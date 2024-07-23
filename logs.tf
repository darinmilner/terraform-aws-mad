resource "aws_flow_log" "flow-log" {
  iam_role_arn    = aws_iam_role.vpc-logs-role.arn 
  log_destination = aws_cloudwatch_log_group.vpc-logs.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.main-vpc.id 
}

resource "aws_cloudwatch_log_group" "vpc-logs" {
  name = "${var.prefix}-vpc-logs"
}

data "aws_iam_policy_document" "logs-assume-role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "vpc-logs-role" {
  name               = "vpc-logs-role"
  assume_role_policy = data.aws_iam_policy_document.vpc-logs-policy.json
}

data "aws_iam_policy_document" "vpc-logs-policy" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "example" {
  name   = "vpc-logs-role-policy"
  role   = aws_iam_role.vpc-logs-role.id 
  policy = data.aws_iam_policy_document.logs-assume-role.json 
}