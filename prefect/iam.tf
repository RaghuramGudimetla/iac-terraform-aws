# Prefect user to upload files for flows
resource "aws_iam_user" "prefect_user" {
  name = "prefect-user"
}

resource "aws_iam_policy" "prefect_user_policy" {
  name = "${var.account_id}-prefect-user-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:DescribeSubnets",
          "ec2:DescribeVpcs",
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:GetAuthorizationToken",
          "ecr:GetDownloadUrlForLayer",
          "ecs:DeregisterTaskDefinition",
          "ecs:DescribeTasks",
          "ecs:RegisterTaskDefinition",
          "ecs:RunTask",
          "iam:PassRole",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:GetLogEvents",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "prefect_user_policy_attachment" {
  user       = aws_iam_user.prefect_user.name
  policy_arn = aws_iam_policy.prefect_user_policy.arn
}

resource "aws_iam_user_policy_attachment" "prefect_user_ecs_full_access" {
  user       = aws_iam_user.prefect_user.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
}
