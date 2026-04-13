# SecureBank DevOps Handbook
## Personal Reference Guide
**Author:** Bryan Ngu  
**GitHub:** bryanngu  
**Last Updated:** April 2026

---

## TABLE OF CONTENTS
1. Lab Environment Setup
2. Linux Fundamentals
3. Security Hardening
4. Bash Scripting
5. Terraform
6. Docker (coming)
7. Kubernetes (coming)
8. Ansible (coming)
9. Quick Reference Commands

---

## 1. LAB ENVIRONMENT SETUP

### Overview
```
LAPTOP (16GB RAM)          DESKTOP (8GB RAM)
── Primary workstation     ── Home server
── SSH client              ── VirtualBox VMs
── Terraform               ── Lab environment
── VS Code                 ── Always on server
── Git/GitHub
```

### 1.1 VirtualBox VM Creation
```
Steps:
1. Open VirtualBox
2. Click "New"
3. Fill in:
   Name:    server-name
   Type:    Linux
   Version: Ubuntu 22.04 LTS (64-bit)
   RAM:     2048MB minimum
   Storage: 20GB minimum

4. Settings → Network → Bridged Adapter
5. Settings → Storage → Attach Ubuntu ISO
6. Start VM and install Ubuntu
```

### 1.2 Ubuntu Server Installation Settings
```
Profile Setup:
   Your name:   yourname
   Server name: server-name
   Username:    yourusername
   Password:    (strong password)

Important Selections:
   ✅ Install OpenSSH Server
   ❌ Skip Ubuntu Pro
   ❌ Skip all Snaps
```

### 1.3 SSH Configuration

#### Find Server IP
```bash
ip addr show
# Look for inet 192.168.0.XXX
```

#### Generate SSH Key on Laptop
```bash
ssh-keygen -t ed25519 -C "youremail@example.com"
# Press Enter for all prompts
```

#### Copy Key to Server
```bash
ssh-copy-id -p PORT username@SERVER_IP
# Enter password once - last time needed
```

#### Configure SSH Config File
```bash
nano ~/.ssh/config
```
```
# Add this entry:
Host server-nickname
    HostName SERVER_IP
    User USERNAME
    Port PORT
```

#### Test Connection
```bash
ssh server-nickname
```

### 1.4 VS Code Remote Connection
```
1. Install "Remote - SSH" extension
2. Press Ctrl + Shift + P
3. Type: Remote-SSH: Connect to Host
4. Select server-nickname
5. Bottom left shows: SSH: server-nickname
```

---

## 2. LINUX FUNDAMENTALS

### 2.1 File System Structure
```
/           → root of entire file system
/home       → user home folders
/etc        → configuration files
/var/log    → log files
/var/www    → web server files
/tmp        → temporary files
/usr        → installed programs
/bin        → essential commands
```

### 2.2 Essential Commands
```bash
# Navigation
pwd                    → show current location
cd /path               → change directory
cd ~                   → go to home folder
cd ..                  → go up one level
ls -la                 → list all files with details

# Files
touch filename         → create empty file
nano filename          → open text editor
cat filename           → display file contents
cp source dest         → copy file
mv source dest         → move/rename file
rm filename            → delete file
rm -rf folder          → delete folder

# Search
grep "text" file       → search for text in file
grep -r "text" folder  → search recursively
find / -name "file"    → find file by name

# System Info
whoami                 → current user
hostname               → server name
uname -a               → system information
uptime                 → server uptime
df -h                  → disk space
free -h                → memory usage
top                    → running processes
ps aux                 → all processes
ps aux | grep NAME     → find specific process
```

### 2.3 File Permissions
```
Permission Format: -rwxrwxrwx
                    ||||||||| 
                    |||------  others
                    |||
                    ------  group
                    ---
                    owner

Values:
r = read    = 4
w = write   = 2
x = execute = 1

Common chmod values:
chmod 600 file    → owner read/write only (SSH keys)
chmod 644 file    → owner read/write, others read
chmod 755 file    → owner all, others read/execute
chmod +x file     → add execute permission
```

### 2.4 User Management
```bash
sudo adduser USERNAME        → create user
sudo deluser --remove-home USERNAME → delete user
sudo usermod -aG sudo USERNAME → add to sudo group
groups USERNAME              → show user groups
id                           → show current user info
```

