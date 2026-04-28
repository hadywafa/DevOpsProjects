module "vpc" {
  source = "./modules/vpc"

  project_name        = var.project_name
  environment         = var.environment
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
  aws_region          = var.aws_region
}

module "compute" {
  source = "./modules/compute"

  project_name      = var.project_name
  environment       = var.environment
  vpc_id            = module.vpc.vpc_id
  subnet_id         = module.vpc.public_subnet_id
  allowed_ssh_cidr  = var.allowed_ssh_cidr
  instance_type     = var.ec2_instance_type
}

module "storage" {
  source = "./modules/storage"

  project_name           = var.project_name
  environment            = var.environment
  s3_bucket_name_prefix  = var.s3_bucket_name_prefix
}
