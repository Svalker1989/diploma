// Создание бакета с использованием ключа
resource "yandex_storage_bucket" "str-bucket" {
  access_key            = var.key_id
  secret_key            = var.secret
  bucket                = "str-bucket"
  max_size              = "1048576"
  default_storage_class = "STANDARD"
}