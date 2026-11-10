variable "aws_region" {
  description = "Region de AWS"
  type        = string
  default     = "eu-west-1"
}

variable "environment" {
  description = "Entorno de despliegue"
  type        = string
  default     = "dev"
}

variable "instance_type" {
  description = "Tipo de instancia EC2"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Nombre del par de claves SSH en AWS (opcional)"
  type        = string
  default     = "user1"
}

variable "enable_nat_gateway" {
  description = "Habilitar NAT Gateway (falso en dev para ahorrar costes)"
  type        = bool
  default     = false
}

