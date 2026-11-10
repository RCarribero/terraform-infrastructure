output "alb_dns_name" {
  description = "URL publica del Elastic Load Balancer (Abre esta URL en tu navegador)"
  value       = module.alb.alb_dns_name
}

output "lambda_function_url" {
  description = "URL publica directa de la funcion AWS Lambda de prueba"
  value       = module.lambda.lambda_function_url
}

output "vpc_id" {
  description = "ID de la VPC creada"
  value       = module.vpc.vpc_id
}

output "public_subnets" {
  description = "Subredes publicas (donde reside el ALB)"
  value       = module.vpc.public_subnets
}

output "private_subnets" {
  description = "Subredes privadas (donde residen las EC2)"
  value       = module.vpc.private_subnets
}

output "asg_name" {
  description = "Nombre del Auto Scaling Group"
  value       = module.autoscaling.asg_name
}

output "developer_role_arn" {
  description = "ARN del Rol IAM que deben asumir los desarrolladores (para no usar la cuenta root)"
  value       = module.iam.developer_role_arn
}

output "developers_group" {
  description = "Nombre del grupo IAM de desarrollo"
  value       = module.iam.developers_group_name
}

output "developer_users" {
  description = "Usuarios creados para el equipo de desarrollo"
  value       = module.iam.developer_users
}
