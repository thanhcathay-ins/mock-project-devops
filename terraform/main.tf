provider "aws" {
  region = var.region
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
  subnet_id     = module.vpc.public_subnet_id
  name          = "jenkins-gitea-server"
}

module "docker_registry" {
  source        = "./modules/ec2"
  ami           = var.docker_registry_ami
  instance_type = var.docker_registry_instance_type
  subnet_id     = module.vpc.private_subnet_id
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
      },
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Effect = "Allow"
      }
    ]
  })

  # Gắn IAM policy cho phép EKS quản lý EC2 instances
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSServicePolicy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  ]
}

module "eks_cluster" {
  source = "./modules/eks_cluster"
  eks_cluster_name   = "my-eks-cluster"
  iam_role_arn       = aws_iam_role.eks_cluster_role.arn
  subnet_ids         = [module.vpc.public_subnet_id, module.vpc.private_subnet_id]
  node_instance_type = var.eks_instance_type
}
