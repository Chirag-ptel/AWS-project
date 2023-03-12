variable "region" {
  description = "The AWS region in which to create the VPC"
  default = "us-east-1"
}

variable "availability_zones" {
  description = "The availability zones for the subnets"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}