# Security Group for ECS Service
resource "aws_security_group" "ecs_service_sg" {
  name        = "mc-dev-ecs-service-sg"
  description = "Security group for MC ECS Fargate service"
  vpc_id      = aws_vpc.mc-dev.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.vpc_web_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "mc-dev-ecs-service-sg"
    Environment = "Dev"
    Project     = "MaidCentral"
  }
}

# ECS Fargate Service
resource "aws_ecs_service" "mc_app" {
  name            = "mc-dev-app-service"
  cluster         = aws_ecs_cluster.mc_cluster.id
  task_definition = aws_ecs_task_definition.mc_app.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]
    security_groups  = [aws_security_group.ecs_service_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.mc-dev-tg.arn
    container_name   = "mc-app"
    container_port   = 80
  }

  depends_on = [
  aws_iam_role_policy_attachment.ecs_execution_policy,
  aws_lb_listener.mc-dev_http_listener
]

  tags = {
    Name        = "mc-dev-app-service"
    Environment = "Dev"
    Project     = "MaidCentral"
  }
}
# Auto Scaling for ECS Service
resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = 4
  min_capacity       = 2
  resource_id        = "service/${aws_ecs_cluster.mc_cluster.name}/${aws_ecs_service.mc_app.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "ecs_cpu_policy" {
  name               = "mc-dev-cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = 70.0
    scale_in_cooldown  = 300
    scale_out_cooldown = 300
  }
}