
variable "region" {
  description = "The AWS region to deploy the infrastructure"
  type        = string
}

variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "public_subnet_cidr_block" {
  description = "The CIDR block for the public subnet"
  type        = string
}

variable "private_subnet_cidr_block" {
  description = "The CIDR block for the private subnet"
  type        = string
}

variable "availability_zone_1" {
  description = "The availability zone 1 for the subnets"
  type        = string
}

variable "availability_zone_2" {
  description = "The availability zone 2 for the subnets"
  type        = string
}

variable "jenkins_ami" {
  description = "The AMI ID for the Jenkins server"
  type        = string
}

variable "jenkins_instance_type" {
  description = "The instance type for the Jenkins server"
  type        = string
}


variable "docker_registry_ami" {
  description = "The AMI ID for the Docker Registry server"
  type        = string
}

variable "docker_registry_instance_type" {
  description = "The instance type for the Docker Registry server"
  type        = string
}

variable "eks_instance_type" {
  description = "The instance type for the EKS node group"
  type        = string
}
