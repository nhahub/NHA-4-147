variable "aws_region" {
  type        = string
  description = "The AWS region to deploy resources in"
  default     = "us-east-1"
}

variable "aws_az" {
  type        = string
  description = "The AWS availability zone for subnet and EC2 instance"
  default     = "us-east-1a"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "vpc_name" {
  type        = string
  description = "Name tag for the VPC"
  default     = "vpc"
}

variable "igw_name" {
  type        = string
  description = "Name tag for the Internet Gateway"
  default     = "gateway"
}

variable "subnet_cidr" {
  type        = string
  description = "CIDR block for the subnet"
  default     = "10.0.1.0/24"
}

variable "subnet_name" {
  type        = string
  description = "Name tag for the Subnet"
  default     = "subnet"
}

variable "route_table_name" {
  type        = string
  description = "Name tag for the Route Table"
  default     = "route-table"
}

variable "security_group_name" {
  type        = string
  description = "Name tag for the Security Group"
  default     = "security-group"
}

variable "security_group_description" {
  type        = string
  description = "Description of the security group"
  default     = "Allow SSH and HTTP traffic"
}

variable "ec2_ami_id" {
  type        = string
  description = "AMI ID to use for launching the EC2 instance"
  default     = "ami-********"
}

variable "ec2_instance_type" {
  type        = string
  description = "EC2 instance type (e.g., t2.micro)"
  default     = "t2.micro"
}

variable "ec2_key_name" {
  type        = string
  description = "Name of the existing EC2 key pair to use for SSH access"
}

variable "ec2_volume_size" {
  type        = number
  description = "Size of the EBS volume in GB for the EC2 instance"
  default     = 8
}

variable "ec2_instance_name" {
  type        = string
  description = "Name tag for the EC2 instance"
  default     = "ec2"
}