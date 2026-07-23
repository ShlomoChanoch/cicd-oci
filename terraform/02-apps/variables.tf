variable "region" {
  type    = string
  default = "us-ashburn-1"
}

variable "ocir_tenancy_namespace" {
  type        = string
  description = "Namespace/Tenancy do OCIR"
  sensitive   = true
}

variable "image_repository" {
  type        = string
  description = "Nome do repositório/imagem no OCIR"
  sensitive   = true
}