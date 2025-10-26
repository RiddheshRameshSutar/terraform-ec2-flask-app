aws_region    = "ap-south-1"
project_name  = "flask-ec2-app"
environment   = "dev"
instance_type = "t3.micro"
key_name      = "linux_key"
private_key_path = "~/.ssh/rrskey"      # Path to YOUR private key

# IMPORTANT: Restrict SSH access to your IP for security
# Get your IP: curl ifconfig.me
allowed_ssh_cidr = ["0.0.0.0/0"]  # Change to ["YOUR_IP/32"] in production

tags = {
  Project     = "Flask EC2 Application"
  ManagedBy   = "Terraform"
  Environment = "Development"
  Owner       = "Riddhesh Ramesh Sutar"
}
