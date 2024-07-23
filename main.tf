provider "aws" {
  region = var.region
}

# # renote storage
# backend "s3"{}

locals {
  common-tags = {
    Env    = "Test"
    Server = "WindowsServer"
  }
}

resource "aws_vpc" "main-vpc" {
  cidr_block           = var.vpc-cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = local.common-tags
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main-vpc.id
}

# Public Subnets
resource "aws_subnet" "public-subnet" {
  count                   = 2
  cidr_block              = var.subnet-cidrs[count.index]
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.main-vpc.id
  availability_zone       = data.aws_availability_zones.available.names[count.index]

  tags = merge(
    local.common-tags,
    tomap({
      "Name" = "${var.prefix}-public-subnet-${count.index + 1}"
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
  count          = 2
  subnet_id      = aws_subnet.public-subnet[count.index].id
  route_table_id = aws_route_table.public-rt.id
}

# #VPC Endpoint
# resource "aws_vpc_endpoint" "ec2" {
#   vpc_id            = aws_vpc.main-vpc.id
#   service_name      = "com.amazonaws.${var.region}.ec2"
#   vpc_endpoint_type = "Interface"
 
#   subnet_ids =  aws_subnet.public-subnet[*].id 
# }