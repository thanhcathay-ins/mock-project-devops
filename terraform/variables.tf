variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-1"
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr_block_1" {
  description = "CIDR block for the first public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "public_subnet_cidr_block_2" {
  description = "CIDR block for the second public subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "private_subnet_cidr_block_1" {
  description = "CIDR block for the first private subnet"
  type        = string
  default     = "10.0.3.0/24"
}

variable "private_subnet_cidr_block_2" {
  description = "CIDR block for the second private subnet"
  type        = string
  default     = "10.0.4.0/24"
}

variable "availability_zone_1" {
  description = "The first availability zone"
  type        = string
  default     = "ap-southeast-1a"
}

variable "availability_zone_2" {
  description = "The second availability zone"
  type        = string
  default     = "ap-southeast-1b"
}

variable "jenkins_ami" {
  description = "AMI ID for the Jenkins server"
  type        = string
  default     = "ami-0b287aaaab87c114d"
}

variable "jenkins_instance_type" {
  description = "Instance type for the Jenkins server"
  type        = string
  default     = "t2.medium"
}

variable "bastion_host_ami" {
  description = "AMI ID for the Jenkins server"
  type        = string
  default     = "ami-0b287aaaab87c114d"
}

variable "bastion_host_instance_type" {
  description = "Instance type for the Jenkins server"
  type        = string
}

variable "ssh_key_name_public" {
  description = "SSH key name for the public instances"
  type        = string
}

variable "ssh_key_name_private" {
  description = "SSH key name for the public instances"
  type        = string
}
