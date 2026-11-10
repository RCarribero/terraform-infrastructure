output "alb_dns_name" {
  description = "Nombre DNS publico del Load Balancer (con HTTPS)"
  value       = "https://${aws_lb.this.dns_name}"
}

output "alb_arn" {
  description = "ARN del Load Balancer"
  value       = aws_lb.this.arn
}

output "target_group_arn" {
  description = "ARN del Target Group"
  value       = aws_lb_target_group.this.arn
}

output "alb_security_group_id" {
  description = "ID del Security Group del ALB"
  value       = aws_security_group.alb.id
}
