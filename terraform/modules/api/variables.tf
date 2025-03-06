variable "environment" {
  description = "The environment (development, staging, production)"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the API"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for the load balancer"
  type        = list(string)
}

variable "db_endpoint" {
  description = "Endpoint of the database"
  type        = string
}

variable "db_name" {
  description = "Name of the database"
  type        = string
}

variable "db_username" {
  description = "Username for the database"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Password for the database"
  type        = string
  sensitive   = true
}

variable "instance_type" {
  description = "Instance type for the API"
  type        = string
  default     = "t4g.micro"
}

variable "ami_id" {
  description = "AMI ID for the EC2 instances"
  type        = string
  default     = "ami-0a3c3a20c09d6f377" # Amazon Linux 2 ARM64
}

variable "key_name" {
  description = "Name of the key pair to use for SSH access"
  type        = string
  default     = null
}

variable "domain_name" {
  description = "Domain name for the API (for SSL certificate)"
  type        = string
  default     = null
} 