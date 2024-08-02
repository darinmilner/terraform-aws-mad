provider "aws" {
  region = var.region
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
  cidr_block              = var.subnet-cidr
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.main-vpc.id
  availability_zone       = "${var.region}a"

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

# # EIP for Nat Gateway
# resource "aws_eip" "nat-eip" {
#   domain = "vpc"

#   depends_on = [aws_internet_gateway.main]
# }

# resource "aws_nat_gateway" "nat-gateway" {
#   allocation_id     = aws_eip.nat-eip.id
#   subnet_id         = aws_subnet.public-subnet.id
#   connectivity_type = "public"

#   tags = merge(
#     {
#       Name = "${var.prefix}-nat-gateway"
#     },
#     local.common-tags
#   )
# }

resource "aws_subnet" "private-subnet" {
  availability_zone               = "${var.region}a"
  vpc_id                          = aws_vpc.main-vpc.id
  cidr_block                      = var.private-subnet-cidr
  assign_ipv6_address_on_creation = false
  map_public_ip_on_launch         = false

  depends_on = [aws_vpc.main-vpc]

  tags = merge(
    {
      Name = "Private-Subnet"
    },
    local.common-tags
  )
}
# Private Route Table
resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.main-vpc.id

  tags = merge(
    local.common-tags,
    tomap({ "Name" = "${var.prefix}-private-route" })
  )
}

# Private Route
resource "aws_route" "private-route" {
  route_table_id         = aws_route_table.private-rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

# Private Route Table Association
resource "aws_route_table_association" "private-rt-assoc" {
  subnet_id      = aws_subnet.private-subnet.id
  route_table_id = aws_route_table.private-rt.id
}

