variable "aws_region" {
  type        = string
  description = "AWS region for all resources."
  default     = "us-east-1"
}

variable "environment" {
  type        = string
  description = "Deployment environment (dev or prod)."
  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "environment must be 'dev' or 'prod'."
  }
}

variable "project_name" {
  type        = string
  description = "Short project identifier used in resource names (lowercase, ≤10 chars)."
  default     = "awsdemo"
  validation {
    condition     = length(var.project_name) <= 10 && can(regex("^[a-z0-9]+$", var.project_name))
    error_message = "project_name must be lowercase alphanumeric and ≤10 chars."
  }
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC."
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  type        = string
  description = "CIDR block for the public subnet."
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  type        = string
  description = "CIDR block for the private subnet."
  default     = "10.0.2.0/24"
}

variable "ec2_instance_type" {
  type        = string
  description = "EC2 instance type."
  default     = "t3.micro"
}

variable "allowed_ssh_cidr" {
  type        = string
  description = "CIDR allowed to SSH into the EC2 instance. Use your IP: x.x.x.x/32"
  default     = "0.0.0.0/0"  # CHANGE THIS to your IP in production
}

variable "s3_bucket_name_prefix" {
  type        = string
  description = "Prefix for the S3 bucket name (must be globally unique; random suffix appended)."
  default     = "demo-data"
}
