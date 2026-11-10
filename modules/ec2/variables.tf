variable "name" {
  description = "Nombre base para los recursos de computo EC2"
  type        = string
  default     = "app-ec2"
}

variable "vpc_id" {
  description = "ID de la VPC"
  type        = string
}

variable "ami_id" {
  description = "ID de la AMI a utilizar"
  type        = string
}

variable "instance_type" {
  description = "Tipo de instancia EC2"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Nombre del Key Pair SSH (opcional, SSM no lo requiere)"
  type        = string
  default     = null
}

variable "alb_security_group_id" {
  description = "ID del Security Group del ALB para autorizar trafico HTTP"
  type        = string
}

variable "associate_public_ip_address" {
  description = "Asignar IP publica a las instancias (false si estan en subredes privadas)"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Etiquetas comunes"
  type        = map(string)
  default     = {}
}
