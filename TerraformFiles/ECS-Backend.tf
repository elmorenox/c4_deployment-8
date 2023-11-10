# Define ECS task definition for backend
resource "aws_ecs_task_definition" "backend_task" {
  family                   = "backend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = "arn:aws:iam::803800361253:role/ecsTaskExecutionRole"
  task_role_arn            = "arn:aws:iam::803800361253:role/ecsTaskExecutionRole"


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
