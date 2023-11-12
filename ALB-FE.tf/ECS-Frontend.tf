# ECS task definition for frontend

resource "aws_ecs_task_definition" "frontend_task" {
  family                   = "frontend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = "arn:aws:iam::896099932731:role/ecstaskExecutionrole"
  task_role_arn            = "arn:aws:iam::896099932731:role/ecstaskExecutionrole"


  container_definitions = <<EOF
  [
  {
      "name": "d8_frontend_container",
      "image": "morenodoesinfra/d8-frontend:latest",
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/dep8-logs",
          "awslogs-region": "us-east-1",
          "awslogs-stream-prefix": "ecs"
        }
      },
      "portMappings": [
        {
          "containerPort": 3000,
          "appProtocol": "http"
        }
      ]
    }
  ]
  EOF
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
    assign_public_ip = true
  }

    load_balancer {
    target_group_arn = aws_lb_target_group.frontend.arn
    container_name   = "d8_frontend_container"
    container_port   = 3000
  }
  
  depends_on = [aws_lb_target_group.frontend]
}


# Target Group for Frontend
resource "aws_lb_target_group" "frontend" {
  name        = "dep8-frontend-app"
  port        = 3000
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.dep8_vpc.id

  health_check {
    enabled = true
    path    = "/"
  }

  depends_on = [aws_lb.dep8_alb]
}

# Application Load Balancer
resource "aws_lb" "dep8_alb" {
  name               = "dep8-alb"
  internal           = false
  load_balancer_type = "application"

  subnets = [
    aws_subnet.public_subnets[0].id,
    aws_subnet.public_subnets[1].id,
  ]

  security_groups = [
    aws_security_group.ecs_security_group.id,
  ]

  depends_on = [aws_internet_gateway.D8Gateway]
}

# ALB Listener for frontend
resource "aws_lb_listener" "frontend_listener" {
  load_balancer_arn = aws_lb.dep8_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }
}

output "alb_url" {
  value = "http://${aws_lb.dep8_alb.dns_name}"
}
