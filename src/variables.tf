variable "cloud_id" {}
variable "folder_id" {}

variable "nat_image_id" {
  default = "fd80mrhj8fl2oe87o4e1"
}

variable "test_vm_image_id" {
  default = "fd8a0c4kq12c44qr6llq"
}

variable "zone-public" {
  type        = string
  default     = "ru-central1-a"
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}

variable "zone-private" {
  type        = string
  default     = "ru-central1-b"
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}

variable "metadata" {
  type        = map(string)
  description = "Metadata VM"
}

variable "preemptible" {
  type        = bool
  default     = true
  description = "Whether the VM is preemptible."
}
