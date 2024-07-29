
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