### 2.5 Services Management
```bash
sudo systemctl start SERVICE    → start service
sudo systemctl stop SERVICE     → stop service
sudo systemctl restart SERVICE  → restart service
sudo systemctl enable SERVICE   → start on boot
sudo systemctl disable SERVICE  → don't start on boot
sudo systemctl status SERVICE   → check status
sudo systemctl is-active SERVICE → true/false check
systemctl list-units --type=service → list all services
```

---

## 3. SECURITY HARDENING

### 3.1 SSH Hardening

#### Config File Location
```
/etc/ssh/sshd_config
/etc/ssh/sshd_config.d/50-cloud-init.conf
```

#### Changes to Make
```bash
sudo nano /etc/ssh/sshd_config
```
```
# Find and change these lines:
Port 2222                    # change from 22
PermitRootLogin no           # disable root login
PasswordAuthentication no    # keys only
```
```bash
# Also update override file:
sudo nano /etc/ssh/sshd_config.d/50-cloud-init.conf
```
```
PasswordAuthentication no
```

#### Verify Changes
```bash
sudo sshd -T | grep -E "permitrootlogin|passwordauthentication|port"
```

#### Restart SSH
```bash
sudo systemctl restart sshd
```

### 3.2 UFW Firewall

#### Setup Commands
```bash
sudo ufw default deny incoming    → block all incoming
sudo ufw default allow outgoing   → allow all outgoing
sudo ufw allow PORT/tcp           → open specific port
sudo ufw enable                   → turn on firewall
sudo ufw status verbose           → check rules
sudo ufw delete allow PORT/tcp    → remove rule
```

#### Standard Bank Server Rules
```bash
sudo ufw allow 2222/tcp    → SSH (custom port)
sudo ufw allow 80/tcp      → HTTP
sudo ufw allow 443/tcp     → HTTPS
sudo ufw enable
```

### 3.3 Nginx Hardening

#### Hide Version Number
```bash
sudo nano /etc/nginx/nginx.conf
```
```
# Inside http { } block add:
server_tokens off;
```

#### Apply Changes
```bash
sudo nginx -t              → test configuration
sudo systemctl reload nginx → apply changes
```

### 3.4 Security Tools

#### Nmap - Network Scanner
```bash
nmap IP                          → basic scan
nmap -sV -sC IP                  → version scan
nmap -p- IP                      → all ports
nmap -p- -T4 IP                  → fast all ports
nmap -p PORT IP                  → specific port
```

#### Hydra - Password Testing
```bash
hydra -l USER -P WORDLIST ssh://IP -t 4
hydra -l USER -P WORDLIST ssh://IP -t 4 -s PORT
```

#### Gobuster - Web Enumeration
```bash
gobuster dir -u http://IP -w WORDLIST
```

#### Common Wordlists Location
```
/snap/seclists/current/Passwords/Common-Credentials/
/snap/seclists/current/Discovery/Web-Content/
```

### 3.5 Log Analysis
```bash
sudo tail -f /var/log/auth.log              → watch logins
sudo grep "Failed password" /var/log/auth.log → failed attempts
sudo cat /var/log/fail2ban.log              → fail2ban activity
sudo journalctl -u nginx                    → nginx logs
```

---

## 4. BASH SCRIPTING

### 4.1 Script Template
```bash
#!/bin/bash
# Script Name: script-name.sh
# Purpose: what this script does
# Author: Bryan
# Date: 2026

# Variables
VARIABLE="value"

# Functions
function_name() {
    echo "$1"
}

# Main Logic
echo "Starting..."
```

### 4.2 Key Concepts
```bash
# Variables
NAME="value"              → create variable
$NAME                     → use variable
$(command)                → store command output
$((5 + 3))               → math operations

# User Input
read VARIABLE             → wait for input

# Conditions
if [ $VAR -gt 10 ]; then  → if greater than 10
    commands
elif [ $VAR -eq 5 ]; then → else if equal to 5
    commands
else                      → otherwise
    commands
fi

# Loops
for ITEM in "${ARRAY[@]}"; do
    echo $ITEM
done

while [ condition ]; do
    commands
done

# Functions
my_function() {
    echo "$1"    → $1 = first argument
}
my_function "hello"

# Arrays
ARRAY=("item1" "item2" "item3")
${ARRAY[@]}    → all items
${#ARRAY[@]}   → count of items
```

