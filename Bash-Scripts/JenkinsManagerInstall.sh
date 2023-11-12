#!/bin/bash

# Update local packages
sudo apt update

# Install Python
sudo apt install -y python3.10 python3.10-venv python3-pip unzip 

# Install required packages
sudo apt-get install -y fontconfig openjdk-17-jre

# Add the Jenkins repository key to the system
curl -fsSL https://pkg.jenkins.io/debian/jenkins.io-2023.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null

# Add Jenkins apt repository entry
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

# Update local packages
sudo apt update

# Install Jenkins
sudo apt-get install -y jenkins

sudo systemctl start jenkins

sudo systemctl enable jenkins

sudo cat /var/lib/jenkins/secrets/initialAdminPassword


# Update package list and install required packages
sudo apt update
sudo apt install -y default-jre software-properties-common

# Add the deadsnakes PPA for Python 3.9
sudo add-apt-repository -y ppa:deadsnakes/ppa
sudo apt update

# Install Python 3.9 and Python 3.9 virtual environment
sudo apt install -y python3.9 python3.9-venv

# Print the installed Python version
python3.9 --version


