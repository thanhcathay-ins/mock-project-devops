resource "aws_eks_cluster" "this" {
  name     = var.eks_cluster_name
  role_arn = var.iam_role_arn
  version  = "1.24"

  vpc_config {
    subnet_ids         = var.subnet_ids
    endpoint_private_access = true
    endpoint_public_access = true
  }
}

resource "aws_eks_node_group" "this" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.eks_cluster_name}-node-group"
  node_role_arn   = var.iam_role_arn
  subnet_ids      = var.subnet_ids

  scaling_config {
    desired_size = 2
    min_size     = 1
    max_size     = 3
  }

  instance_types = [var.node_instance_type]

  depends_on = [
    aws_eks_cluster.this
  ]
}
