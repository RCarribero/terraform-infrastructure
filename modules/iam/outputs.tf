output "developer_role_arn" {
  description = "ARN del rol que deben asumir los desarrolladores (para no usar la cuenta root)"
  value       = aws_iam_role.infra_developer.arn
}

output "developer_role_name" {
  description = "Nombre del rol de infraestructura para desarrolladores"
  value       = aws_iam_role.infra_developer.name
}

output "developers_group_name" {
  description = "Nombre del grupo IAM de desarrolladores"
  value       = aws_iam_group.developers.name
}

output "developer_users" {
  description = "Lista de desarrolladores dados de alta"
  value       = [for u in aws_iam_user.dev_users : u.name]
}

