variable "aws_region" {
  default = "ap-south-1"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "availability_zones" {
  default = ["ap-south-1a", "ap-south-1b"]
}

variable "app_port" {
  default = 8080
}

variable "allowed_ingress_ports" {
  description = "List of ports to allow in the security group"
  type        = list(number)
  default     = [80]  # Can be [80, 8080] or anything later
}
