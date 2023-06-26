# Lambda role and policy attachments
resource "aws_iam_role" "data_extraction_role" {
    name = "${var.region}_${var.account_id}_data_extraction_role"
    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

# Policy and attachment for logging lambda
resource "aws_iam_policy" "data_extraction_lambda_execution_policy" {
  name = "${var.region}-${var.account_id}-data-extraction-lambda-execution-policy"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "logs:CreateLogGroup",
            "Resource": "arn:aws:logs:ap-southeast-2:${var.account_id}"
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": [
                "arn:aws:logs:ap-southeast-2:${var.account_id}:log-group:/aws/lambda/${var.region}-${var.account_id}-data-extraction:*"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "data_extraction_execution_policy_attachment" {
  role = aws_iam_role.data_extraction_role.name
  policy_arn = aws_iam_policy.data_extraction_lambda_execution_policy.arn
}

# Policy and attachment to write files to bucket location from lambda
resource "aws_iam_policy" "data_extraction_s3_write_policy" {
  name = "${var.region}-${var.account_id}-data-extraction-s3-write-policy"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
              "s3:PutObject"
            ],
            "Resource": "arn:aws:s3:::${var.region}-${var.account_id}-data-extraction/*"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "data_extraction_s3_policy_attachment" {
  role = aws_iam_role.data_extraction_role.name
  policy_arn = aws_iam_policy.data_extraction_s3_write_policy.arn
}

# Create a temp zip file before being uploaded
data "archive_file" "python_data_extraction_package" {
    type = "zip"
    source_file = "${path.module}/functions/data_extraction/lambda_function.py"
    output_path = ".data/data_extraction.zip"
}

# Creating the lambda function
resource "aws_lambda_function" "data_extraction_lambda" {
    filename = ".data/data_extraction.zip"
    function_name = "${var.region}-${var.account_id}-data-extraction"
    description = "Lambda function to extract continuous data"
    role = "${aws_iam_role.data_extraction_role.arn}"
    handler = "lambda_function.lambda_handler"
    runtime = "python3.9"
    timeout = 180
    source_code_hash = data.archive_file.python_data_extraction_package.output_base64sha256
    layers = ["${var.data_wrangler_layer}"]
    environment {
      variables = {
        stage = "test"
      }
    }
}

# Cloud watch 
resource "aws_cloudwatch_log_group" "data_extraction_cloudwatch_group" {
  name     = "/aws/lambda/${var.region}-${var.account_id}-data-extraction"
  retention_in_days = 14
}

resource "aws_cloudwatch_event_rule" "data_extraction_run_lambda" {
  name   = "${var.region}-${var.account_id}-data-extraction-run-lambda"
  description = "Schedule lambda function for data extraction"
  is_enabled = false
  schedule_expression = "rate(10 minutes)"
}

# Trigger lambda from cloudwatch
resource "aws_cloudwatch_event_target" "data_extraction_target" {
  target_id = "data-extraction-target"
  rule = aws_cloudwatch_event_rule.data_extraction_run_lambda.name
  arn = aws_lambda_function.data_extraction_lambda.arn
}

resource "aws_lambda_permission" "data_extraction_allow_cloudwatch" {
  statement_id = "AllowExecutionFromCloudWatch"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.data_extraction_lambda.function_name
  principal = "events.amazonaws.com"
  source_arn = aws_cloudwatch_event_rule.data_extraction_run_lambda.arn
}