### 4.3 Comparison Operators
```bash
# Numbers
-eq   → equal to
-ne   → not equal to
-gt   → greater than
-lt   → less than
-ge   → greater than or equal
-le   → less than or equal

# Strings
=     → equal
!=    → not equal
-z    → empty string
-n    → not empty string

# Files
-f    → is a file
-d    → is a directory
-e    → exists
```

### 4.4 SecureBank Scripts Location
```
~/lab-projects/scripting/
├── bank-health-checks.sh  → server health report
├── auto-recovery.sh       → service auto recovery
├── security-audit.sh      → security audit report
└── cheatsheet.txt         → quick reference
```

### 4.5 Cron Job Scheduling
```bash
sudo crontab -e    → edit schedule
sudo crontab -l    → list schedules

# Format:
MIN HOUR DAY MONTH WEEKDAY COMMAND

# Examples:
*/5 * * * *   /path/script.sh    → every 5 minutes
0 * * * *     /path/script.sh    → every hour
0 0 * * *     /path/script.sh    → every midnight
0 9 * * 1     /path/script.sh    → Monday 9am
0 0 * * 5     /path/script.sh    → Friday midnight
0 8 * * 1-5   /path/script.sh    → weekdays 8am

# Days: 0=Sun 1=Mon 2=Tue 3=Wed 4=Thu 5=Fri 6=Sat
```

---

## 5. TERRAFORM

### 5.1 Overview
```
Terraform provisions infrastructure using code.
Write once → deploy anywhere → identical every time.

WORKFLOW:
terraform init     → download providers (once per project)
terraform plan     → preview changes (always before apply)
terraform apply    → create infrastructure
terraform destroy  → remove infrastructure
terraform output   → show output values
terraform taint    → force resource recreation
```

### 5.2 File Structure
```
project/
├── main.tf          → main configuration
├── variables.tf     → input variables
├── outputs.tf       → output values
├── providers.tf     → provider config
└── terraform.tfvars → variable values
```

### 5.3 File Templates

#### main.tf
```hcl
terraform {
  required_version = ">= 1.0"
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}

locals {
  server_name = "${var.bank_name}-${var.environment}"
}

output "server_name" {
  value = local.server_name
}
```

#### variables.tf
```hcl
variable "server_ip" {
  description = "Server IP address"
  type        = string
  default     = "192.168.0.178"
}

variable "ssh_port" {
  description = "SSH port number"
  type        = number
  default     = 2222
}

variable "admin_user" {
  description = "Admin username"
  type        = string
  default     = "lab-server"
}
```

#### provisioner.tf
```hcl
resource "null_resource" "server_setup" {
  connection {
    type        = "ssh"
    host        = var.server_ip
    user        = var.admin_user
    port        = var.ssh_port
    private_key = file("~/.ssh/id_ed25519")
  }

  provisioner "remote-exec" {
    inline = [
      "sudo systemctl stop unattended-upgrades",
      "sudo systemctl disable unattended-upgrades",
      "sudo rm -f /var/lib/dpkg/lock-frontend",
      "sudo DEBIAN_FRONTEND=noninteractive apt update -y",
      "sudo DEBIAN_FRONTEND=noninteractive apt install -y nginx fail2ban ufw",
      "sudo ufw default deny incoming",
      "sudo ufw default allow outgoing",
      "sudo ufw allow ${var.ssh_port}/tcp",
      "sudo ufw allow 80/tcp",
      "sudo ufw --force enable",
      "sudo systemctl start nginx",
      "sudo systemctl enable nginx",
      "sudo systemctl start fail2ban",
      "sudo systemctl enable fail2ban"
    ]
  }
}
```

---

## 6. GIT AND GITHUB

### 6.1 Initial Setup
```bash
git config --global user.name "Bryan"
git config --global user.email "email@example.com"
```

### 6.2 Daily Workflow
```bash
git status              → see changed files
git add .               → stage all changes
git add filename        → stage specific file
git commit -m "message" → save snapshot
git push origin main    → upload to GitHub
git pull origin main    → download from GitHub
git log                 → see commit history
git diff                → see what changed
```

