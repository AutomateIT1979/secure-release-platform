# TAG: AUTOMATION-INFRASTRUCTURE-TERRAFORM
# PURPOSE: Output values from Terraform deployment
# SCOPE: EC2 details for connection and usage
# SAFETY: Provides necessary information for SSH and integration

output "instance_id" {
  description = "ID of the security scanning EC2 instance"
  value       = aws_instance.scans_ec2.id
}

output "instance_public_ip" {
  description = "Public IP address of the security scanning EC2"
  value       = aws_instance.scans_ec2.public_ip
}

output "instance_private_ip" {
  description = "Private IP address of the security scanning EC2"
  value       = aws_instance.scans_ec2.private_ip
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.scans_sg.id
}

output "ssh_command" {
  description = "SSH command to connect to the instance"
  value       = "ssh -i ~/.ssh/lab-devops-key.pem ubuntu@${aws_instance.scans_ec2.public_ip}"
}
