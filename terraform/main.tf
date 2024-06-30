provider "aws" {
  region = var.region
}

resource "aws_security_group" "bastion_sg" {
  name        = "bastion_sg"
  description = "Allow SSH traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
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

resource "aws_security_group" "jenkins_gitea_sg" {
  name        = "jenkins_gitea_sg"
  description = "Allow SSH traffic from Bastion Host"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

module "vpc" {
  source                  = "./modules/vpc"
  cidr_block              = var.vpc_cidr_block
  public_subnet_cidr      = var.public_subnet_cidr_block
  private_subnet_cidr     = var.private_subnet_cidr_block
  availability_zone_1     = var.availability_zone_1
  availability_zone_2     = var.availability_zone_2
}

module "jenkins-gitea-server" {
  source        = "./modules/ec2"
  ami           = var.jenkins_ami
  instance_type = var.jenkins_instance_type
  subnet_id     = module.vpc.private_subnet_id
  name          = "jenkins-gitea-server"
  key_name      = var.ssh_key_name_private
  security_group_ids = [aws_security_group.jenkins_gitea_sg.id]
}

module "bastion_host" {
  source        = "./modules/ec2"
  ami           = var.bastion_host_ami
  instance_type = var.bastion_host_instance_type
  subnet_id     = module.vpc.public_subnet_id
  name          = "bastion-host-server"
  key_name      = var.ssh_key_name_public
  security_group_ids = [aws_security_group.bastion_sg.id]
}

