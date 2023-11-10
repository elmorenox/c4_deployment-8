###Provider###
provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region = "us-east-1"
}

###VPC###
resource "aws_default_vpc" "default" {}

###SECURITYGROUP###
resource "aws_security_group" "Dep8_SG" {
  name        = "Dep8_SG"
  description = "open ssh traffic"
  vpc_id      = aws_default_vpc.default.id

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

tags = {
    "Name" : "Deployment_8_Security_Group"
    "Terraform" : "true"
  }

}

###INSTANCE1###
resource "aws_instance" "JenkinsManager" {
  ami                         = "ami-08c40ec9ead489470"
  instance_type               = "t2.micro"
  availability_zone           = "us-east-1a"
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.Dep8_SG.id] 
  key_name                    = "Dep8KeyPair"
  user_data                   = file("JenkinsManagerInstall.sh")
    tags = {
    "Name" : "Dep8_JenkinsManager"
  }
}

###INSTANCE2###
resource "aws_instance" "JenkinsAgent" {
  ami                         = "ami-08c40ec9ead489470"
  instance_type               = "t2.micro"
  availability_zone           = "us-east-1a"
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.Dep8_SG.id]
  key_name                    = "Dep8KeyPair"
  user_data                   = file("DockerInstall.sh")
    tags = {
    "Name" : "Dep8_Docker"
  }
}

###INSTANCE3###
resource "aws_instance" "JenkinsAgent2" {
  ami                         = "ami-08c40ec9ead489470"
  instance_type               = "t2.micro"
  availability_zone           = "us-east-1a"
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.Dep8_SG.id]
  key_name                    = "Dep8KeyPair"
  user_data                   = file("TerraformInstall.sh")
    tags = {
    "Name" : "Dep8_Terraform"
  }
}
