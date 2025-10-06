
terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = { source = "hashicorp/aws", version = ">= 5.0" }
    archive = { source = "hashicorp/archive", version = ">= 2.4.0" }
  }
}
provider "aws" { region = var.aws_region }
variable "aws_region" { type = string, default = "us-west-2" }
locals { tags = { project = "serverless-order-api", env = "demo", owner = "portfolio" } }
