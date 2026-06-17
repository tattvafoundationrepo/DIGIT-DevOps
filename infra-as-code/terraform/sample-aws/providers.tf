# Provider Configuration

provider "aws" {
  region = "ap-south-1"
}

# Using these data sources allows the configuration to be generic for any region.
data "aws_region" "current" {}

data "aws_availability_zones" "available" {}

# Retained for compatibility with older modules in this repository.
provider "http" {}
