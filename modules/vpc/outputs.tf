output "vpc_id" {
  description = "ID de la VPC creada"
  value       = aws_vpc.this.id
}

output "public_subnets" {
  description = "Lista de IDs de las subredes publicas"
  value       = aws_subnet.public[*].id
}

output "private_subnets" {
  description = "Lista de IDs de las subredes privadas"
  value       = aws_subnet.private[*].id
}

output "internet_gateway_id" {
  description = "ID del Internet Gateway"
  value       = aws_internet_gateway.this.id
}

output "nat_gateway_id" {
  description = "ID del NAT Gateway (si esta habilitado)"
  value       = var.enable_nat_gateway ? aws_nat_gateway.this[0].id : null
}
