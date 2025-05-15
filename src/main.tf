resource "yandex_vpc_network" "dnd-vpc" {
  name = local.network_name
}

resource "yandex_vpc_subnet" "public" {
  name           = local.subnet_name1
  zone           = var.zone-public
  network_id     = yandex_vpc_network.dnd-vpc.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

resource "yandex_vpc_subnet" "private" {
  name           = local.subnet_name2
  zone           = var.zone-private
  network_id     = yandex_vpc_network.dnd-vpc.id
  v4_cidr_blocks = ["192.168.20.0/24"]
  route_table_id = yandex_vpc_route_table.nat-instance-route.id
}

resource "yandex_vpc_security_group" "nat-instance-sg" {
  name       = local.sg_nat_name
  network_id = yandex_vpc_network.dnd-vpc.id

  egress {
    protocol       = "ANY"
    description    = "any"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol       = "TCP"
    description    = "ssh"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }

  ingress {
    protocol       = "TCP"
    description    = "ext-http"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }

  ingress {
    protocol       = "TCP"
    description    = "ext-https"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 443
  }

  ingress {
    protocol          = "ICMP"
    description       = "Allow ping"
    v4_cidr_blocks    = ["0.0.0.0/0"]
  }
}

resource "yandex_compute_instance" "nat-instance" {
  name        = local.vm_nat_name
  platform_id = "standard-v3"
  zone        = var.zone-public

  resources {
    core_fraction = 20
    cores         = 2
    memory        = 2
  }

  boot_disk {
    initialize_params {
      image_id = var.nat_image_id
      size = 20
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.public.id
    security_group_ids = [yandex_vpc_security_group.nat-instance-sg.id]
    ip_address = "192.168.10.254"
    nat                = true
  }

  scheduling_policy {
    preemptible = var.preemptible
  }

  metadata = var.metadata
}

resource "yandex_vpc_route_table" "nat-instance-route" {
  name       = "nat-instance-route"
  network_id = yandex_vpc_network.dnd-vpc.id
  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = yandex_compute_instance.nat-instance.network_interface.0.ip_address
  }
}

resource "yandex_compute_instance" "test-vm" {
  name        = local.vm_test_name
  platform_id = "standard-v3"
  zone        = var.zone-private

  resources {
    core_fraction = 20
    cores         = 2
    memory        = 2
  }

  boot_disk {
    initialize_params {
      image_id = var.test_vm_image_id
      size = 20
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.private.id
    security_group_ids = [yandex_vpc_security_group.nat-instance-sg.id]
  }

  scheduling_policy {
    preemptible = var.preemptible
  }

  metadata = var.metadata
}