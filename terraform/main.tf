# TAG: AUTOMATION-INFRASTRUCTURE-TERRAFORM
# PURPOSE: Create dedicated EC2 instance for security scanning (Trivy + Gitleaks)
# SCOPE: EC2 + Security Group + SSH Key management
# SAFETY: Separate from Jenkins EC2, isolated security scanning environment

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Security Group for Scans EC2
resource "aws_security_group" "scans_sg" {
  name        = "lab-devops-scans-sg"
  description = "Security group for dedicated security scanning EC2"

  # SSH access from my IP
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip_cidr]
    description = "SSH access from local machine"
  }

  # Allow all outbound traffic (for downloading scan tools, databases)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name    = "lab-devops-scans-sg"
    Project = "secure-release-platform"
    Purpose = "security-scanning"
    Jalon   = "5b"
  }
}

# EC2 Instance for Security Scans
resource "aws_instance" "scans_ec2" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  vpc_security_group_ids = [aws_security_group.scans_sg.id]

  root_block_device {
    volume_size = 10
    volume_type = "gp3"
  }

  user_data = <<-EOF
    #!/bin/bash
    # Update system
    apt-get update
    apt-get upgrade -y

    # Install Docker
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    usermod -aG docker ubuntu

    # Pull security scanning images
    docker pull aquasec/trivy:latest
    docker pull zricethezav/gitleaks:latest

    # Create scan workspace
    mkdir -p /opt/security-scans
    chown ubuntu:ubuntu /opt/security-scans

    echo "Security scanning EC2 ready" > /var/log/bootstrap-complete.log
  EOF

  tags = {
    Name    = "lab-devops-scans-ec2"
    Project = "secure-release-platform"
    Purpose = "security-scanning"
    Jalon   = "5b"
    ManagedBy = "Terraform"
  }
}
