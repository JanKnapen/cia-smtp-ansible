# General multi-host variables
variable "ansible_username" {
  type        = string
}

variable "ansible_password" {
  type        = string
  sensitive   = true
}

variable "root_public_key" {
  type = string
  sensitive = true
}

variable "root_private_key_name" {
  type = string
  sensitive = true
}

variable "proxmox_api_url" {
  type = string
  sensitive = true
}

variable "proxmox_api_token_id" {
  type = string
  sensitive = true
}

variable "proxmox_api_token_secret" {
  type = string
  sensitive = true
}


## Hosts
variable "lxcs2404" {
  description = "24.04 LXC container definitions"

  type = map(object({
    target_node       = string
    target_pool       = string
    target_storage    = string
    unprivileged      = bool
    hostname          = string
    vm_id             = number
    servicename       = string
    cpu_cores         = number
    ram               = number
    swap              = number
    boot_disk_size    = number
    network_interface = string
    static_ip         = string
    gateway_ip        = string
    onboot            = bool
    startup           = string
    root_password     = string
  }))
}
