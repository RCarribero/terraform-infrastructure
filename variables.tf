variable "aws_region" {
  description = "Region de AWS"
  type        = string
  default     = "eu-west-1"
}

variable "environment" {
  description = "Entorno de despliegue (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "instance_type" {
  description = "Tipo de instancia EC2"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Nombre del par de claves SSH en AWS"
  type        = string
  default     = "user1"
}

variable "enable_nat_gateway" {
  description = "Habilitar NAT Gateway (permite a las EC2 privadas descargar paquetes a traves de internet)"
  type        = bool
  default     = true
}
