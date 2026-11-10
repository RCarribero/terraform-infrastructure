variable "aws_region" {
  description = "Region de AWS"
  type        = string
  default     = "eu-west-1"
}

variable "environment" {
  description = "Entorno de despliegue"
  type        = string
  default     = "prod"
}

variable "instance_type" {
  description = "Tipo de instancia EC2"
  type        = string
  default     = "t3.small"
}

variable "key_name" {
  description = "Nombre del par de claves SSH en AWS"
  type        = string
  default     = "user1"
}

variable "enable_nat_gateway" {
  description = "Habilitar NAT Gateway en produccion"
  type        = bool
  default     = true
}

