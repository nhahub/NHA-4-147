module "vpc" {
  source   = "./modules/vpc"
  vpc_cidr = var.vpc_cidr
  vpc_name = var.vpc_name
}

module "igw" {
  source   = "./modules/internet_gateway"
  vpc_id   = module.vpc.vpc_id
  igw_name = var.igw_name
}

module "subnet" {
  source            = "./modules/subnet"
  vpc_id            = module.vpc.vpc_id
  subnet_cidr       = var.subnet_cidr
  availability_zone = var.aws_az
  subnet_name       = var.subnet_name
}

module "route_table" {
  source              = "./modules/route_table"
  vpc_id              = module.vpc.vpc_id
  igw_id              = module.igw.igw_id
  subnet_id           = module.subnet.subnet_id
  route_table_name    = var.route_table_name
}

module "security_group" {
  source                     = "./modules/security_group"
  vpc_id                     = module.vpc.vpc_id
  security_group_name        = var.security_group_name
  security_group_description = var.security_group_description
}


resource "tls_private_key" "rsa_private_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Save the private key to a local file
resource "local_file" "private_key_file" {
  content  = tls_private_key.rsa_private_key.private_key_pem
  filename = "${path.root}/private_key.pem"
}

# Create an AWS Key Pair using the generated public key
resource "aws_key_pair" "public_key_pair" {
  key_name   = "public_key_pair"
  public_key = tls_private_key.rsa_private_key.public_key_openssh
}


module "k8s_master" {
  source            = "./modules/ec2"
  ami_id            = var.ec2_ami_id
  instance_type     = var.ec2_instance_type
  subnet_id         = module.subnet.subnet_id
  security_group_id = module.security_group.security_group_id
  key_name          = aws_key_pair.public_key_pair.key_name
  volume_size       = var.ec2_volume_size
  instance_name     = "k8s-master"
}


module "k8s_worker01" {
  source            = "./modules/ec2"
  ami_id            = var.ec2_ami_id
  instance_type     = var.ec2_instance_type
  subnet_id         = module.subnet.subnet_id
  security_group_id = module.security_group.security_group_id
  key_name          = aws_key_pair.public_key_pair.key_name
  volume_size       = var.ec2_volume_size
  instance_name     = "k8s-worker01"
}

module "k8s_worker02" {
  source            = "./modules/ec2"
  ami_id            = var.ec2_ami_id
  instance_type     = var.ec2_instance_type
  subnet_id         = module.subnet.subnet_id
  security_group_id = module.security_group.security_group_id
  key_name          = aws_key_pair.public_key_pair.key_name
  volume_size       = var.ec2_volume_size
  instance_name     = "k8s-worker02"
}

module "sonarqube" {
  source            = "./modules/ec2"
  ami_id            = var.ec2_ami_id
  instance_type     = var.ec2_instance_type
  subnet_id         = module.subnet.subnet_id
  security_group_id = module.security_group.security_group_id
  key_name          = aws_key_pair.public_key_pair.key_name
  volume_size       = var.ec2_volume_size
  instance_name     = "sonarqube"
}