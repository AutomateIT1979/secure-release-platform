# TAG: AUTOMATION-INFRASTRUCTURE-TERRAFORM
# PURPOSE: Variables for security scanning EC2 infrastructure
# SCOPE: Parameterizable configuration
# SAFETY: Sensitive values in terraform.tfvars (gitignored)

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "eu-west-3"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "ami_id" {
  description = "Ubuntu 22.04 LTS AMI ID for eu-west-3"
  type        = string
  # Ubuntu 22.04 LTS in eu-west-3 (verify latest)
  default     = "ami-04c332520bd9cedb4"
}

variable "key_name" {
  description = "SSH key pair name"
  type        = string
}

variable "my_ip_cidr" {
  description = "My IP address in CIDR format (e.g., 1.2.3.4/32)"
  type        = string
}
