variable "tenancy_ocid" {
  type        = string
  description = "OCID da Tenancy do OCI"
}

variable "user_ocid" {
  type        = string
  description = "OCID do usuário no OCI"
}

variable "fingerprint" {
  type        = string
  description = "Fingerprint da chave de API"
}

variable "private_key_path" {
  type        = string
  description = "Caminho local para o arquivo .pem da chave privada"
}

variable "region" {
  type        = string
  default     = "us-ashburn-1"
  description = "Região da OCI"
}

variable "compartment_ocid" {
  type        = string
  description = "OCID do compartimento onde os recursos serão criados"
}

