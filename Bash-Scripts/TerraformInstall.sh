#!/bin/bash

# Update the package lists to include the latest package information.
sudo apt update

# Install OpenJDK 11 Runtime Environment without asking for user confirmation.
sudo apt install -y openjdk-11-jre

# Download the HashiCorp GPG key, add it to the system's keyrings, and save it as hashicorp-archive-keyring.gpg.
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg

# Add the HashiCorp repository to the system's package sources list by creating a new file named hashicorp.list.
# This file specifies the repository location and uses the GPG key for verification.
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

# Update the package lists again, this time including the HashiCorp repository information.
sudo apt update

# Install Terraform using the updated package lists from the HashiCorp repository.
sudo apt-get install terraform
