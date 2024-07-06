provider "aws" {
  region = "ap-southeast-1"
}

# Tạo VPC
resource "aws_vpc" "eks_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "eks_vpc"
  }
}

# Tạo 2 public subnets (tự động gán IP public)
resource "aws_subnet" "public_subnet1" {
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-southeast-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "eks_public_subnet1"
  }
}

resource "aws_subnet" "public_subnet2" {
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ap-southeast-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "eks_public_subnet2"
  }
}

# Tạo Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.eks_vpc.id

  tags = {
    Name = "eks_igw"
  }
}

# Tạo route table
resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "eks_route_table"
  }
}

# Liên kết route table với public subnets
resource "aws_route_table_association" "public_subnet1_association" {
  subnet_id      = aws_subnet.public_subnet1.id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_route_table_association" "public_subnet2_association" {
  subnet_id      = aws_subnet.public_subnet2.id
  route_table_id = aws_route_table.route_table.id
}

# Tạo IAM role cho EKS cluster (thêm các quyền cần thiết)
resource "aws_iam_role" "eks_cluster_role" {
  name = "eks_cluster_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = ["eks.amazonaws.com"]
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

# Tạo IAM role cho EKS node group
resource "aws_iam_role" "eks_node_group_role" {
  name = "eks_node_group_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Effect = "Allow"
      }
    ]
  })

  # Gắn IAM policy cho phép các node trong EKS node group
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  ]
}

# Tạo instance profile cho node group
resource "aws_iam_instance_profile" "eks_node_group_instance_profile" {
  name = "eks_node_group_instance_profile"
  role = aws_iam_role.eks_node_group_role.name
}

# Tạo EKS cluster
resource "aws_eks_cluster" "eks_cluster" {
  name     = "eks_cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = "1.24"

  vpc_config {
    subnet_ids              = [aws_subnet.public_subnet1.id, aws_subnet.public_subnet2.id]
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  depends_on = [
    aws_iam_role.eks_cluster_role
  ]
}

# Tạo EKS node group
resource "aws_eks_node_group" "eks_node_group" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "eks_node_group"
  node_role_arn   = aws_iam_role.eks_node_group_role.arn  # Sử dụng IAM role của node group
  subnet_ids      = [aws_subnet.public_subnet1.id, aws_subnet.public_subnet2.id]

  scaling_config {
    desired_size = 1
    min_size     = 1
    max_size     = 1
  }

  instance_types = ["t3.medium"]

  depends_on = [
    aws_eks_cluster.eks_cluster
  ]
}
