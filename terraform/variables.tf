variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "n0sebleed-eks"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "node_group_name" {
  description = "Name of the node group"
  type        = string
  default     = "default"
}

variable "instance_types" {
  description = "Instance types for node group"
  type        = list(string)
  default     = ["t3.micro"]
}

variable "desired_capacity" {
  description = "Desired number of nodes"
  type        = number
  default     = 1
}

variable "min_size" {
  description = "Minimum number of nodes"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum number of nodes"
  type        = number
  default     = 3
}

variable "create_node_group" {
  description = "Whether to create the node group"
  type        = bool
  default     = true
}