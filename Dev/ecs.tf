# ECS Cluster
resource "aws_ecs_cluster" "mc_cluster" {
  name = "mc-dev-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name        = "mc-dev-cluster"
    Environment = "Dev"
    Project     = "MaidCentral"
  }
}

# IAM Role for ECS Task Execution
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "mc-dev-ecs-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })

  tags = {
    Name        = "mc-dev-ecs-execution-role"
    Environment = "Dev"
    Project     = "MaidCentral"
  }
}

# Attach AWS managed policy to execution role
resource "aws_iam_role_policy_attachment" "ecs_execution_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ECS Task Definition
resource "aws_ecs_task_definition" "mc_app" {
  family                   = "mc-dev-app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([{
    name      = "mc-app"
    image     = "${aws_ecr_repository.mc_app.repository_url}:latest"
    essential = true
    portMappings = [{
      containerPort = 80
      hostPort      = 80
      protocol      = "tcp"
    }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = "/ecs/mc-dev-app"
        "awslogs-region"        = "us-east-1"
        "awslogs-stream-prefix" = "ecs"
      }
    }
  }])

  tags = {
    Name        = "mc-dev-app"
    Environment = "Dev"
    Project     = "MaidCentral"
  }
}

# CloudWatch Log Group for ECS
resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "/ecs/mc-dev-app"
  retention_in_days = 7

  tags = {
    Name        = "mc-dev-ecs-logs"
    Environment = "Dev"
    Project     = "MaidCentral"
  }
}

# Outputs
output "ecs_cluster_name" {
  value = aws_ecs_cluster.mc_cluster.name
}

output "ecs_task_definition_arn" {
  value = aws_ecs_task_definition.mc_app.arn
}