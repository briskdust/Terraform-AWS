resource "aws_security_group" "security-group-trial" {
  name        = "dev-security-group"
  description = "Allow TLS inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH into VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Nginx Port"
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
    Name = "security-group-sg"
  }
}

data "aws_ami" "latest-amazon-linus" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "instance-trial" {
  ami           = data.aws_ami.latest-amazon-linus.id
  instance_type = "t2.micro"

  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.security-group-trial.id]
  availability_zone      = "eu-west-3a"

  associate_public_ip_address = true
  key_name                    = aws_key_pair.key-pair-trial.key_name

  tags = {
    Name = "dev-instance"
  }
}

resource "aws_key_pair" "key-pair-trial" {
  key_name   = "new-key"
  public_key = file(var.public_key_path)
}
