# SecureBank Server Provisioner
# Runs commands on lab server via Terraform

resource "null_resource" "server_setup" {

 #Connection details
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
      "sudo apt update -y",
      "echo 'System updated successfully'"
    ]
  }

  #Phase 2 - Install Security Tools
  provisioner "remote-exec" {
    inline = [
      "echo '=== Phase 2: Security Tools ==='",
      "sudo apt install -y fail2ban ufw",
      "echo 'Security tools installed'"
    ]
  }

  #Phase 3 - Configure Firewall
  provisioner "remote-exec" {
    inline = [
      "echo '===Phase 3: Firewall Setup ==='",
      "sudo ufw default deny incoming",
      "sudo ufw default allow outgoing",
      "sudo ufw allow ${var.ssh_port}/tcp",
      "sudo ufw allow 80/tcp",
      "sudo ufw --force enable",
      "echo 'Firewall configured'"
    ]
  }

  #Phase 4 - Verify Setup
  provisioner "remote-exec" {
    inline = [
      "echo '===phase 4: Verification ==='",
      "sudo ufw status",
      "sudo systemctl is-active nginx",
      "echo 'SecureBank server ready'"
    ]
  }
}
