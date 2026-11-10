variable "name" {
  description = "Prefijo para los nombres de los recursos IAM"
  type        = string
  default     = "app"
}

variable "developer_users" {
  description = "Lista de nombres de usuario para los desarrolladores"
  type        = list(string)
  default     = ["dev-lead", "dev-engineer"]
}

variable "tags" {
  description = "Etiquetas comunes para los recursos IAM"
  type        = map(string)
  default     = {}
}

