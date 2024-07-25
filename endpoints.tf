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


resource "aws_security_group" "endpoint-sg" {
  description = "VPC Endpoint Security Group"
  name        = "${var.prefix}-vpc-endpoint-sg"
  vpc_id      = aws_vpc.main-vpc.id

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [var.vpc-cidr, var.private-subnet-cidr, var.subnet-cidr]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = local.tcp-protocol
    cidr_blocks = [var.vpc-cidr, var.private-subnet-cidr, var.subnet-cidr]
  }

  tags = merge(
    {
      Name = "${var.prefix}-vpc-endpoint-sg"
    },
    local.common-tags
  )
}

resource "aws_vpc_endpoint" "ec2-endpoint" {
  #   private_dns_enabled = true
  service_name      = "com.amazonaws.${var.region}.ec2"
  vpc_endpoint_type = "Interface"
  vpc_id            = aws_vpc.main-vpc.id

  security_group_ids = [aws_security_group.endpoint-sg.id]

  // Connect the endpoint to the private subnet
  //subnet_ids = [aws_subnet.private-subnet.id]

  tags = merge(
    {
      Name = "EC2-VPC-Endpoint"
    },
    local.common-tags
  )
}

resource "aws_vpc_endpoint" "ssm-endpoint" {
  #   private_dns_enabled = true
  service_name      = "com.amazonaws.${var.region}.ssm"
  vpc_endpoint_type = "Interface"
  vpc_id            = aws_vpc.main-vpc.id

  security_group_ids = [aws_security_group.endpoint-sg.id]

  // Connect the endpoint to the private subnet
  //subnet_ids = [aws_subnet.private-subnet.id]

  tags = merge(
    {
      Name = "SSM-VPC-Endpoint"
    },
    local.common-tags
  )
}

resource "aws_vpc_endpoint" "s3-endpoint" {
  #   private_dns_enabled = true
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Interface"
  vpc_id            = aws_vpc.main-vpc.id

  security_group_ids = [aws_security_group.endpoint-sg.id]

  // Connect the endpoint to the private subnet
  //subnet_ids = [aws_subnet.private-subnet.id]

  tags = merge(
    {
      Name = "S3Bucket-VPC-Endpoint"
    },
    local.common-tags
  )
}


resource "aws_vpc_endpoint" "ssmmessages-endpoint" {
  #   private_dns_enabled = true
  service_name      = "com.amazonaws.${var.region}.ssmmessages"
  vpc_endpoint_type = "Interface"
  vpc_id            = aws_vpc.main-vpc.id

  security_group_ids = [aws_security_group.endpoint-sg.id]

  // Connect the endpoint to the private subnet
  //subnet_ids = [aws_subnet.private-subnet.id]

  tags = merge(
    {
      Name = "SSMMessages-VPC-Endpoint"
    },
    local.common-tags
  )
}


resource "aws_vpc_endpoint" "ec2messages-endpoint" {
  #   private_dns_enabled = true
  service_name      = "com.amazonaws.${var.region}.ec2messages"
  vpc_endpoint_type = "Interface"
  vpc_id            = aws_vpc.main-vpc.id

  security_group_ids = [aws_security_group.endpoint-sg.id]

  // Connect the endpoint to the private subnet
  //subnet_ids = [aws_subnet.private-subnet.id]

  tags = merge(
    {
      Name = "EC2Messages-VPC-Endpoint"
    },
    local.common-tags
  )
}

resource "aws_vpc_endpoint_subnet_association" "ec2-endpoint-assoc" {
  subnet_id       = aws_subnet.private-subnet.id
  vpc_endpoint_id = aws_vpc_endpoint.ec2-endpoint.id
}

resource "aws_vpc_endpoint_subnet_association" "s3-endpoint-assoc" {
  subnet_id       = aws_subnet.private-subnet.id
  vpc_endpoint_id = aws_vpc_endpoint.s3-endpoint.id
}

resource "aws_vpc_endpoint_subnet_association" "ec2messages-endpoint-assoc" {
  subnet_id       = aws_subnet.private-subnet.id
  vpc_endpoint_id = aws_vpc_endpoint.ec2messages-endpoint.id
}


resource "aws_vpc_endpoint_subnet_association" "ssm-endpoint-assoc" {
  subnet_id       = aws_subnet.private-subnet.id
  vpc_endpoint_id = aws_vpc_endpoint.ssm-endpoint.id
}

resource "aws_vpc_endpoint_subnet_association" "ssmmessages-endpoint-assoc" {
  subnet_id       = aws_subnet.private-subnet.id
  vpc_endpoint_id = aws_vpc_endpoint.ssmmessages-endpoint.id
}

