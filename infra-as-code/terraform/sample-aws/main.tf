terraform {
  required_version = ">= 1.5.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.42"
    }
    http = {
      source  = "hashicorp/http"
      version = ">= 3.5"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 3.0"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.9"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.0"
    }
  }

  backend "s3" {
    bucket         = "bmc-prod-s3"
    key            = "digit-bootcamp-setup/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "bmc-prod-s3"
    encrypt        = true
  }
}

################################
# NETWORK
################################
module "network" {
  source             = "../modules/kubernetes/aws/network"
  vpc_cidr_block     = var.vpc_cidr_block
  cluster_name       = var.cluster_name
  availability_zones = var.network_availability_zones
}

################################
# DATABASE
################################
module "db" {
  source                       = "../modules/db/aws"
  subnet_ids                   = module.network.private_subnets
  vpc_security_group_ids       = [module.network.rds_db_sg_id]
  availability_zone            = element(var.availability_zones, 0)
  instance_class               = var.db_instance_class
  engine_version               = var.db_engine_version
  storage_type                 = var.db_storage_type
  storage_gb                   = var.db_storage_gb
  backup_retention_days        = var.db_backup_retention_days
  parameter_group_name         = var.db_parameter_group_name
  deletion_protection          = var.db_deletion_protection
  cloudwatch_logs_exports      = var.db_cloudwatch_logs_exports
  administrator_login          = var.db_username
  administrator_login_password = var.db_password
  identifier                   = "${var.cluster_name}-db"
  db_name                      = var.db_name
  environment                  = var.cluster_name
}

################################
# EKS CLUSTER
################################
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = var.cluster_name
  kubernetes_version = var.kubernetes_version

  vpc_id     = module.network.vpc_id
  subnet_ids = concat(module.network.private_subnets, module.network.public_subnets)

  authentication_mode          = var.cluster_authentication_mode
  endpoint_public_access       = var.cluster_endpoint_public_access
  endpoint_private_access      = var.cluster_endpoint_private_access
  endpoint_public_access_cidrs = var.cluster_endpoint_public_access_cidrs
  service_ipv4_cidr            = var.cluster_service_ipv4_cidr

  create_iam_role = false
  iam_role_arn    = var.eks_cluster_role_arn

  create_security_group = false
  security_group_id     = var.eks_cluster_security_group_id

  create_node_security_group = false
  node_security_group_id     = var.eks_node_security_group_id

  enabled_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]

  create_cloudwatch_log_group        = false
  create_primary_security_group_tags = false

  cluster_tags = {
    KubernetesCluster                           = var.cluster_name
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }

  # OIDC and addons are intentionally managed as standalone resources below to
  # preserve the existing resource addresses in this Terraform root module.
  enable_irsa       = false
  create_kms_key    = false
  encryption_config = null

  eks_managed_node_groups = {}

  tags = {}
}


################################
# EKS MANAGED NODE GROUP
################################
resource "aws_eks_node_group" "bmc_managed_m5a_xlarge_1b" {
  cluster_name    = module.eks.cluster_name
  node_group_name = var.eks_managed_node_group_name
  node_role_arn   = var.eks_managed_node_role_arn
  subnet_ids      = var.eks_managed_node_group_subnet_ids

  version         = var.kubernetes_version
  release_version = var.eks_managed_node_ami_release_version
  ami_type        = var.eks_managed_node_ami_type
  capacity_type   = var.eks_managed_node_capacity_type
  instance_types  = [var.instance_type]
  disk_size       = var.eks_managed_node_disk_size

  scaling_config {
    min_size     = var.eks_managed_node_min_size
    max_size     = var.eks_managed_node_max_size
    desired_size = var.number_of_worker_nodes
  }

  update_config {
    max_unavailable = var.eks_managed_node_max_unavailable
  }

  tags = {}
}

################################
# DATA SOURCES
################################
data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
}

data "aws_caller_identity" "current" {}

data "tls_certificate" "thumb" {
  url = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}

################################
# LOCALS
################################
locals {
  eks_oidc_issuer = replace(
    data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer,
    "https://",
    ""
  )
}

################################
# KUBERNETES PROVIDER
################################
provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

################################
# OIDC PROVIDER
################################
resource "aws_iam_openid_connect_provider" "eks_oidc_provider" {
  url             = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.thumb.certificates[0].sha1_fingerprint]
}

################################
# EBS CSI IRSA
################################
resource "aws_iam_role" "ebs_csi_irsa" {
  name = "bmc-prod-ebs-csi-irsa"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.eks_oidc_provider.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${local.eks_oidc_issuer}:sub" = "system:serviceaccount:kube-system:ebs-csi-controller-sa"
          }
        }
      }
    ]
  })

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_iam_role_policy_attachment" "ebs_csi_policy" {
  role       = aws_iam_role.ebs_csi_irsa.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

################################
# EKS ADDONS
################################
resource "aws_eks_addon" "vpc_cni" {
  cluster_name  = data.aws_eks_cluster.cluster.name
  addon_name    = "vpc-cni"
  addon_version = var.vpc_cni_addon_version
}

resource "aws_eks_addon" "aws_ebs_csi_driver" {
  cluster_name             = data.aws_eks_cluster.cluster.name
  addon_name               = "aws-ebs-csi-driver"
  addon_version            = var.aws_ebs_csi_driver_addon_version
  service_account_role_arn = aws_iam_role.ebs_csi_irsa.arn
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name  = data.aws_eks_cluster.cluster.name
  addon_name    = "kube-proxy"
  addon_version = var.kube_proxy_addon_version
}

resource "aws_eks_addon" "core_dns" {
  cluster_name  = data.aws_eks_cluster.cluster.name
  addon_name    = "coredns"
  addon_version = var.core_dns_addon_version
}

################################
# SECURITY GROUP RULES
################################
resource "aws_security_group_rule" "rds_db_ingress_workers" {
  description              = "Allow worker nodes to communicate with RDS database"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = module.network.rds_db_sg_id
  source_security_group_id = var.eks_legacy_worker_security_group_id
  type                     = "ingress"
}

resource "aws_security_group_rule" "rds_db_ingress_managed_nodes" {
  description              = "EKS managed nodes (AL2023)"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = module.network.rds_db_sg_id
  source_security_group_id = var.eks_node_security_group_id
  type                     = "ingress"
}

################################
# STORAGE MODULES
################################
module "es-master" {
  source             = "../modules/storage/aws"
  storage_count      = 3
  environment        = var.cluster_name
  disk_prefix        = "es-master"
  availability_zones = var.availability_zones
  storage_sku        = "gp3"
  disk_size_gb       = 25
}

module "es-data-v1" {
  source             = "../modules/storage/aws"
  storage_count      = 3
  environment        = var.cluster_name
  disk_prefix        = "es-data-v1"
  availability_zones = var.availability_zones
  storage_sku        = "gp3"
  disk_size_gb       = 100
}

module "zookeeper" {
  source             = "../modules/storage/aws"
  storage_count      = 3
  environment        = var.cluster_name
  disk_prefix        = "zookeeper"
  availability_zones = var.availability_zones
  storage_sku        = "gp3"
  disk_size_gb       = 20
}

module "kafka" {
  source             = "../modules/storage/aws"
  storage_count      = 3
  environment        = var.cluster_name
  disk_prefix        = "kafka"
  availability_zones = var.availability_zones
  storage_sku        = "gp3"
  disk_size_gb       = 200
}
