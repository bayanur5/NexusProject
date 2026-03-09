resource "null_resource" "wait_for_nexus" {
  depends_on = [aws_instance.nexus]

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = aws_instance.nexus.public_ip
      user        = "ubuntu"
      private_key = file("/Users/aktan/.ssh/id_rsa")
    }

    inline = [
      "echo 'Waiting for Nexus to start...'",
      "for i in $(seq 1 30); do",
      "  if nc -zv 127.0.0.1 8081; then",
      "    echo 'Nexus is up!'",
      "    exit 0",
      "  fi",
      "  sleep 10",
      "done",
      "echo 'Nexus did not start in time!'",
      "exit 1"
    ]
  }
}