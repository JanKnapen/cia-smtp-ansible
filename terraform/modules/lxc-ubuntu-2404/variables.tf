variable "hostname" {
  description = "The hostname of the LXC container"
  type        = string
  default     = "lxc-ubuntu-server"
}

variable "vm_id" {
  description = "The ID of the VM of the container"
  type        = number
  default     = null
}

variable "servicename" {
  description = "The name of the service that will be hosted in the container"
  type        = string
  default     = "servicename"
}

variable "unprivileged" {
  description = "If the LXC container should be unprivileged"
  type        = bool
  default     = true
}

variable "cpu_cores" {
  description = "Number of CPU cores"
  type        = number
  default     = 4
}

variable "ram" {
  description = "Amount of RAM in MB"
  type        = number
  default     = 8192
}

variable "swap" {
  description = "Amount of SWAP in MB"
  type        = number
  default     = 4096
}

variable "tags" {
  description = "Tags"
  type        = string
  default     = "ubuntu-24.04"
}

variable "onboot" {
  description = "If the container should start on boot"
  type        = bool
  default     = false  
}

variable "startup" {
  description = "Start/shutdown order, startup delay & shutdown timeout in format 'order=int,up=sec,down=sec'"
  type        = string
  default     = ""
}

variable "boot_disk_size" {
  description = "Size of the boot disk in GB"
  type        = string
  default     = 16
}

variable "network_interface" {
  description = "Network interface to connect the container"
  type        = string
  default     = "vmbr0"
}

variable "static_ip" {
  description = "Static IPv4 address for the container"
  type        = string
  default     = ""
}

variable "gateway_ip" {
  description = "Gateway for the container"
  type        = string
  default     = ""
}

variable "target_node" {
  description = "The target node to create the container on"
  type        = string
}

variable "target_pool" {
  description = "The target pool to create the container on"
  type        = string
  default     = ""
}

variable "target_storage" {
  description = "The target storage to create the container on"
  type        = string
  default     = "local-lvm"
}

variable "root_password" {
  description = "Password of the LXC container root user"
  type        = string
  sensitive   = true
}


# Host and proxmox access variables
variable "ansible_username" {
  description = "The username of the LXC container ansible user"
  type        = string
}

variable "ansible_password" {
  description = "Password of the LXC container ansible user"
  type        = string
  sensitive   = true
}

variable "root_public_key" {
  description = "Public key of an administrator to login"
  type        = string
  sensitive   = true
}

variable "root_private_key_name" {
  description = "The name of the private key to connect to the host with"
  type        = string
  sensitive   = true
}

variable "proxmox_api_url" {
  type        = string
  description = "The Proxmox API URL"
  sensitive   = true
}

variable "proxmox_api_token_id" {
  type        = string
  description = "The Proxmox API token ID"
  sensitive   = true
}

variable "proxmox_api_token_secret" {
  type        = string
  description = "The Proxmox API token secret"
  sensitive   = true
}