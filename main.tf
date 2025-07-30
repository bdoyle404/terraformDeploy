## See https://github.com/tariq87/terraformDeploy/tree/main
## Creates the VPC and subnet and uses their IDs.

variable "region" {
    default = "us-east-2"
}
variable "basename" {
    default = "terraformDeploy"
}
variable "vpc_name" {
    default = "vpn-terraformDeploy"
}
variable "subnet_name" {
    default = "snet-terraformDeploy"
}

provider "aws" {
  region = var.region
}

# --- Create VPC and subnet -----------------------------------------------
resource "aws_vpc" "this" {
  cidr_block           = "10.0.0.0/24"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = var.vpc_name
    Purpose = "test"
  }
}

resource "aws_subnet" "subnet_id" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = "10.0.0.0/25" # inside 10.0.0.0/24
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.subnet_name}"
    Purpose = "test"
  }
}

# --- AMI lookup -----------------------------------------------------------
data "aws_ami" "latest_amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

# --- Launch instance in the created subnet --------------------------------
resource "aws_instance" "ec2_instance" {
  ami           = data.aws_ami.latest_amazon_linux.id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.subnet_id.id

  tags = {
    Name    = "WebServer"
    Purpose = "test"
    Stack   = "${var.basename}"
  }
}
