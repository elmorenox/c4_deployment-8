# Define provider and region
provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region = "us-east-1"  
}

# Create a VPC
resource "aws_vpc" "dep8_vpc" {
  cidr_block = "10.0.0.0/16"  # Specify your desired CIDR block
}

# Defines two specific subnets in us-east-1a and us-east-1b
resource "aws_subnet" "public_subnets" {
  count             = 2
  vpc_id            = aws_vpc.dep8_vpc.id
  cidr_block        = cidrsubnet(aws_vpc.dep8_vpc.cidr_block, 8, count.index)
  availability_zone = element(["us-east-1a", "us-east-1b"], count.index)
  tags = {
    Name = "Dep8Subnets"
  }
}
###INTERNETGATEWAY###
resource "aws_internet_gateway" "D8Gateway" {
  vpc_id = aws_vpc.dep8_vpc.id

  tags = {
    Name = "GW_d8"
  }
}

# Associate subnets with the route table
resource "aws_route_table_association" "subnet_association_a" {
  subnet_id      = aws_subnet.public_subnets[0].id # Subnet in us-east-1a
  route_table_id = aws_route_table.dep8_route_table.id
}

resource "aws_route_table_association" "subnet_association_b" {
  subnet_id      = aws_subnet.public_subnets[1].id # Subnet in us-east-1b
  route_table_id = aws_route_table.dep8_route_table.id
}

resource "aws_route" "internet_gateway_route" {
  route_table_id         = aws_route_table.dep8_route_table.id
  destination_cidr_block = "0.0.0.0/0" # Default route for internet
  gateway_id             = aws_internet_gateway.D8Gateway.id
}

  # Create route table
resource "aws_route_table" "dep8_route_table" {
  vpc_id = aws_vpc.dep8_vpc.id
   tags = {
    Name = "Dep8Route"
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.D8Gateway.id
  }
}

# Create ECS cluster
resource "aws_ecs_cluster" "aws-ecs-cluster" {
  name = "dep8-cluster"
  tags = {
    Name = "dep8-ecs"
  }
}

resource "aws_cloudwatch_log_group" "log-group" {
  name = "/ecs/dep8-logs"

  tags = {
    Application = "dep8-app"
  }
}

# Define ECS task definition for backend
resource "aws_ecs_task_definition" "backend_task" {
  family                   = "backend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = "arn:aws:iam::896099932731:role/dep8-IAM-Role"
  task_role_arn            = "arn:aws:iam::896099932731:role/dep8-IAM-Role"


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

# ECS task definition for frontend
resource "aws_ecs_task_definition" "frontend_task" {
  family                   = "frontend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = "arn:aws:iam::896099932731:role/dep8-IAM-Role"
  task_role_arn            = "arn:aws:iam::896099932731:role/dep8-IAM-Role"


  container_definitions = jsonencode([
    {
      name  = "frontend-container"
      image = "kha1i1/deployment8:FE_image"
      
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

# Create security group for ECS tasks
resource "aws_security_group" "ecs_security_group" {
  vpc_id = aws_vpc.dep8_vpc.id

  # Allow incoming traffic on specified ports
  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create ALB
resource "aws_lb" "dep8_alb" {
  name               = "dep8-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = aws_subnet.public_subnets[*].id
  security_groups    = [aws_security_group.ecs_security_group.id]
}
