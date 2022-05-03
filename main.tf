provider "aws" {
  region = "us-east-1"
}

locals {
  common-tags = {
    Env = "Test"
  }
}

resource "aws_vpc" "main-vpc" {
  cidr_block           = var.vpc-cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main-vpc.id
}

data "aws_availability_zones" "available" {
  state = "available"
}

# Public Subnets
resource "aws_subnet" "public-subnet" {
  cidr_block              = var.subnet-cidr
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.main-vpc.id
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = merge(
    local.common-tags,
    tomap({
      "Name" = "${var.prefix}-public-subnet"
    })
  )
}

# Public Route Table
resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.main-vpc.id

  tags = merge(
    local.common-tags,
    tomap({ "Name" = "${var.prefix}-public-route" })
  )
}

# Public Route
resource "aws_route" "public-route" {
  route_table_id         = aws_route_table.public-rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

# Public Route Table Association
resource "aws_route_table_association" "public-rt-assoc" {
  subnet_id      = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.public-rt.id
}
