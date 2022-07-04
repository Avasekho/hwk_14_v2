terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.21.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "build_server" {
  ami                    = "ami-08d4ac5b634553e16"
  instance_type          = "t2.micro"
  key_name               = "us-east-1-key"
  vpc_security_group_ids = [aws_security_group.open_port_22_8080.id]
  iam_instance_profile   = "aws-ec2-s3-bucket-access"

  tags = {
    Name = "Build Server"
  }

  connection {
    type     = "ssh"
    user     = "ubuntu"
    private_key = file("/home/avasekho/us-east-1-key.pem")
    host     = self.public_ip
  }

    provisioner "remote-exec" {
      inline = [
        "sudo apt update",
        "sudo apt update",
        "sudo apt install -y maven default-jdk awscli",
        "mkdir -p /home/ubuntu/.ssh/",
        "aws s3 cp s3://avasekho.test.credentials/id_rsa /home/ubuntu/.ssh/id_rsa",
        "aws s3 cp s3://avasekho.test.credentials/config /home/ubuntu/.ssh/config",
        "chmod 400 /home/ubuntu/.ssh/id_rsa",
        "chmod 600 /home/ubuntu/.ssh/config",
        "git config --global core.sshCommand 'ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'",
        "git clone ssh://APKAVNWETNK3NSW6CY4P@git-codecommit.us-east-1.amazonaws.com/v1/repos/boxfuze /tmp/boxfuze",
        "cd /tmp/boxfuze/",
        "mvn package",
        "aws s3 cp /tmp/boxfuze/target/hello-1.0.war s3://boxfuze.avasekho.test/hello-1.0.war",
    ]
  }

}

resource "aws_instance" "prod_server" {
  ami                    = "ami-08d4ac5b634553e16"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.open_port_22_8080.id]
  key_name               = "us-east-1-key"
  depends_on             = [aws_instance.build_server]
  iam_instance_profile   = "aws-ec2-s3-bucket-access"

  tags = {
    Name = "Prod Server"
  }

  connection {
    type     = "ssh"
    user     = "ubuntu"
    private_key = file("/home/avasekho/us-east-1-key.pem")
    host     = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt update",
      "sudo apt install -y tomcat9 awscli",
      "sudo chmod 777 /var/lib/tomcat9/webapps/",
      "aws s3 cp s3://boxfuze.avasekho.test/hello-1.0.war /var/lib/tomcat9/webapps/hello-1.0.war",
    ]
  }

}

resource "aws_security_group" "open_port_22_8080" {
  name        = "allow_8080_for_tomcat"
  description = "Allow inbound traffic on port 8080"

  ingress {
    description = "Open port for tomcat"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Open port for tomcat"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_8080_for_tomcat"
  }
}