# Prefect user to upload files for flows
resource "aws_iam_user" "prefect_user" {
  name = "prefect-user"
}

resource "aws_iam_policy" "prefect_s3_access" {
  name = "${var.region}-${var.account_id}-prefect-access"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:GetObjectAcl",
          "s3:GetBucketLocation",
          "s3:PutObject",
          "s3:PutObjectAcl"
        ],
        "Resource" : [
          "arn:aws:s3:::${var.region}-${var.account_id}-prefect",
          "arn:aws:s3:::${var.region}-${var.account_id}-prefect/*"
        ]
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "ecr_user_policy" {
  user   = aws_iam_user.prefect_user.name
  policy_arn = aws_iam_policy.prefect_s3_access.arn
}