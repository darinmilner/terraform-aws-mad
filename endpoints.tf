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

