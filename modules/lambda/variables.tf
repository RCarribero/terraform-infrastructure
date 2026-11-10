variable "name" {
  description = "Nombre o prefijo para la funcion Lambda"
  type        = string
  default     = "app-lambda"
}

variable "tags" {
  description = "Etiquetas comunes"
  type        = map(string)
  default     = {}
}
