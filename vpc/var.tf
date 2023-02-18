variable "region" {
  description = "The AWS region in which to create the VPC"
  default = "us-east-1"
}

variable "availability_zones" {
  description = "The availability zones for the subnets"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

/*variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC"
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr_blocks" {
  description = "The CIDR blocks for the public subnets"
  type = list(string)
  default = [
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24",
  ]
}

variable "private_subnet_cidr_blocks" {
  description = "The CIDR blocks for the private subnets"
  type = list(string)
  default = [
    "10.0.11.0/24",
    "10.0.12.0/24",
    "10.0.13.0/24",
  ]
}*/

