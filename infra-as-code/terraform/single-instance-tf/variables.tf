#
# Variables Configuration
#

variable "cluster_name" {
  default = "single-instance"
}

variable "vpc_cidr_block" {
  default = "192.168.0.0/16"
}

variable "network_availability_zones" {
  default = ["ap-south-1b", "ap-south-1a"]
}

variable "availability_zones" {
  default = ["ap-south-1b"]
}

variable "kubernetes_version" {
  default = "1.20"
}

variable "instance_type" {
  default = "m4.xlarge"
}

variable "override_instance_types" {
  default = ["r5a.large", "r5ad.large", "r5d.large", "m4.xlarge"]
  
}

variable "number_of_worker_nodes" {
  default = "2"
}

variable "ssh_key_name" {
  default = "test-singleinstance"
}
variable "iam_keybase_user" {
 default = "keybase:egovterraform"
}

