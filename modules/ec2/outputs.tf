output "launch_template_id" {
  description = "ID del Launch Template de EC2"
  value       = aws_launch_template.this.id
}

output "launch_template_arn" {
  description = "ARN del Launch Template de EC2"
  value       = aws_launch_template.this.arn
}

output "security_group_id" {
  description = "ID del Security Group de EC2"
  value       = aws_security_group.this.id
}

output "iam_role_arn" {
  description = "ARN del rol IAM para SSM"
  value       = aws_iam_role.ssm.arn
}
