# Lambda role and policy attachments
resource "aws_iam_role" "external_function_role" {
  name               = "${var.region}-${var.account_id}-external-function-role"
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
resource "aws_iam_policy" "external_function_lambda_execution_policy" {
  name   = "${var.region}-${var.account_id}-external-function-lambda-execution-policy"
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
                "arn:aws:logs:ap-southeast-2:${var.account_id}:log-group:/aws/lambda/${var.region}-${var.account_id}-external-function:*"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "external_function_execution_policy_attachment" {
  role       = aws_iam_role.external_function_role.name
  policy_arn = aws_iam_policy.external_function_lambda_execution_policy.arn
}

# Create a temp zip file before being uploaded
data "archive_file" "python_external_function_package" {
  type        = "zip"
  source_file = "${path.module}/functions/external_function/lambda_function.py"
  output_path = ".data/external_function.zip"
}

# Creating the lambda function
resource "aws_lambda_function" "external_function_lambda" {
  filename         = ".data/external_function.zip"
  function_name    = "${var.region}-${var.account_id}-external-function"
  description      = "Lambda function to be used as snowflake external function"
  role             = aws_iam_role.external_function_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.9"
  timeout          = 180
  source_code_hash = data.archive_file.python_external_function_package.output_base64sha256
  layers           = ["${var.data_wrangler_layer}"]
  environment {
    variables = {
      stage = "test"
    }
  }
}

# Cloud watch 
resource "aws_cloudwatch_log_group" "external_function_cloudwatch_group" {
  name              = "/aws/lambda/${var.region}-${var.account_id}-external-function"
  retention_in_days = 7
}

/*
Creating proxy service for lambda
*/

resource "aws_iam_role" "external_function_proxy_role" {
  name = "${var.region}-${var.account_id}-external-function-proxy-role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : "sts:AssumeRole",
        "Principal" : {
          "AWS" : "arn:aws:iam::590854632853:user/5tjb-s-auss6886"
        },
        "Condition" : {
          "StringLike" : {
            "sts:ExternalId" : "QB11547_SFCRole=2_OJ0KYyXr0dyGHS69gDmjRqY1s1E="
          }
        }
      }
    ]
  })
}

# API Gateway with REST
resource "aws_api_gateway_rest_api" "external_function_rest_api" {
  name        = "external-function-rest-api"
  description = "API for external function"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# Creating a resource in API Gateway actions
resource "aws_api_gateway_resource" "external_function_rest_resource" {
  path_part   = "action"
  parent_id   = aws_api_gateway_rest_api.external_function_rest_api.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.external_function_rest_api.id
}

# Create a method. Ideally API method.
resource "aws_api_gateway_method" "external_function_rest_method" {
  rest_api_id   = aws_api_gateway_rest_api.external_function_rest_api.id
  resource_id   = aws_api_gateway_resource.external_function_rest_resource.id
  http_method   = "POST"
  authorization = "AWS_IAM"
}

# Integration with lambda
resource "aws_api_gateway_integration" "external_function_rest_integration" {
  rest_api_id             = aws_api_gateway_rest_api.external_function_rest_api.id
  resource_id             = aws_api_gateway_resource.external_function_rest_resource.id
  http_method             = aws_api_gateway_method.external_function_rest_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.external_function_lambda.invoke_arn
}

# Lambda permission
resource "aws_lambda_permission" "apigw_rest_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.external_function_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:ap-southeast-2:${var.account_id}:${aws_api_gateway_rest_api.external_function_rest_api.id}/*/${aws_api_gateway_method.external_function_rest_method.http_method}${aws_api_gateway_resource.external_function_rest_resource.path}"
}

# This resource policy is to ensure who can access the endpoint
resource "aws_api_gateway_rest_api_policy" "external_function_rest_api_policy" {
  rest_api_id = aws_api_gateway_rest_api.external_function_rest_api.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:sts::${var.account_id}:assumed-role/${var.region}-${var.account_id}-external-function-proxy-role/snowflake"
      },
      "Action": "execute-api:Invoke",
      "Resource": "arn:aws:execute-api:ap-southeast-2:${var.account_id}:${aws_api_gateway_rest_api.external_function_rest_api.id}/*/${aws_api_gateway_method.external_function_rest_method.http_method}${aws_api_gateway_resource.external_function_rest_resource.path}"
    }
  ]
}
EOF
}

# Deploying the API
resource "aws_api_gateway_deployment" "external_function_rest_api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.external_function_rest_api.id
  description = "Deploying the API"
  triggers = {
    redeployment = sha1(jsonencode([aws_api_gateway_rest_api.external_function_rest_api.id
      , aws_api_gateway_method.external_function_rest_method.id
      , aws_api_gateway_integration.external_function_rest_integration
    ]))
  }
  lifecycle {
    create_before_destroy = true
  }
}

# We need a stage while deployment
resource "aws_api_gateway_stage" "external_function_gateway_stage" {
  deployment_id         = aws_api_gateway_deployment.external_function_rest_api_deployment.id
  rest_api_id           = aws_api_gateway_rest_api.external_function_rest_api.id
  description           = "Stage used to deploy the API"
  stage_name            = "test"
  cache_cluster_size    = 0.5
  cache_cluster_enabled = true
}
