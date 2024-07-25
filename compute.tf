
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

  iam_instance_profile = aws_iam_instance_profile.ec2-profile.name
  key_name             = "EC2-Key"
  availability_zone    = "${var.region}a"
  security_groups      = [aws_security_group.web-sg.id]
  //subnet_id = aws_subnet.public-subnet.id 
  subnet_id = aws_subnet.private-subnet.id

  user_data = base64encode(templatefile("powershell/testing.ps1", {
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
  name        = "allow_web_access"
  description = "allow inbound traffic"
  vpc_id      = aws_vpc.main-vpc.id

  ingress {
    description = "Windows port RDP"
    from_port   = "3389"
    to_port     = "3389"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTP"
    from_port   = "80"
    to_port     = "80"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTPS"
    from_port   = "443"
    to_port     = "443"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "0"
    protocol    = "-1"
    to_port     = "0"
  }
  tags = {
    "Name" = "ec2-sg"
  }
}

# resource "aws_iam_role" "codedeploy-role" {
#   name = "codedeploy-role"

#   assume_role_policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Sid": "",
#       "Effect": "Allow",
#       "Principal": {
#         "Service": "codedeploy.amazonaws.com"
#       },
#       "Action": "sts:AssumeRole"
#     }
#   ]
# }
# EOF
# }

# resource "aws_iam_role_policy_attachment" "AWSCodeDeployRole" {
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
#   role       = aws_iam_role.codedeploy-role.name
# }

# resource "aws_codedeploy_app" "app" {
#   compute_platform = "Server"
#   name             = "test-app"
# }

# resource "aws_codedeploy_deployment_group" "deployment" {
#   app_name               = aws_codedeploy_app.app.name
#   deployment_config_name = "CodeDeployDefault.OneAtATime"
#   deployment_group_name  = "Test-Group"
#   service_role_arn       = aws_iam_role.codedeploy-role.arn

#   load_balancer_info {
#     target_group_pair_info {
#       prod_traffic_route {
#         listener_arns = [aws_lb_listener.http.arn]
#       }

#       target_group {
#         name = aws_lb_target_group.lb-tg.name
#       }
#       target_group {
#         name = aws_lb_target_group.lb-tg-2.name
#       }
#     }
#   }
# }

