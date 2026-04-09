# SecureBank Infrastructure
# Main Terraform Configuration

terraform {
  required_version = ">= 1.0"

  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}

# Local variables for SecureBank
locals {
  server_name  = "${var.bank_name}-${var.environment}-server"
  ssh_address  = "${var.server_ip}:${var.ssh_port}"
}

# Output information
output "bank_name" {
  description = "Name of the bank"
  value       = var.bank_name
}

output "environment" {
  description = "Current environment"
  value       = var.environment
}

output "server_name" {
  description = "Full server name"
  value       = local.server_name
}

output "ssh_connection" {
  description = "SSH connection details"
  value       = "ssh -p ${var.ssh_port} ${var.admin_user}@${var.server_ip}"
}



