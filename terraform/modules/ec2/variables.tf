variable "ami" {
  description = "The AMI to use for the instance"
  type        = string
}

variable "instance_type" {
  description = "The type of instance to start"
  type        = string
}

variable "subnet_id" {
  description = "The VPC subnet ID to launch in"
  type        = string
}

variable "name" {
  description = "The name of the instance"
  type        = string
}

variable "key_name" {
  description = "The SSH key name to use for the instance"
  type        = string
}

variable "security_group_ids" {
  description = "The security group IDs to associate with the instance"
  type        = list(string)
}