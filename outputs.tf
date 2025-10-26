output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.web.id
}

output "instance_public_ip" {
  description = "Public IP address (Elastic IP)"
  value       = aws_eip.web.public_ip
}

output "instance_private_ip" {
  description = "Private IP address"
  value       = aws_instance.web.private_ip
}

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "security_group_id" {
  description = "Security group ID"
  value       = aws_security_group.web.id
}

output "website_url" {
  description = "Flask application URL"
  value       = "http://${aws_eip.web.public_ip}"
}

output "ssh_command" {
  description = "SSH command to connect to instance"
  value       = "ssh -i ${var.private_key_path} ec2-user@${aws_eip.web.public_ip}"
}

#output "private_key_path" {
 #description = "Path to private SSH key"
  #value       = "${path.module}/${var.key_name}.pem"
  #sensitive   = true
#}

output "deployment_info" {
  description = "Deployment information"
  value = {
    region           = var.aws_region
    environment      = var.environment
    instance_type    = var.instance_type
    ami_id           = aws_instance.web.ami
    availability_zone = aws_instance.web.availability_zone
  }
}
