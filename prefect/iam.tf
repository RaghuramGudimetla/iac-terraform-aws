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
          "s3:GetObject",
          "s3:ListBucket",
          "s3:ListAllMyBuckets",
          "s3:PutObject"
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:s3:::ap-southeast-2-886192468297-prefect/flowconfigs/",
          "arn:aws:s3:::ap-southeast-2-886192468297-prefect/flowconfigs/*"
        ]
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "prefect_user_policy_attachment" {
  user = aws_iam_user.prefect_user.name
  policy_arn = aws_iam_policy.prefect_user_policy.arn
}