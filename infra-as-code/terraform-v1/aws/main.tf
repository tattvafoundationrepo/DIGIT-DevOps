terraform {
  backend "s3" {
    bucket         = "bmc-prod-s3"
    key            = "digit-bootcamp-setup/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "bmc-prod-s3"
    encrypt        = true
  }
}

module "network" {
  source             = "../modules/kubernetes/aws/network"
  vpc_cidr_block     = var.vpc_cidr_block
  cluster_name       = var.cluster_name
  availability_zones = var.network_availability_zones
}

# Postgres DB
module "db" {
  source                       = "../modules/db/aws"
  subnet_ids                   = module.network.private_subnets
  vpc_security_group_ids       = [module.network.rds_db_sg_id]
  availability_zone            = element(var.availability_zones, 0)
  instance_class               = "db.t3.medium"
  engine_version               = "13.20"
  storage_type                 = "gp2"
  storage_gb                   = 100
  backup_retention_days        = 15
  administrator_login          = var.db_username
  administrator_login_password = var.db_password
  identifier                   = "${var.cluster_name}-db"
  db_name                      = var.db_name
  environment                  = var.cluster_name
}

module "eks" {
  source = "terraform-aws-modules/eks/aws"

  cluster_name    = var.cluster_name
  cluster_version = var.kubernetes_version

  vpc_id = module.network.vpc_id
  subnets = concat(
    module.network.private_subnets,
    module.network.public_subnets
  )

  cluster_enabled_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  # =====================================
  # WORKER GROUPS (OLD MODULE SYNTAX)
  # =====================================
  worker_groups = [
    {
      name = "standard"

      ami_id        = "ami-07c784a35375304ad"
      instance_type = "m5a.2xlarge"

      subnets = ["subnet-02fec7d5efae0f94b"]

      asg_desired_capacity = 3
      asg_max_size         = 4
      asg_min_size         = 1

      kubelet_extra_args = ""

      spot_instance_pools      = null
      spot_allocation_strategy = null
    }
  ]

  # =====================================
  # TAGS (OLD MODULE STYLE)
  # =====================================
  tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    "KubernetesCluster"                         = var.cluster_name
  }
}
data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

data "aws_caller_identity" "current" {}

data "tls_certificate" "thumb" {
  url = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

resource "aws_iam_openid_connect_provider" "eks_oidc_provider" {
  url = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer

  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = [
    data.tls_certificate.thumb.certificates[0].sha1_fingerprint
  ]
}


resource "aws_iam_role" "eks_iam" {
  name = "${var.cluster_name}-eks"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EKSWorkerAssumeRole"
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://", "")}"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://", "")}:sub" = "system:serviceaccount:kube-system:ebs-csi-controller-sa"
          }
        }
      }
    ]
  })
}


resource "kubernetes_service_account_v1" "ebs_csi_controller_sa" {
  metadata {
    name      = "ebs-csi-controller-sa"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.eks_iam.arn
    }
  }
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEBSCSIDriverPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.eks_iam.name
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEC2FullAccess" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
  role       = aws_iam_role.eks_iam.name
}

resource "aws_security_group_rule" "rds_db_ingress_workers" {
  description              = "Allow worker nodes to communicate with RDS database"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = module.network.rds_db_sg_id
  source_security_group_id = module.eks.worker_security_group_id
  type                     = "ingress"
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name = data.aws_eks_cluster.cluster.name
  addon_name   = "kube-proxy"
}

resource "aws_eks_addon" "core_dns" {
  cluster_name = data.aws_eks_cluster.cluster.name
  addon_name   = "coredns"
}

resource "aws_eks_addon" "aws_ebs_csi_driver" {
  cluster_name = data.aws_eks_cluster.cluster.name
  addon_name   = "aws-ebs-csi-driver"
}

module "es-master" {
  source             = "../modules/storage/aws"
  storage_count      = 3
  environment        = var.cluster_name
  disk_prefix        = "es-master"
  availability_zones = var.availability_zones
  storage_sku        = "gp2"
  disk_size_gb       = 25
}

module "es-data-v1" {
  source             = "../modules/storage/aws"
  storage_count      = 3
  environment        = var.cluster_name
  disk_prefix        = "es-data-v1"
  availability_zones = var.availability_zones
  storage_sku        = "gp2"
  disk_size_gb       = 100
}

module "zookeeper" {
  source             = "../modules/storage/aws"
  storage_count      = 3
  environment        = var.cluster_name
  disk_prefix        = "zookeeper"
  availability_zones = var.availability_zones
  storage_sku        = "gp2"
  disk_size_gb       = 20
}

module "kafka" {
  source             = "../modules/storage/aws"
  storage_count      = 3
  environment        = var.cluster_name
  disk_prefix        = "kafka"
  availability_zones = var.availability_zones
  storage_sku        = "gp2"
  disk_size_gb       = 200
}
