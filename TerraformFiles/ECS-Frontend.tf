# ECS task definition for frontend
resource "aws_ecs_task_definition" "frontend_task" {
  family                   = "frontend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = "arn:aws:iam::803800361253:role/ecsTaskExecutionRole"
  task_role_arn            = "arn:aws:iam::803800361253:role/ecsTaskExecutionRole"


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