### 6.3 SSH Key for GitHub
```bash
ssh-keygen -t ed25519 -C "email@example.com"
cat ~/.ssh/id_ed25519.pub    → copy this to GitHub
ssh -T git@github.com        → test connection
```

### 6.4 Repository Setup
```bash
git clone git@github.com:USERNAME/REPO.git
cd REPO
git add .
git commit -m "Initial commit"
git push origin main
```

---

## 7. QUICK REFERENCE

### Most Used Commands Daily
```bash
ssh SERVER           → connect to server
sudo systemctl status SERVICE → check service
sudo ufw status      → check firewall
df -h                → check disk space
free -h              → check memory
ps aux | grep NAME   → find process
tail -f /var/log/auth.log → watch logs
git add . && git commit -m "msg" && git push → save to GitHub
terraform plan       → preview infrastructure
terraform apply      → deploy infrastructure
```

### Common File Locations
```
SSH Config:      ~/.ssh/config
SSH Keys:        ~/.ssh/id_ed25519
Nginx Config:    /etc/nginx/nginx.conf
SSH Server:      /etc/ssh/sshd_config
UFW Rules:       /etc/ufw/
Cron Jobs:       sudo crontab -e
Auth Logs:       /var/log/auth.log
Fail2ban Log:    /var/log/fail2ban.log
Terraform:       ~/lab-projects/terraform/
Scripts:         ~/lab-projects/scripting/
GitHub Repo:     ~/securebank-infrastructure/
```

### Port Reference
```
22    → SSH (default)
2222  → SSH (our hardened port)
80    → HTTP
443   → HTTPS
3306  → MySQL
5432  → PostgreSQL
6379  → Redis
8080  → Alternative HTTP
```

---

📝 **HANDBOOK UPDATE**
```
DOCKERFILE INSTRUCTIONS:
FROM IMAGE     → base image to build on
LABEL key=val  → metadata
RUN command    → run during build
COPY src dest  → copy files into image
EXPOSE port    → document port usage
CMD ["cmd"]    → run when container starts
ENV KEY=value  → set environment variable
WORKDIR /path  → set working directory


## 6. DOCKER

### 6.1 Overview
```
Docker packages applications with everything
they need to run identically anywhere.

IMAGE     → blueprint/template (read only)
CONTAINER → running instance of image
DOCKERFILE → instructions to build image
```

### 6.2 Installation on Ubuntu
```bash
# Add Docker GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Add Docker repository
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list

# Install Docker
sudo apt update && sudo apt install -y docker-ce docker-ce-cli containerd.io

# Add user to docker group
sudo usermod -aG docker USERNAME
newgrp docker
```

### 6.3 Dockerfile Template
```dockerfile
FROM nginx:latest
LABEL maintainer="name@email.com"
RUN rm -rf /usr/share/nginx/html/*
COPY html/ /usr/share/nginx/html/
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

### 6.4 Essential Commands
```bash
# Images
docker images                    → list images
docker build -t NAME:VERSION .   → build image
docker pull IMAGE                → download image
docker rmi IMAGE                 → delete image

# Containers
docker ps                        → running containers
docker ps -a                     → all containers
docker run -d -p HOST:CONTAINER --name NAME IMAGE
docker stop CONTAINER            → stop container
docker rm CONTAINER              → delete container
docker logs CONTAINER            → view logs
docker exec -it CONTAINER bash   → shell access

# Combined stop and remove
docker stop NAME && docker rm NAME
```

### 6.5 Zero Downtime Deployment
```
STEPS:
1. Build new image with new version tag
   docker build -t app:2.0 .

2. Start new version on different port
   docker run -d -p 8081:80 --name app-v2 app:2.0

3. Test new version works
   http://SERVER_IP:8081

4. Stop old version
   docker stop app-v1 && docker rm app-v1

5. Start new version on main port
   docker run -d -p 8080:80 --name app app:2.0
```

### 6.6 Rollback
```bash
docker stop CONTAINER
docker rm CONTAINER
docker run -d -p PORT:80 --name NAME IMAGE:OLD_VERSION
```
---

*This handbook is updated as new modules are completed.*
*Latest version always on GitHub: bryanngu/securebank-infrastructure*

