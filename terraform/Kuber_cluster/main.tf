resource "yandex_compute_instance" "master" {
  name        = "master"
  platform_id = "standard-v1"
  zone           = "ru-central1-a"
  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }
  boot_disk {
    initialize_params {
      size = 15
      image_id = "fd8vmcue7aajpmeo39kk"
    }
  }
  scheduling_policy {
    preemptible = true
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.subnet_1a.id
    nat       = true
  }

  metadata = {
      user-data          = data.template_file.cloudinit.rendered 
      serial-port-enable = 1
  }
}

resource "yandex_compute_instance" "worker-1" {
  name        = "worker-1"
  zone           = "ru-central1-b"
  platform_id = "standard-v1"
  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }
  boot_disk {
    initialize_params {
      size = 15
      image_id = "fd8vmcue7aajpmeo39kk"
    }
  }
  scheduling_policy {
    preemptible = true
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.subnet_1b.id
    nat       = true
  }

  metadata = {
      user-data          = data.template_file.cloudinit.rendered 
      serial-port-enable = 1
  }
}

resource "yandex_compute_instance" "worker-2" {
  name        = "worker-2"
  zone           = "ru-central1-b"
  platform_id = "standard-v1"
  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }
  boot_disk {
    initialize_params {
      size = 15
      image_id = "fd8vmcue7aajpmeo39kk"
    }
  }
  scheduling_policy {
    preemptible = true
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.subnet_1b.id
    nat       = true
  }

  metadata = {
      user-data          = data.template_file.cloudinit.rendered 
      serial-port-enable = 1
  }
}
data "template_file" "cloudinit" {
  template = file("./cloud-init.yml")

  vars = {
    username = "str"
    ssh_key = var.vms_ssh_key 
  }
}

# Output values

output "instance_masters_public_ips" {
  description = "Public IP addresses for master-nodes"
  value = yandex_compute_instance.master.network_interface.0.nat_ip_address
}

output "instance_group_masters_private_ips" {
  description = "Private IP addresses for master-nodes"
  value = yandex_compute_instance.master.network_interface.0.ip_address
}

output "instance_worker-1_public_ips" {
  description = "Public IP addresses for worder-nodes"
  value = yandex_compute_instance.worker-1.network_interface.0.nat_ip_address
}

output "instance_worker-1_private_ips" {
  description = "Private IP addresses for worker-nodes"
  value = yandex_compute_instance.worker-1.network_interface.0.ip_address
}

output "instance_worker-2_public_ips" {
  description = "Public IP addresses for worder-nodes"
  value = yandex_compute_instance.worker-2.network_interface.0.nat_ip_address
}

output "instance_worker-2_private_ips" {
  description = "Private IP addresses for worker-nodes"
  value = yandex_compute_instance.worker-2.network_interface.0.ip_address
}