variable "ami" {
  description = "AMI ID"
  type        = string
}

variable "instance_type" {
  description = "Instance type"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID"
  type        = string
}

variable "key_name" {
  description = "SSH key name"
  type        = string
}

variable "name" {
  description = "Name tag for the instance"
  type        = string
}

variable "security_group_ids" {
  description = "Security group IDs"
  type        = list(string)
}

variable "volume_size" {
  description = "Size of the EBS volume in GiB"
  type        = number
  default     = 16
}

variable "volume_type" {
  description = "Type of the EBS volume"
  type        = string
  default     = "gp3"
}

variable "delete_on_termination" {
  description = "Whether the volume should be deleted on instance termination"
  type        = bool
  default     = true
}
