# Define ECS task definition for backend
resource "aws_ecs_task_definition" "backend_task" {
  family                   = "backend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = "arn:aws:iam::896099932731:role/ecstaskExecutionrole"
  task_role_arn            = "arn:aws:iam::896099932731:role/ecstaskExecutionrole"


  container_definitions = jsonencode([
    {
      name  = "backend-container"
      image = "kha1i1/deployment8:BEimage"
      
      # Commands to run inside the container
      command = [
        "python",
        "manage.py",
        "migrate"
      ]

      # Expose the container port
      portMappings = [
        {
          containerPort = 8000
        }
      ]
    }
  ])
}


# ECS Service for Backend
resource "aws_ecs_service" "backend_service" {
  name            = "backend-service"
  cluster         = aws_ecs_cluster.aws-ecs-cluster.id
  task_definition = aws_ecs_task_definition.backend_task.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets = aws_subnet.public_subnets[*].id
    security_groups = [aws_security_group.ecs_security_group.id]
  }
}