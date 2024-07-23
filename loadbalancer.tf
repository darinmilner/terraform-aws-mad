# resource "aws_lb" "loadbalancer" {
#   name               = "${var.prefix}-alb"
#   load_balancer_type = "application"
#   security_groups    = [aws_security_group.alb-sg.id]
#   subnets            = [aws_subnet.public-subnet[0].id, aws_subnet.public-subnet[1].id]

#   # access_logs {
#   #   bucket  = var.log-bucket-name
#   #   prefix  = var.prefix
#   #   enabled = true
#   # }

#   tags = local.common-tags
# }

# resource "aws_lb_listener" "http" {
#   load_balancer_arn = aws_lb.loadbalancer.arn
#   port              = local.http-port
#   protocol          = "HTTP"

#   default_action {
#     type = "fixed-response"
#     fixed_response {
#       content_type = "text/plain"
#       message_body = "404 page not found"
#       status_code  = 404
#     }
#   }
# }

# resource "aws_security_group" "alb-sg" {
#   name   = "${var.prefix}-alb-security"
#   vpc_id = aws_vpc.main-vpc.id

#   ingress {
#     from_port   = local.http-port
#     to_port     = local.http-port
#     protocol    = local.tcp-protocol
#     cidr_blocks = [local.all-ips]
#   }

#   ingress {
#     from_port   = local.https-port
#     to_port     = local.https-port
#     protocol    = local.tcp-protocol
#     cidr_blocks = [local.all-ips]
#   }

#   egress {
#     from_port   = local.any-port
#     to_port     = local.any-port
#     protocol    = local.any-protocol
#     cidr_blocks = [local.all-ips]
#   }
# }

# resource "aws_lb_target_group" "lb-tg" {
#   name     = "${var.prefix}-alb-target-group"
#   port     = var.server-port
#   protocol = "HTTP"
#   vpc_id   = aws_vpc.main-vpc.id

#   health_check {
#     path                = "/*"
#     protocol            = "HTTP"
#     matcher             = "200"
#     interval            = var.interval
#     timeout             = 3
#     healthy_threshold   = 2
#     unhealthy_threshold = 2
#   }
# }

# resource "aws_lb_target_group" "lb-tg-2" {
#   name     = "${var.prefix}-alb-target-group2"
#   port     = 8001
#   protocol = "HTTP"
#   vpc_id   = aws_vpc.main-vpc.id

#   health_check {
#     path                = "/*"
#     protocol            = "HTTP"
#     matcher             = "200"
#     interval            = var.interval
#     timeout             = 3
#     healthy_threshold   = 2
#     unhealthy_threshold = 2
#   }
# }
# resource "aws_lb_listener_rule" "lb-listener" {
#   listener_arn = aws_lb_listener.http.arn
#   priority     = 100

#   condition {
#     path_pattern {
#       values = ["*"]
#     }
#   }

#   action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.lb-tg.arn
#   }

#   condition {
#     path_pattern {
#       values = ["*"]
#     }
#   }
# }
