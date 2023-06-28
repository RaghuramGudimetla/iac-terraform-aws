# Allow snowflake to read objects from bucket
resource "aws_iam_policy" "snowflake_read" {
  name        = "snowflake-read"
  description = "Policy for snowflake to read objects from bucket"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ],
        "Resource" : [
          "arn:aws:s3:::ap-southeast-2-886192468297-data-extraction/*",
          "arn:aws:s3:::ap-southeast-2-886192468297-data-extraction"
        ]
      }
    ]
  })
}


# Allow snowflake to read objects from bucket
resource "aws_iam_role" "snowflake_role" {
  name = "snowflake_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Condition": {
          "StringLike": {
              "sts:ExternalId": "QB11547_SFCRole=*"
          }
      },
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::590854632853:root"
      }
    }
  ]
}
EOF

  tags = {
    tag-key = "snowflake-trust"
  }
}

resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = aws_iam_role.snowflake_role.name
  policy_arn = aws_iam_policy.snowflake_read.arn
}
