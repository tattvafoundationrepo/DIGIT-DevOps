variable "subnet_ids" {}
variable "vpc_security_group_ids" {}
variable "availability_zone" {}
variable "instance_class" {}
variable "engine_version" {}
variable "storage_type" {}
variable "storage_gb" {}
variable "backup_retention_days" {}
variable "parameter_group_name" {}
variable "deletion_protection" {}
variable "cloudwatch_logs_exports" {}
variable "administrator_login" {}

variable "administrator_login_password" {
  sensitive = true
}

variable "db_name" {}
variable "identifier" {}
variable "environment" {}
