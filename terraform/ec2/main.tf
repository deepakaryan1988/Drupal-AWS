provider "aws" {
  region = "ap-south-1"
}

# Get the default VPC to attach the security group
data "aws_vpc" "default" {
  default = true
}

# Create a security group to allow HTTP and SSH access
resource "aws_security_group" "web_sg" {
  name        = "allow_http_ssh"
  description = "Allow HTTP (80) and SSH (22) access"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Import your SSH public key
resource "aws_key_pair" "deployer" {
  key_name   = "deepak-key-devops"
  public_key = file("/Users/deepak/Documents/projects/AWS/deepak-key.pub")
}

# Launch EC2 instance with Apache and user_data
resource "aws_instance" "web" {
  ami                    = "ami-03f4878755434977f"  # Ubuntu 22.04 LTS in Mumbai
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  tags = {
    Name = "DrupalAWS-Demo"
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install apache2 -y
              sudo systemctl start apache2
              sudo systemctl enable apache2
              echo "<h1>Hello from Deepak's EC2 Demo</h1>" > /var/www/html/index.html
              EOF
}
