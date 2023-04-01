resource "aws_instance" "aws_ubuntu" {
  count                  = var.counter
  ami                    = var.ami_ubuntu
  instance_type          = var.instance
  subnet_id              = element(var.aws_public_subnet, count.index)
  vpc_security_group_ids = var.aws_web_security_group
  root_block_device {
    volume_size = var.volume_size_web
    volume_type = var.volume_type_web
  }

  tags = {
    Name = "aws_ubuntu-${terraform.workspace == "dev" ? var.name_web.dev : (terraform.workspace == "hom" ? var.name_web.hom : var.name_web.prod)}"
  }

  user_data = <<-EOF
      "sudo apt update",
      "sudo apt-get install apache2 -y",
      "sudo ufw allow 'Apache'",
      "sudo ufw allow ssh",
      "sudo systemctl start apache2"
  EOF
}

resource "aws_instance" "aws_amazon" {
  count                  = var.counter
  ami                    = var.ami_amazon_linux
  instance_type          = var.instance
  subnet_id              = element(var.aws_private_subnet, count.index)
  vpc_security_group_ids = var.aws_server_security_group
  root_block_device {
    volume_size = var.volume_size_server
    volume_type = var.volume_type_server
  }
  tags = {
    Name = "aws_amazon-${terraform.workspace == "dev" ? var.name_web.dev : (terraform.workspace == "hom" ? var.name_web.hom : var.name_web.prod)}"
  }

  user_data = <<-EOF
      "sudo apt update",
      "sudo apt install nginx -y",
      "sudo apt install mysql-server -y",
      "sudo ufw allow 'Nginx HTTP'",
      "systemctl start nginx"
  EOF
}

