resource "aws_ecs_cluster" "prefect_cluster" {
  name = "ecs-prefect-cluster"
}

resource "aws_ecs_cluster_capacity_providers" "prefect_agent_cluster_capacity_providers" {
  cluster_name       = aws_ecs_cluster.prefect_cluster.name
  capacity_providers = ["FARGATE"]
}