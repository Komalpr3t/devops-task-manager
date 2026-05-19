terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Security Group allowing SSH, HTTP, and k3s/Kubernetes API access
resource "aws_security_group" "k3s_sg" {
  name        = "k3s_node_sg"
  description = "Allow inbound traffic for k3s, HTTP, and SSH"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    description = "NodePort Service Range"
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Kubernetes API"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Restrict this to your Jenkins/Dev IP in production
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "k3s-sg"
  }
}

# EC2 Instance
resource "aws_instance" "k3s_node" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  vpc_security_group_ids = [aws_security_group.k3s_sg.id]

  # User data script to install Docker and k3s
  user_data = <<-EOF
              #!/bin/bash
              set -ex

              # Update packages
              apt-get update -y
              apt-get upgrade -y

              # Install Docker
              apt-get install -y apt-transport-https ca-certificates curl software-properties-common
              curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
              add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
              apt-get update -y
              apt-get install -y docker-ce docker-ce-cli containerd.io
              usermod -aG docker ubuntu

              # Install k3s
              curl -sfL https://get.k3s.io | sh -s - --write-kubeconfig-mode 644 --node-external-ip=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)

              # Make kubeconfig accessible to ubuntu user
              mkdir -p /home/ubuntu/.kube
              cp /etc/rancher/k3s/k3s.yaml /home/ubuntu/.kube/config
              chown -R ubuntu:ubuntu /home/ubuntu/.kube
              
              # Output kubeconfig path so the user can easily fetch it
              echo "k3s installation complete. Kubeconfig is at /etc/rancher/k3s/k3s.yaml"
              EOF

  tags = {
    Name = "Task-Manager-K3s-Node"
  }
}
