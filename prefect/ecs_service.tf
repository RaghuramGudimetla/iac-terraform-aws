
resource "aws_ecs_cluster" "prefect_cluster" {
  name = "ecs-prefect-cluster"
}

resource "aws_ecs_cluster_capacity_providers" "prefect_agent_cluster_capacity_providers" {
  cluster_name       = aws_ecs_cluster.prefect_cluster.name
  capacity_providers = ["FARGATE"]
}

resource "aws_cloudwatch_log_group" "prefect_agent_log_group" {
  name              = "prefect-agent-log-group"
  retention_in_days = 7
}

resource "aws_ecs_task_definition" "prefect_agent_task_definition" {
  family = "prefect-agent"
  cpu    = var.cpu
  memory = var.memory

  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  container_definitions = jsonencode([
    {
      name    = "prefect-agent"
      image   = var.prefect_image
      command = ["prefect", "agent", "start", "-q", var.prefect_agent_queue_name]
      cpu     = var.cpu
      memory  = var.memory
      environment = [
        {
          name  = "PREFECT_API_URL"
          value = var.prefect_api_url
        }
      ]
      secrets = [
        {
          name      = "PREFECT_API_KEY"
          valueFrom = var.prefect_api_key
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.prefect_agent_log_group.name
          awslogs-region        = "ap-southeast-2"
          awslogs-stream-prefix = "prefect-agent"
        }
      }
    }
  ])
  execution_role_arn = aws_iam_role.prefect_execution_role.arn
  task_role_arn = aws_iam_role.prefect_task_role.arn
}

resource "aws_ecs_service" "prefect_agent_service" {
  name          = "prefect-agent-service"
  cluster       = aws_ecs_cluster.prefect_cluster.id
  desired_count = 1
  launch_type   = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.prefect_security_group.id]
    assign_public_ip = true
    subnets          = [aws_subnet.prefect_subnet.id]
  }
  task_definition = aws_ecs_task_definition.prefect_agent_task_definition.arn
}