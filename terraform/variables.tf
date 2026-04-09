#SecureBank Infrastructure Variables

variable "bank_name" {
  description = "Name of the bank"
  type        = string
  default     = "SecureBank"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "development"
}

variable "server_ip" {
  description = "IP address of lab server"
  type        = string
  default     ="192.168.0.178"
}

variable "ssh_port" {
  description = "SSH port for lab server"
  type        = number
  default     = 2222
}

variable "admin_user"  {
  description = "Admin user on server"
  type        =  string
  default = "lab-server"
}
