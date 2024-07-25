resource "aws_iam_policy" "ec2-policy" {
  name        = "server-policy"
  path        = "/"
  description = "Policy to provide EC2 permissions"
  policy      = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "ec2policy",
  "Statement": [
    {
      "Sid": "First",
      "Effect": "Allow",
      "Action": [
        "autoscaling:Describe*",
        "ssm:DescribeDocument",
        "ssmmessages:*",
        "ssm:PutConfigureaPackageResult",
        "ssm:GetParameter",
        "ssm:UpdateAssociationStatus",
        "ssm:GetMannifest",
        "ssm:GetDocument",
        "ec2messages:*",
        "ssm:PutComplianceItems",
        "ssm:DescribeAssociation",
        "ssm:ListCommands",
        "s3:*",
        "ssm:GetDeployablePatchSnapshotForInstance",
        "ssm:PutInventory",
        "ssm:ListAssociations",
        "ssm:UpdateInstanceAssociationStatus",
        "ec2:*",
        "kms:GenerateDataKey",
        "kms:Decrypt",
        "logs:*"
      ],
      "Resource": "*"
    }
  ]
}
POLICY
}

resource "aws_iam_role" "ec2-role" {
  name = "ec2-profile-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2-policy-attachment" {
  role       = aws_iam_role.ec2-role.name
  policy_arn = aws_iam_policy.ec2-policy.arn
}

resource "aws_iam_instance_profile" "ec2-profile" {
  name = "ec2-instance-profile"
  role = aws_iam_role.ec2-role.name
}

resource "aws_iam_role_policy_attachment" "ssm-managed-policy" {
  role       = aws_iam_role.ec2-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# resource "aws_sns_topic_policy" "topic-policy" {
#   arn    = aws_sns_topic.asg-sns-topic.arn
#   policy = data.aws_iam_policy_document.sns-topic-policy.json
# }

# data "aws_iam_policy_document" "sns-topic-policy" {
#   statement {
#     sid = "AllowManageSNS"

#     actions = [
#       "SNS:Subscribe",
#       "SNS:SetTopicAttributes",
#       "SNS:RemovePermission",
#       "SNS:Receive",
#       "SNS:Publish",
#       "SNS:ListSubscriptionsByTopic",
#       "SNS:GetTopicAttributes",
#       "SNS:DeleteTopic",
#       "SNS:AddPermission",
#     ]

#     effect    = "Allow"
#     resources = [aws_sns_topic.asg-sns-topic.arn]

#     principals {
#       type        = "AWS"
#       identifiers = ["*"]
#     }
#   }

#   statement {
#     sid       = "Allow CloudwatchEvents"
#     actions   = ["sns:Publish"]
#     resources = [aws_sns_topic.asg-sns-topic.arn]

#     principals {
#       type        = "Service"
#       identifiers = ["events.amazonaws.com"]
#     }
#   }

#   statement {
#     sid       = "Allow RDS Event Notification"
#     actions   = ["sns:Publish"]
#     resources = [aws_sns_topic.asg-sns-topic.arn]

#     principals {
#       type        = "Service"
#       identifiers = ["rds.amazonaws.com"]
#     }
#   }
# }

# #SNS - Topic
# resource "aws_sns_topic" "asg-sns-topic" {
#   name = "${var.prefix}-asg-sns-topic-${random_string.rand.result}"
# }

# resource "aws_sqs_queue_policy" "test" {
#   queue_url = aws_sqs_queue.notification-queue.id

#   policy = <<POLICY
# {
#   "Version": "2012-10-17",
#   "Id": "sqspolicy",
#   "Statement": [
#     {
#       "Sid": "First",
#       "Effect": "Allow",
#       "Principal": "*",
#       "Action": "sqs:SendMessage",
#       "Resource": "${aws_sqs_queue.notification-queue.arn}",
#       "Condition": {
#         "ArnEquals": {
#           "aws:SourceArn": "${aws_sns_topic.asg-sns-topic.arn}"
#         }
#       }
#     }
#   ]
# }
# POLICY
# }
