# Execution role - mainly used by prefect fargate agent
resource "aws_iam_role" "prefect_execution_role" {
  name = "${var.account_id}-prefect-execution-role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : [
            "ecs-tasks.amazonaws.com",
            "ec2.amazonaws.com",
            "ecs.amazonaws.com",
            "ecr.amazonaws.com"
          ]
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "prefect_ecs_task_execution_policy_attachment" {
  role       = aws_iam_role.prefect_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_policy" "prefect_execution_policy" {
  name = "${var.account_id}-prefect-execution-policy"
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
          "arn:aws:s3:::ap-southeast-2-886192468297-prefect/flows",
          "arn:aws:s3:::ap-southeast-2-886192468297-prefect/flows/*"
        ]
      },
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "ecs:RegisterTaskDefinition",
          "ecs:RunTask",
          "ecs:DescribeTaskDefinition"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "prefect_ecs_execution_policy_attachment" {
  role       = aws_iam_role.prefect_execution_role.name
  policy_arn = aws_iam_policy.prefect_execution_policy.arn
}

resource "aws_iam_role_policy_attachment" "prefect_ecr_policy_attachment" {
  role       = aws_iam_role.prefect_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
}

# Task role

resource "aws_iam_role" "prefect_task_role" {
  name = "${var.account_id}-prefect-task-role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : [
            "ecs-tasks.amazonaws.com",
            "ec2.amazonaws.com",
            "ecs.amazonaws.com",
            "ecr.amazonaws.com"
          ]
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "prefect_task_policy" {
  name = "${var.account_id}-prefect-task-policy"
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
          "arn:aws:s3:::ap-southeast-2-886192468297-prefect/flows",
          "arn:aws:s3:::ap-southeast-2-886192468297-prefect/flows/*"
        ]
      },
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

resource "aws_iam_role_policy_attachment" "prefect_ecs_task_policy_attachment" {
  role       = aws_iam_role.prefect_task_role.name
  policy_arn = aws_iam_policy.prefect_task_policy.arn
}

resource "aws_iam_role_policy_attachment" "prefect_ecr_task_policy_attachment" {
  role       = aws_iam_role.prefect_task_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
}