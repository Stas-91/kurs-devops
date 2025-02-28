variable "yandex_cloud_token" {
  type        = string
  description = "Token for accessing Yandex Cloud"
}

variable "elastic_passwd" {}

variable "grafana_passwd" {}

# Переменные для создания ВМ
variable "cores" {
  description = "Number of CPU cores"
  type        = number
  default     = 2
}

variable "memory" {
  description = "Amount of memory (in GB)"
  type        = number
  default     = 2
}

variable "image_id" {
  description = "ID of the image to use for the VM"
  type        = string
  default     = "fd8s3qh62qn5sqoemni6"
}

# Переменная для управления средой
variable "is_production" {
  description = "Flag to determine if the environment is production"
  default     = false
}