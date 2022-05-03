data "aws_ami" "windows-ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["Windows_Server-2019-English-Full-Base-*"]
  }
}

# resource "aws_instance" "win-server" {
#   instance_type               = "t2.micro"
#   ami                         = data.aws_ami.windows-ami.id
#   subnet_id                   = aws_subnet.public-subnet.id
#   private_ip                  = "10.0.1.122"
#   associate_public_ip_address = true
#   vpc_security_group_ids      = [aws_security_group.web-sg.id]
#   key_name                    = file("${path.module}/keys/authkey.pub")

#   user_data = templatefile("userdata.ps1", {
#     ServerName = "server"
#   })
# }

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
  user_data = filebase64("taskdata.ps1")

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

# resource "aws_launch_configuration" "win-config" {
#   name            = "windows-server-config"
#   image_id        = data.aws_ami.windows-ami.id
#   instance_type   = var.instance-type
#   security_groups = [aws_security_group.web-sg.id]

#   ebs_block_device {
#     //default_version = 1
#     // disable_api_termination = false
#     device_name           = "/dev/sda1"
#     volume_size           = 60
#     volume_type           = "gp2"
#     encrypted             = true
#     iops                  = 0
#     delete_on_termination = true
#   }
#   ebs_optimized = false
#   user_data = templatefile("userdata.ps1", {
#     ServerName  = "server",
#     Environment = "dev",
#     System      = "test"
#   })

#   lifecycle {
#     create_before_destroy = true
#   }
# }

resource "aws_autoscaling_group" "win-server-asg" {
  // launch_configuration = aws_launch_configuration.win-config.name
  launch_template {
    id      = aws_launch_template.launch-tl.id
    version = "$Latest"
  }
  desired_capacity    = var.min-size
  min_size            = var.min-size
  max_size            = var.max-size
  vpc_zone_identifier = [aws_subnet.public-subnet.id]

  // target_group_arns = [aws_lb_target_group.lb-tg.arn]
  // health_check_type = "ELB"

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
