# Variables
variable "env_name" {
}

variable "vpc_cidr" {
}

variable "vpc_id" {
}

variable "az" {
}

variable "public_subnets" {
  type = "list"
}

variable "service_ports" {
  type = "list"
}

# Create userdata template
data "template_file" "userdata" {
  template = "${file("${path.module}/bootstrap.tpl")}"
}

# Create Instance 01
resource "aws_instance" "server_a" {
  count                       = "${var.az}"
  ami                         = "ami-07dc734dc14746eab"
  instance_type               = "t2.micro"
  user_data                   = "${data.template_file.userdata.rendered}"
  associate_public_ip_address = false

  tags = {
    Name = "${var.env_name}0${count.index + 1}"
  }

  key_name        = "LinuxAppKey"
  subnet_id       = "${element(var.public_subnets, count.index)}"
  security_groups = ["${aws_security_group.Server_SG.id}"]
}

# Create Security Group
resource "aws_security_group" "Server_SG" {
  name        = "${var.env_name}_Security_SG"
  description = "Used for access the instances"
  vpc_id      = "${var.vpc_id}"

  dynamic "ingress" {
    for_each = [for s in var.service_ports : {
      from_port = s.from_port
      to_port   = s.to_port
    }]

    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create EIP for the App servers.
resource "aws_eip" "Servers_a" {
  count    = "${var.az}"
  vpc      = true
  instance = "${element(aws_instance.server_a.*.id, count.index)}"
}
