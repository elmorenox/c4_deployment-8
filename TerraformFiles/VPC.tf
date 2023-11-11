# Create a VPC
resource "aws_vpc" "dep8_vpc" {
  cidr_block = "172.28.0.0/16"  
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
