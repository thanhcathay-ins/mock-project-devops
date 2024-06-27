variable "eks_cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
}

variable "iam_role_arn" {
  description = "The ARN of the IAM role for EKS"
  type        = string
}

variable "subnet_ids" {
  description = "The list of subnet IDs for the EKS cluster"
  type        = list(string)
}

variable "node_instance_type" {
  description = "The instance type for the EKS node group"
  type        = string
}
