# SecureBank Server Provisioner
# Automatically configures server on creation

resource "null_resource" "server_setup" {

  # Connection details
  connection {
    type        = "ssh"
    host        = var.server_ip
    user        = var.admin_user
    port        = var.ssh_port
    private_key = file("~/.ssh/id_rsa")
  }

  # Phase 1 - System Update
  provisioner "remote-exec" {
    inline = [
      "echo '=== Phase 1: System Update ==='",
      "sudo DEBIAN_FRONTEND=noninteractive apt update -y",
      "sudo DEBIAN_FRONTEND=noninteractive apt upgrade -y",
      "echo '=== Phase 1: Complete ==='"
    ]
  }

  # Phase 2 - Install Software
  provisioner "remote-exec" {
    inline = [
      "echo '=== Phase 2: Installing Software ==='",
      "sudo DEBIAN_FRONTEND=noninteractive apt install -y nginx fail2ban ufw",
      "echo '=== Phase 2: Complete ==='"
    ]
  }

  # Phase 3 - Configure Firewall
  provisioner "remote-exec" {
    inline = [
      "echo '=== Phase 3: Firewall Setup ==='",
      "sudo ufw default deny incoming",
      "sudo ufw default allow outgoing",
      "sudo ufw allow ${var.ssh_port}/tcp",
      "sudo ufw allow 80/tcp",
      "sudo ufw --force enable",
      "echo '=== Phase 3: Complete ==='"
    ]
  }

  # Phase 4 - Start and Enable Services
  provisioner "remote-exec" {
    inline = [
      "echo '=== Phase 4: Starting Services ==='",
      "sudo systemctl start nginx",
      "sudo systemctl enable nginx",
      "sudo systemctl start fail2ban",
      "sudo systemctl enable fail2ban",
      "echo '=== Phase 4: Complete ==='"
    ]
  }

  # Phase 5 - Verify Everything
  provisioner "remote-exec" {
    inline = [
      "echo '=== Phase 5: Verification ==='",
      "sudo ufw status",
      "sudo systemctl is-active nginx && echo 'Nginx: OK' || echo 'Nginx: FAILED'",
      "sudo systemctl is-active fail2ban && echo 'Fail2ban: OK' || echo 'Fail2ban: FAILED'",
      "echo '=== SecureBank Server Ready ==='"
    ]
  }
}
