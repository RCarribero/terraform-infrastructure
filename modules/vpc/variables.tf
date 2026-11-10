variable "name" {
  description = "Nombre de la VPC"
  type        = string
  default     = "main-vpc"
}

variable "cidr_block" {
  description = "Rango CIDR de la VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "Lista de Zonas de Disponibilidad"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "Lista de bloques CIDR para subredes publicas"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "Lista de bloques CIDR para subredes privadas"
  type        = list(string)
  default     = []
}

variable "enable_nat_gateway" {
  description = "Habilitar NAT Gateway para que las subredes privadas tengan salida a internet (genera coste en AWS)"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Etiquetas comunes para los recursos"
  type        = map(string)
  default     = {}
}
