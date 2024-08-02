
# resource "aws_key_pair" "auth-key" {
#   key_name   = "authkey"
#   public_key = file("${path.module}/keys/authkey.pub")
# }

# resource "aws_launch_template" "launch-tl" {
#   name_prefix   = "${var.prefix}-asg-template"
#   instance_type = var.instance-type
#   image_id      = data.aws_ami.windows-ami.id
#   //key_name               = aws_key_pair.auth-key.id
#   key_name               = "EC2-Key"
#   vpc_security_group_ids = [aws_security_group.web-sg.id]

#   iam_instance_profile {
#     arn = aws_iam_instance_profile.ec2-profile.arn
#   }

#   metadata_options {
#     http_endpoint               = "enabled"  //default
#     http_tokens                 = "optional" // default
#     http_put_response_hop_limit = 5
#     instance_metadata_tags      = "enabled"
#   }

#   network_interfaces {
#     associate_public_ip_address = true
#     delete_on_termination = true 
#   }

#   user_data = base64encode(templatefile("powershell/testing.ps1", {
#     BucketName  = aws_s3_bucket.powershellbucket.bucket,
#     Environment = "dev",
#     System      = "test"
#     Region      = var.region
#   }))
#   # user_data = filebase64("powershell/get-scripts.ps1")

#   monitoring {
#     enabled = true
#   }

#   block_device_mappings {
#     device_name = "/dev/sda1"

#     ebs {
#       volume_size           = 60
#       delete_on_termination = true
#     }
#   }

#   tag_specifications {
#     resource_type = "instance"

#     tags = {
#       Name        = "Test-Powershell-Instance"
#       Bucket-Name = aws_s3_bucket.powershellbucket.bucket
#       Environment = "dev"
#     }
#   }

#   depends_on = [
#     aws_s3_bucket.powershellbucket
#   ]
# }

resource "aws_instance" "ec2-instance" {
  instance_type = "t2.micro"
  ami           = data.aws_ami.windows-ami.id

  iam_instance_profile   = aws_iam_instance_profile.ec2-profile.name
  key_name               = "EC2-Key"
  availability_zone      = "${var.region}a"
  vpc_security_group_ids = [aws_security_group.web-sg.id]
  # subnet_id            = aws_subnet.public-subnet.id
  subnet_id = aws_subnet.private-subnet.id

  user_data = base64encode(templatefile("powershell/startup.ps1", {
    BucketName  = aws_s3_bucket.powershellbucket.bucket,
    Environment = "dev",
    System      = "test"
    Region      = var.region
  }))

  tags = {
    Name = "${var.prefix}-ec2-demo"
    OS   = "Windows"
  }
}

# resource "aws_autoscaling_group" "win-server-asg" {
#   launch_template {
#     id      = aws_launch_template.launch-tl.id
#     version = "$Latest"
#   }
#   desired_capacity    = var.min-size
#   min_size            = var.min-size
#   max_size            = var.max-size
#   health_check_type = "EC2"
#   availability_zones = [ "${var.region}a" ]
#   //vpc_zone_identifier = [aws_subnet.public-subnet[0].id, aws_subnet.public-subnet[1].id]

#   tag {
#     key                 = "Terraform-ASG"
#     value               = "${var.prefix}Server"
#     propagate_at_launch = true
#   }
#   tag {
#     key                 = "OperatingSystem"
#     value               = "WindowsOS"
#     propagate_at_launch = true
#   }
# }

resource "aws_security_group" "web-sg" {
  name        = "allow web access"
  description = "allow inbound traffic"
  vpc_id      = aws_vpc.main-vpc.id

  # ingress {
  #   description = "Windows port RDP"
  #   from_port   = "3389"
  #   to_port     = "3389"
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  # ingress {
  #   description = "HTTP"
  #   from_port   = "80"
  #   to_port     = "80"
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  # ingress {
  #   description = "HTTPS"
  #   from_port   = "443"
  #   to_port     = "443"
  #   protocol    = local.tcp-protocol
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  ingress {
    cidr_blocks = [aws_subnet.private-subnet.cidr_block] # private subnet cidr
    from_port   = "0"
    protocol    = local.any-protocol
    to_port     = "0"
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "0"
    protocol    = local.any-protocol
    to_port     = "0"
  }

  tags = {
    "Name" = "ec2-sg"
  }
}
