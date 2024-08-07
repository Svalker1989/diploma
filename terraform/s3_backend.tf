terraform {
backend "s3" {
 endpoints = {
   s3 =  "https://storage.yandexcloud.net"
   }
 bucket = "str-bucket"
 region = "ru-central1"
 key = "terraform.tfstate"
 skip_region_validation = true
 skip_credentials_validation = true
 skip_requesting_account_id  = true # необходимая опция Terraform для версии 1.6.1 и старше.
 skip_s3_checksum            = true # необходимая опция при описании бэкенда для Terraform версии 1.6.3 и старше.
 //если требуются блокировка tfstate, то необходимо создать таблицу блокировок. Используется для совместной работы с одним tfstate.
 //dynamodb_endpoint = "https://docapi.serverless.yandexcloud.net/ru-central1/b1gl328j72hoingknj27/etn0td68gda20s6dpcbi"
 //dynamodb_table = "str-tfstate"
 }
}