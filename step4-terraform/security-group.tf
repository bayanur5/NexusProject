resource "aws_security_group" "nexus_sg" {
  name        = "nexus-sg"
  description = "Allow SSH from laptop and HTTP for Nexus"
  vpc_id      = aws_vpc.main.id

  # SSH from your laptop only
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["97.242.60.240/32"]   # <-- replace with your laptop IP
  }

  # Nexus UI accessible publicly
  ingress {
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # All outbound allowed
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.tags
}