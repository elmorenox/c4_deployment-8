# Define provider and region
provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region = "us-east-1"  
}

# Create ALB
resource "aws_lb" "dep8_alb" {
  name               = "dep8-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = aws_subnet.public_subnets[*].id
  security_groups    = [aws_security_group.ecs_security_group.id]
}
