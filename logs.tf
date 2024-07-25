# resource "aws_flow_log" "flow-log" {
#   iam_role_arn    = aws_iam_role.vpc_flow_log_cloudwatch.arn
#   log_destination = aws_cloudwatch_log_group.vpc-logs.arn
#   traffic_type    = "ALL"
#   vpc_id          = aws_vpc.main-vpc.id
# }

# resource "aws_cloudwatch_log_group" "vpc-logs" {
#   name            = "/aws/vpc-flow-logs/${var.prefix}-logs"
#   log_group_class = "STANDARD"
#   #   retention_in_days = 7

#   tags = {
#     Name        = "VPC-Logs"
#     Environment = var.environment
#   }
# }

# resource "aws_iam_role" "vpc_flow_log_cloudwatch" {
#   name_prefix        = "vpc-flow-log-role-"
#   assume_role_policy = data.aws_iam_policy_document.flow_log_cloudwatch_assume_role.json
# }

# data "aws_iam_policy_document" "flow_log_cloudwatch_assume_role" {
#   statement {
#     principals {
#       type        = "Service"
#       identifiers = ["vpc-flow-logs.amazonaws.com"]
#     }

#     actions = ["sts:AssumeRole"]
#   }
# }

# resource "aws_iam_role_policy_attachment" "vpc_flow_log_cloudwatch" {
#   role       = aws_iam_role.vpc_flow_log_cloudwatch.name
#   policy_arn = aws_iam_policy.vpc_flow_log_cloudwatch.arn
# }

# resource "aws_iam_policy" "vpc_flow_log_cloudwatch" {
#   name_prefix = "vpc-flow-log-cloudwatch-"
#   policy      = data.aws_iam_policy_document.vpc_flow_log_cloudwatch.json
# }

# data "aws_iam_policy_document" "vpc_flow_log_cloudwatch" {
#   statement {
#     sid = "AWSVPCFlowLogsPushToCloudWatch"

#     actions = [
#       "logs:CreateLogGroup",
#       "logs:CreateLogStream",
#       "logs:PutLogEvents",
#       "logs:DescribeLogGroups",
#       "logs:DescribeLogStreams",
#     ]

#     resources = ["*"]
#   }
# }
