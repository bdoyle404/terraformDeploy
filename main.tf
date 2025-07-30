## See https://github.com/tariq87/terraformDeploy/tree/main
variable "region" {}
variable "vpc_name" {}

provider "aws" {
    region = var.region
}

data "aws_ami" "latest_amazon_linux" {
    most_recent = true
    owners = ["amazon"]
    filter {
        name = "name"
        values = ["amzn2-ami-hvm-*"]
    }
    filter {
        name = "architecture"
        values = ["x86_64"]
    }
    filter {
        name = "root-device-type"
        values = ["ebs"]
    }
}

data "aws_vpc" "selected_vpc" {
    filter {
        name   = "tag:Name"
        values = [var.vpc_name]
    }
}

data "aws_subnets" "private" {
    filter {
        name   = "vpc-id"
        values = [data.aws_vpc.selected_vpc.id]
    }
    tags = {
        type = "private"
        stack = "terraformDeploy"
    }
}

resource "aws_instance" "ec2_instance" {
    ami           = data.aws_ami.latest_amazon_linux.id
    instance_type = "t2.micro"
    subnet_id = data.aws_subnets.private.ids[0]
    tags = {
        Name = "WebServer"
        Purpose = "test"
        Stack = "terraformDeploy"
    }
}
