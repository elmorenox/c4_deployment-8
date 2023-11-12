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
