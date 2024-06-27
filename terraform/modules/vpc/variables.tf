variable "cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "public_subnet_cidr" {
  description = "The CIDR block for the public subnet"
  type        = string
}

variable "private_subnet_cidr" {
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
