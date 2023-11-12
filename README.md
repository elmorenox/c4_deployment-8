# Automated Terraform Deployment Documentation

## Purpose
This documentation provides an overview of deploying an E-commerce application stack. The deployment involves creating a Python script for sensitive information detection, setting up a Jenkins manager and agent architecture, and creating Terraform files for ECS and VPC. Additionally, Docker images for both the backend and frontend are created, and Jenkinsfiles are used to automate the deployment process.

## Issues

## System Diagram

### Step 1: Sensitive Information Detection Script

``` 
#!/usr/bin/python3

import logging
import sys
import re

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(" Credential Checker")

patterns = [
    re.compile(r'(?<!\S)["\']?[0-9a-zA-Z+/]{20}["\']?(?!\S)'),  # Matches any 20 character string with only alphanumeric characters and the characters + and /, optionally enclosed in quotes and directly surrounded by spaces or quotes
    re.compile(r'(?<!\S)["\']?[0-9a-zA-Z+/]{40}["\']?(?!\S)'),  # Matches any 40 character string with only alphanumeric characters and the characters + and /, optionally enclosed in quotes and directly surrounded by spaces or quotes
]


def contains_credentials(file_content):
    for pattern in patterns:
        if pattern.search(file_content):
            return True
    return False


def main():
    exit_code = 0
    files = sys.argv[1:]
    for local_file in files:
        try:
            with open(local_file, 'r') as f:
                logger.info(f" Checking {local_file} for credentials \n")
                file_content = f.read()
                if contains_credentials(file_content):
                    logger.warning(
                        f" Credentials detected in file: {local_file}"
                    )
                    exit_code = 1
                    for pattern in patterns:
                        matches = pattern.findall(file_content)
                        for match in matches:
                            logger.warning(
                                f" Credentials possible match: {match}"
                            )
        except UnicodeDecodeError:
            pass
        except FileNotFoundError:
            logger.error(f"File not found: {local_file}")

    return exit_code  # Return the exit code


if __name__ == "__main__":
    sys.exit(main())

```

### Step 2: Jenkins Manager and Agent Architecture
Set up a Jenkins manager and agent architecture with the following instances:

[(Working-Enviroment)main.tf](JenkinsTF/(Working-Enviroment)main.tf)

Instance 1:
- Jenkins with Docker pipeline plugin
Instance 2 (T.2 medium):
- Docker
- Default-jre
Instance 3:
- Terraform
- Default-jre

### Step 3: ECS and VPC Terraform Files
Create Terraform files for ECS and VPC with the specified components:
- 2 AZ's
- 2 Public Subnets
- 2 Containers for the frontend
- 1 Container for the backend
- 1 Route Table
- Security Group Ports: 8000, 3000, 80
- 1 ALB

### Step 4: Backend Docker Image
Create a Docker image for the backend on a T.2 medium using the following steps:
```
# Python runtime as a base image
FROM python:3.9

# Set the working directory in the container
WORKDIR /app

# Clone Github repo into the container
RUN git clone https://github.com/elmorenox/c4_deployment-8.git

# Change the working directory to the 'backend' folder
WORKDIR /app/c4_deployment-8/backend

# Install the Python dependencies from requirements.txt
RUN pip install -r requirements.txt

# Run the Django database migration
RUN python manage.py migrate

# Expose port 8000 for the Django development server
EXPOSE 8000

# Start the Django development server 
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
```

### Step 5: Frontend Docker Image
Create a Docker image for the frontend on a T.2 medium using the following steps:
```
# Used Node.js runtime as a base image
FROM node:10

# Set the working directory in the container
WORKDIR /frontend

#copy cur dir to container
COPY . /frontend

# Install Node.js dependencies
RUN npm install 
RUN npm install --save-dev @babel/plugin-proposal-private-property-in-object

# Expose port 3000 for the Node.js application
EXPOSE 3000

# Start the Node.js application
CMD ["npm", "start"]
```

### Step 6: Jenkinsfiles
Create two Jenkinsfiles for deploying the backend and frontend ECS Terraform files:

Jenkinsfile_backend
```
insert code here
```

Jenkinsfile_frontend
```
insert code here
```

### Step 7: Application Stack and API Server
The application stack consists of a backend and frontend deployed on ECS with an ALB. The backend serves as an API server running on port 8000.
