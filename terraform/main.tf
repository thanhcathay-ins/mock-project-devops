provider "aws" {
  region = var.region
}

module "vpc" {
  source                  = "./modules/vpc"
  cidr_block              = var.vpc_cidr_block
  public_subnet_cidr      = var.public_subnet_cidr_block  # Sử dụng đúng tên biến
  private_subnet_cidr     = var.private_subnet_cidr_block  # Sử dụng đúng tên biến
  availability_zone       = var.availability_zone
}

module "jenkins" {
  source        = "./modules/ec2"
  ami           = var.jenkins_ami
  instance_type = var.jenkins_instance_type
  subnet_id     = module.vpc.public_subnet_id
  name          = "jenkins-server"
}

module "gitea" {
  source        = "./modules/ec2"
  ami           = var.gitea_ami
  instance_type = var.gitea_instance_type
  subnet_id     = module.vpc.public_subnet_id
  name          = "gitea-server"
}

module "docker_registry" {
  source        = "./modules/ec2"
  ami           = var.docker_registry_ami
  instance_type = var.docker_registry_instance_type
  subnet_id     = module.vpc.public_subnet_id
  name          = "docker-registry-server"
}

# Tạo IAM role cho EKS cluster
resource "aws_iam_role" "eks_cluster_role" {
  name = "eks_cluster_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Effect = "Allow"
      }
    ]
  })

  # Gắn IAM policy cho phép EKS quản lý EC2 instances
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  ]
}

module "eks_cluster" {
  source = "./modules/eks_cluster"
  eks_cluster_name   = "my-eks-cluster"
  iam_role_arn       = aws_iam_role.eks_cluster_role.arn
  subnet_ids         = [module.vpc.public_subnet_id, module.vpc.private_subnet_id]
  node_instance_type = var.eks_instance_type
}