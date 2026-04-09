# securebank-infrastructure
SecureBank Cloud Infrastructure Project

# SecureBank Cloud Infrastructure

## Project Overview
This repository contains the complete infrastructure 
code for SecureBank's cloud environment.

## Author
- Name: Bryan
- GitHub: bryanngu

## Project Structure
```
securebank-infrastructure/
├── bash-scripts/     → automation scripts
├── terraform/        → infrastructure as code
├── security/         → security configurations
└── docs/             → documentation and cheatsheets
```

## Infrastructure Components

### Bash Scripts
- bank-health-checks.sh  → daily server health report
- auto-recovery.sh       → automatic service recovery
- security-audit.sh      → daily security audit
- conditions.sh          → service health checker
- user-input.sh          → interactive server manager

### Terraform
- main.tf          → main infrastructure configuration
- variables.tf     → configurable variables
- provisioner.tf   → server setup automation

## Technologies Used
- Ubuntu 22.04 LTS
- Nginx Web Server
- Terraform v1.x
- UFW Firewall
- Fail2ban
- Git

## How to Use

### Run Health Check
```bash
bash bash-scripts/bank-health-checks.sh
```

### Deploy Infrastructure
```bash
cd terraform
terraform init
terraform plan
terraform apply
```

## Security Measures
- SSH hardened (port 2222, key auth only)
- UFW firewall configured
- Fail2ban installed
- Nginx version hidden
- Root login disabled

## Changelog

### Version 2.0 - Provisioner Fix
- Added DEBIAN_FRONTEND=noninteractive to prevent apt timeouts
- Added Phase 4 to explicitly start and enable services
- Added Phase 5 for verification of all services
- Fixed fail2ban not starting after installation
