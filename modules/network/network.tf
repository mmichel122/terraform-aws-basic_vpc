# Variables
variable "env_name" {
}

variable "vpc_cidr" {
}

variable "az" {
}

# Get AZs
data "aws_availability_zones" "available" {}

# Create VPC
resource "aws_vpc" "vpc" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name   = "${var.env_name} VPC"
    Deploy = "vpc"
  }
}

# Create Internet gateway
resource "aws_internet_gateway" "vpc" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags = {
    Name   = "${var.env_name} Internet Gateway"
    Deploy = "vpc"
  }
}

# Create Public Subnets
resource "aws_subnet" "Public_subnet" {
  count             = "${var.az}"
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${cidrsubnet(var.vpc_cidr, 8, count.index + 1)}"
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"

  tags = {
    Name   = "${var.env_name}  Public Subnet AZ${count.index + 1}"
    Deploy = "vpc"
  }
}

# Create Public Route Table for Internet Access
resource "aws_route_table" "public_vpc" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.vpc.id}"
  }

  tags = {
    Name   = "${var.env_name} Public Route Table"
    Deploy = "vpc"
  }
}

resource "aws_route_table_association" "public" {
  count          = "${var.az}"
  subnet_id      = "${element(aws_subnet.Public_subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.public_vpc.id}"
}

output "vpc" {
  value = aws_vpc.vpc.id
}

output "public_subnets" {
  value = aws_subnet.Public_subnet.*.id
}
