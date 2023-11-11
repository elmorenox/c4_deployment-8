# Define provider and region
provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region = "us-east-1"  
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

# ALB Listener for Backend
resource "aws_lb_listener" "backend_listener" {
  load_balancer_arn = aws_lb.dep8_alb.arn
  port              = 8000
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }
}

output "alb_url" {
  value = "http://${aws_lb.dep8_alb.dns_name}"
}