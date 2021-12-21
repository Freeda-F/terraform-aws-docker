## key pair generation
resource "aws_key_pair" "ipstack" {
  key_name   = "ipst-key"
  public_key = file ("ipst-key.pub")
}

## security group creation
resource "aws_security_group" "ipstack-sg" {
  name        = "ipstack-sg"
  description = "Allow TLS all inbound traffic"

  ingress {
    description      = ""
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

 tags = {
    Name = "${var.project}-sg"
    Project = var.project
  }
}

# get details of VPC and its subnets
data "aws_subnet_ids" "vpc" {
  vpc_id = var.vpc-id
}