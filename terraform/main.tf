provider "aws" {
  region = var.region
}

module "vpc" {
  source = "./modules/vpc"

  cidr_block                = var.vpc_cidr_block
  public_subnet_cidr_block_1 = var.public_subnet_cidr_block_1
  public_subnet_cidr_block_2 = var.public_subnet_cidr_block_2
  private_subnet_cidr_block_1 = var.private_subnet_cidr_block_1
  private_subnet_cidr_block_2 = var.private_subnet_cidr_block_2
  availability_zone_1       = var.availability_zone_1
  availability_zone_2       = var.availability_zone_2
}

resource "aws_security_group" "jenkins_gitea_sg" {
  name        = "jenkins_gitea_sg"
  description = "Allow SSH and HTTP traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "bastion_sg" {
  name        = "bastion_sg"
  description = "Allow SSH and HTTP/HTTPS traffic from Bastion Host"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.jenkins_gitea_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

module "jenkins_gitea_server" {
  source        = "./modules/ec2"
  ami           = var.jenkins_ami
  instance_type = var.jenkins_instance_type
  subnet_id     = element(module.vpc.public_subnets, 0)
  name          = "jenkins-gitea-server"
  key_name      = var.ssh_key_name_public
  security_group_ids = [aws_security_group.jenkins_gitea_sg.id]
}

module "bastion_host" {
  source        = "./modules/ec2"
  ami           = var.bastion_host_ami
  instance_type = var.bastion_host_instance_type
  subnet_id     = element(module.vpc.private_subnets, 0)
  name          = "bastion-host-server"
  key_name      = var.ssh_key_name_private
  security_group_ids = [aws_security_group.bastion_sg.id]
}
