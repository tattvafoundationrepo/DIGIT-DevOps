# Variables Configuration. Check for REPLACE to substitute custom values.

variable "cluster_name" {
  description = "Name of the Kubernetes cluster"
  default     = "bmc-prod"
}

variable "vpc_cidr_block" {
  description = "CIDR block"
  default     = "192.168.0.0/16"
}

variable "network_availability_zones" {
  description = "Availability zones used by the VPC module"
  default     = ["ap-south-1b", "ap-south-1a"]
}

variable "availability_zones" {
  description = "Availability zones used by zonal storage and database placement"
  default     = ["ap-south-1b"]
}

variable "kubernetes_version" {
  description = "Kubernetes version for EKS"
  default     = "1.34"
}

variable "cluster_authentication_mode" {
  description = "EKS cluster authentication mode"
  default     = "CONFIG_MAP"
}

variable "cluster_endpoint_public_access" {
  description = "Enable public access for the EKS API endpoint"
  default     = true
}

variable "cluster_endpoint_private_access" {
  description = "Enable private access for the EKS API endpoint"
  default     = false
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "CIDR blocks allowed to reach the public EKS API endpoint"
  default     = ["0.0.0.0/0"]
}

variable "cluster_service_ipv4_cidr" {
  description = "Kubernetes service IPv4 CIDR for the EKS cluster"
  default     = "10.100.0.0/16"
}

variable "eks_cluster_role_arn" {
  description = "Existing IAM role ARN used by the EKS cluster"
  default     = "arn:aws:iam::713626956440:role/bmc-prod2025012208434463150000000c"
}

variable "eks_cluster_security_group_id" {
  description = "Existing additional cluster security group attached to the EKS control plane"
  default     = "sg-07b503a66e1e1023c"
}

variable "eks_node_security_group_id" {
  description = "Existing security group used by the current managed node group instances"
  default     = "sg-072f13c3d135db248"
}

variable "eks_legacy_worker_security_group_id" {
  description = "Existing legacy worker security group still allowed to reach RDS"
  default     = "sg-05ab7cdde5b9d09bb"
}

variable "instance_type" {
  description = "Instance type for the EKS managed node group"
  default     = "m5a.xlarge"
}

variable "override_instance_types" {
  description = "Legacy spot override instance types retained for compatibility"
  default     = ["r5a.large", "r5ad.large", "r5d.large", "m4.xlarge"]
}

variable "number_of_worker_nodes" {
  description = "Desired number of worker nodes"
  default     = 3
}

variable "eks_managed_node_group_name" {
  description = "EKS managed node group name"
  default     = "bmc-managed-m5a-xlarge-1b"
}

variable "eks_managed_node_group_subnet_ids" {
  description = "Subnet IDs used by the EKS managed node group"
  default     = ["subnet-02fec7d5efae0f94b"]
}

variable "eks_managed_node_ami_type" {
  description = "AMI type used by the EKS managed node group"
  default     = "AL2023_x86_64_STANDARD"
}

variable "eks_managed_node_ami_release_version" {
  description = "AMI release version used by the EKS managed node group"
  default     = "1.34.4-20260318"
}

variable "eks_managed_node_capacity_type" {
  description = "Capacity type used by the EKS managed node group"
  default     = "ON_DEMAND"
}

variable "eks_managed_node_min_size" {
  description = "Minimum size for the EKS managed node group"
  default     = 3
}

variable "eks_managed_node_max_size" {
  description = "Maximum size for the EKS managed node group"
  default     = 6
}

variable "eks_managed_node_disk_size" {
  description = "Root disk size in GiB for EKS managed nodes"
  default     = 60
}

variable "eks_managed_node_max_unavailable" {
  description = "Maximum unavailable nodes during managed node group updates"
  default     = 1
}

variable "eks_managed_node_role_arn" {
  description = "Existing IAM role ARN used by the EKS managed node group"
  default     = "arn:aws:iam::713626956440:role/bmc-prod-managed-node-role"
}

variable "ssh_key_name" {
  description = "Legacy SSH key name retained for compatibility"
  default     = "demo-ssh-key"
}

variable "db_name" {
  description = "RDS DB name. Do not use hyphens or special characters."
  default     = "bmcprod2025"
}

variable "db_username" {
  description = "RDS database user name"
  default     = "bmcprodadmin"
}

variable "db_instance_class" {
  description = "RDS instance class"
  default     = "db.r6i.large"
}

variable "db_engine_version" {
  description = "PostgreSQL engine version"
  default     = "14.22"
}

variable "db_storage_type" {
  description = "RDS storage type"
  default     = "gp2"
}

variable "db_storage_gb" {
  description = "Allocated RDS storage in GiB"
  default     = 100
}

variable "db_backup_retention_days" {
  description = "RDS backup retention in days"
  default     = 15
}

variable "db_parameter_group_name" {
  description = "RDS parameter group name"
  default     = "postgres14-md5-auth"
}

variable "db_deletion_protection" {
  description = "Enable deletion protection for RDS"
  default     = true
}

variable "db_cloudwatch_logs_exports" {
  description = "CloudWatch log exports enabled for RDS"
  default     = ["postgresql", "iam-db-auth-error"]
}

# DO NOT fill in here. This will be asked at runtime.
variable "db_password" {}

variable "public_key" {
  description = "Legacy SSH public key retained for compatibility"
  default     = "ssh-rsa zxyzxyzxyzxyzxyzxyzxyzxyzxyzxyzxyzxyzxyzxyzxyzxyzxyzxyzxyzxyzxyzxyzxyzxyzxyzxyzxyzxyzxyzxyzxyzxyzxyzxyzxyzxy"
}

variable "vpc_cni_addon_version" {
  description = "Version for the vpc-cni EKS addon"
  default     = "v1.21.1-eksbuild.3"
}

variable "aws_ebs_csi_driver_addon_version" {
  description = "Version for the aws-ebs-csi-driver EKS addon"
  default     = "v1.55.0-eksbuild.1"
}

variable "kube_proxy_addon_version" {
  description = "Version for the kube-proxy EKS addon"
  default     = "v1.34.3-eksbuild.2"
}

variable "core_dns_addon_version" {
  description = "Version for the coredns EKS addon"
  default     = "v1.13.1-eksbuild.1"
}
