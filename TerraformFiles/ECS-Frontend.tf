# ECS task definition for frontend
resource "aws_ecs_task_definition" "frontend_task" {
  family                   = "frontend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = "arn:aws:iam::896099932731:role/ecstaskExecutionrole"
  task_role_arn            = "arn:aws:iam::896099932731:role/ecstaskExecutionrole"




  container_definitions = jsonencode([
    {
      name  = "frontend-container"
      image = "your_registry/frontend:latest" # Replace with your Docker image repository URL
      
      # Commands to run inside the container
      command = [
        "npm",
        "start"
      ]

      # Expose the container port
      portMappings = [
        {
          containerPort = 3000
        }
      ]
    }
  ])
}

# ECS Service for Frontend
resource "aws_ecs_service" "frontend_service" {
  name            = "frontend-service"
  cluster         = aws_ecs_cluster.aws-ecs-cluster.id
  task_definition = aws_ecs_task_definition.frontend_task.arn
  launch_type     = "FARGATE"
  desired_count   = 2

  network_configuration {
    subnets = aws_subnet.public_subnets[*].id
    security_groups = [aws_security_group.ecs_security_group.id]
  }
  
  depends_on = [aws_lb_target_group.dep8_frontend]
}