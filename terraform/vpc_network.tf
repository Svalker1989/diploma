resource "yandex_vpc_network" "netology" {
  name = var.vpc_name
}
resource "yandex_vpc_subnet" "subnet_1a" {
  name           = var.subnet_name_1a
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.netology.id
  v4_cidr_blocks = var.subnet_a_cidr
}
resource "yandex_vpc_subnet" "subnet_1b" {
  name           = var.subnet_name_1b
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.netology.id
  v4_cidr_blocks = var.subnet_b_cidr
}
resource "yandex_vpc_subnet" "subnet_1c" {
  name           = var.subnet_name_1c
  zone           = "ru-central1-c"
  network_id     = yandex_vpc_network.netology.id
  v4_cidr_blocks = var.subnet_c_cidr
}