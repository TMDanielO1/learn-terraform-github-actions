terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    random = {
      source = "hashicorp/random"
    }
  }

  backend "remote" {
    organization = "CNCT-DSGW-Terraform01"

    workspaces {
      name = "cnct-lab-testing"
    }
  }
}

provider "aws" {
  region = "us-east-2"
}

provider "random" {}

resource "random_pet" "sg" {}

resource "aws_instance" "web" {
  ami                    = "ami-09558250a3419e7d0"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.web-sg.id]

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p 8080 &
              EOF
}

resource "aws_security_group" "web-sg" {
  name = "${random_pet.sg.id}-sg"
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["18.162.103.100/32"]
  }
}

output "web-address" {
  value = "${aws_instance.web.public_dns}:8080"
}
