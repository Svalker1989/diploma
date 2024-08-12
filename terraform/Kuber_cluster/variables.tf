###cloud vars
variable "token" {
  type        = string
  description = "OAuth-token; https://cloud.yandex.ru/docs/iam/concepts/authorization/oauth-token"
}

variable "cloud_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/cloud/get-id"
}

variable "folder_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id"
}

variable "default_zone" {
  type        = string
  default     = "ru-central1-a"
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}

variable "vpc_name" {
  type        = string
  default     = "netology"
  description = "VPC network&subnet name"
}

variable "subnet_a_cidr" {
  type        = list(string)
  default     = ["10.0.1.0/24"]
  description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
}
variable "subnet_b_cidr" {
  type        = list(string)
  default     = ["10.0.2.0/24"]
  description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
}
variable "subnet_c_cidr" {
  type        = list(string)
  default     = ["10.0.3.0/24"]
  description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
}

variable "subnet_name_1a" {
  type        = string
  default     = "subnet-1a"
  description = "VPC network&subnet name"
}

variable "subnet_name_1b" {
  type        = string
  default     = "subnet-1b"
  description = "VPC network&subnet name"
}

variable "subnet_name_1c" {
  type        = string
  default     = "subnet-1c"
  description = "VPC network&subnet name"
}

variable "vms_ssh_key" {
  type        = string
  description = "ssh-key"
}
###ssh vars

/*variable "vms_ssh_public_root_key" {
  type        = string
  description = "user ssh public key"
}*/