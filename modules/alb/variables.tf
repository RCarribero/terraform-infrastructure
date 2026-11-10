variable "name" {
  description = "Nombre para el Load Balancer y sus recursos asociados"
  type        = string
  default     = "app-alb"
}

variable "vpc_id" {
  description = "ID de la VPC donde se desplegara el ALB"
  type        = string
}

variable "public_subnets" {
  description = "Lista de IDs de subredes publicas (al menos 2 AZs diferentes)"
  type        = list(string)
}

variable "tags" {
  description = "Etiquetas comunes para los recursos"
  type        = map(string)
  default     = {}
}

