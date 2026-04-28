output "vpc_id" {
  description = "ID of the VPC."
  value       = module.vpc.vpc_id
}

output "public_subnet_id" {
  description = "ID of the public subnet."
  value       = module.vpc.public_subnet_id
}

output "private_subnet_id" {
  description = "ID of the private subnet."
  value       = module.vpc.private_subnet_id
}

output "ec2_instance_id" {
  description = "ID of the EC2 instance."
  value       = module.compute.instance_id
}

output "ec2_public_ip" {
  description = "Public IP of the EC2 instance."
  value       = module.compute.public_ip
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket."
  value       = module.storage.bucket_name
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket."
  value       = module.storage.bucket_arn
}
