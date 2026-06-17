variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "cluster_name" {
  description = "Name of the Kubernetes cluster"
}

variable "availability_zones" {
  description = "Availability zones where public and private subnets are created"
  default     = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
}
