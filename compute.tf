data "aws_ami" "windows-ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["Windows_Server-2019-English-Full-Base-*"]
  }
}

locals {
  http-port    = 80
  https-port   = 443
  any-port     = 0
  any-protocol = "-1"
  tcp-protocol = "tcp"
  all-ips      = "0.0.0.0/0"
}

resource "aws_key_pair" "auth-key" {
  key_name   = "authkey"
  public_key = file("${path.module}/keys/authkey.pub")
}

resource "aws_launch_template" "launch-tl" {
  name_prefix            = "${var.prefix}-asg-template"
  instance_type          = var.instance-type
  image_id               = data.aws_ami.windows-ami.id
  key_name               = aws_key_pair.auth-key.id
  vpc_security_group_ids = [aws_security_group.web-sg.id]

  # user_data = base64encode(templatefile("userdata.ps1", {
  #   ServerName  = "server",
  #   Environment = "dev",
  #   System      = "test"
  # }))
  # user_data = filebase64("powershell/get-scripts.ps1")

  monitoring {
    enabled = true
  }

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size = 60
    }
  }
}

resource "aws_autoscaling_group" "win-server-asg" {
  launch_template {
    id      = aws_launch_template.launch-tl.id
    version = "$Latest"
  }
  desired_capacity    = var.min-size
  min_size            = var.min-size
  max_size            = var.max-size
  vpc_zone_identifier = [aws_subnet.public-subnet[0].id, aws_subnet.public-subnet[1].id]

  tag {
    key                 = "Terraform-ASG"
    value               = "${var.prefix}-window-server-autoscaling"
    propagate_at_launch = true
  }
}

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

resource "aws_lb" "loadbalancer" {
  name               = "${var.prefix}-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb-sg.id]
  subnets            = [aws_subnet.public-subnet[0].id, aws_subnet.public-subnet[1].id]

  # access_logs {
  #   bucket  = var.log-bucket-name
  #   prefix  = var.prefix
  #   enabled = true
  # }

  tags = local.common-tags
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.loadbalancer.arn
  port              = local.http-port
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "404 page not found"
      status_code  = 404
    }
  }
}

resource "aws_security_group" "alb-sg" {
  name   = "${var.prefix}-alb-security"
  vpc_id = aws_vpc.main-vpc.id

  ingress {
    from_port   = local.http-port
    to_port     = local.http-port
    protocol    = local.tcp-protocol
    cidr_blocks = [local.all-ips]
  }

  ingress {
    from_port   = local.https-port
    to_port     = local.https-port
    protocol    = local.tcp-protocol
    cidr_blocks = [local.all-ips]
  }

  egress {
    from_port   = local.any-port
    to_port     = local.any-port
    protocol    = local.any-protocol
    cidr_blocks = [local.all-ips]
  }
}

resource "aws_lb_target_group" "lb-tg" {
  name     = "${var.prefix}-alb-target-group"
  port     = var.server-port
  protocol = "HTTP"
  vpc_id   = aws_vpc.main-vpc.id

  health_check {
    path                = "/*"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = var.interval
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_target_group" "lb-tg-2" {
  name     = "${var.prefix}-alb-target-group2"
  port     = 8001
  protocol = "HTTP"
  vpc_id   = aws_vpc.main-vpc.id

  health_check {
    path                = "/*"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = var.interval
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}
resource "aws_lb_listener_rule" "lb-listener" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb-tg.arn
  }

  condition {
    path_pattern {
      values = ["*"]
    }
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

