variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "flask-ec2-app"
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"  # Free tier eligible
}

variable "ami_id" {
  description = "AMI ID (leave empty for latest Amazon Linux 2)"
  type        = string
  default     = ""
}

variable "key_name" {
  description = "SSH key pair name"
  type        = string
  default     = "linux_key"
}

variable "private_key_path" {
  description = "Path to your existing SSH private key"
  type        = string
  default     = "~/.ssh/rrskey"
}

variable "allowed_ssh_cidr" {
  description = "CIDR blocks allowed to SSH (your IP)"
  type        = list(string)
  default     = ["0.0.0.0/0"]  # WARNING: Restrict to your IP in production!
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default = {
    Project     = "Flask EC2 App"
    ManagedBy   = "Terraform"
    Environment = "Development"
  }
}
