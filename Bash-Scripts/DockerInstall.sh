#!/bin/bash

# Update package lists and upgrade existing packages
sudo apt update
sudo apt upgrade -y

# Install default Java Runtime Environment (JRE)
sudo apt install -y default-jre

# Install software-properties-common for managing software repositories
sudo apt install -y software-properties-common

# Add the deadsnakes PPA for Python versions
sudo add-apt-repository -y ppa:deadsnakes/ppa

# Install Python 3.9 and venv (virtual environment) for Python 3.9
sudo apt install -y python3.9
sudo apt install -y python3.9-venv

# Install essential build tools for compiling software
sudo apt install -y build-essential

# Install development files for the MySQL client library
sudo apt install -y libmysqlclient-dev

# Install development headers for Python 3.9
sudo apt install -y python3.9-dev

# Update package lists and install necessary tools for HTTPS-based repositories
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg

# Fetch and install Docker's official GPG key
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add Docker repository to system's sources list
echo "deb [arch=\"$(dpkg --print-architecture)\" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo \"$VERSION_CODENAME\") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update package lists after adding the Docker repository
sudo apt-get update

# Install Docker CE, Docker CLI, containerd.io, and Docker plugins
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
