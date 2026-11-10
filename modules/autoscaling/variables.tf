variable "name" {
  description = "Nombre base para el Auto Scaling Group"
  type        = string
  default     = "app"
}

variable "subnet_ids" {
  description = "Lista de IDs de subredes donde se desplegaran las instancias"
  type        = list(string)
}

variable "launch_template_id" {
  description = "ID del Launch Template creado por el modulo EC2"
  type        = string
}

variable "target_group_arns" {
  description = "Lista de ARNs de Target Groups del ALB"
  type        = list(string)
  default     = []
}

variable "min_size" {
  description = "Numero minimo de instancias en el ASG"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Numero maximo de instancias en el ASG"
  type        = number
  default     = 3
}

variable "desired_capacity" {
  description = "Numero deseado de instancias en el ASG"
  type        = number
  default     = 2
}

variable "tags" {
  description = "Etiquetas comunes"
  type        = map(string)
  default     = {}
}
