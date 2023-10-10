#!/bin/bash

# Create Directory For raga
mkdir /home/azuser/raga

for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt-get remove $pkg; done
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
# Add the repository to Apt sources:
# echo   "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu" $(. /etc/os-release && echo "$VERSION_CODENAME")" stable" |   sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo -E DEBIAN_FRONTEND=noninteractive bash -c 'echo "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" > /etc/apt/sources.list.d/docker.list'
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Add Docker Compose
sudo apt install -y docker-compose

# Add Az Client
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash


vault_name="az-raga-vault"
secret_name="az-raga-stream"
tenant_id="8d09f28d-2b54-4761-98f1-de38762cd939"
user_app_id="1b036220-2a5b-4b03-a582-2117f7711325"

access_token=$(curl -H Metadata:true "http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https://vault.azure.net" -s | grep -o '"access_token":"[^"]*' | cut -d '"' -f 4)
secret_value=$(curl -X GET "https://${vault_name}.vault.azure.net/secrets/${secret_name}/?api-version=7.2" -H "Authorization: Bearer ${access_token}" -s | grep -o '"value":"[^"]*' | cut -d '"' -f 4)

az login --service-principal --tenant ${tenant_id} -u ${user_app_id} -p ${secret_value}




# Download Docker-compose files
az storage blob download --account-name adevtestlab7019 --container-name scripts --file /home/azuser/raga/docker-compose-optimized.yml --name docker-compose-optimized.yml --account-name adevtestlab7019 --account-key GvSg3qcey0kUXECmR6+CHA/Yzbk/hNrKxm2NMyosEGCFbJ+G6z9JyAZrFwMeqYv/t6gr9XvjZRkn+AStwcThyg==

file_path="/home/azuser/raga/docker-compose-optimized.yml"

if [ -f "$file_path" ]; then
  echo "docker-compose-optimized.yml is present at $file_path"
  chmod -775 /home/azuser/raga/docker-compose-optimized.yml
else
  echo "docker-compose-optimized.yml is not present at $file_path"
fi

# Spin up Kafka Services 
sudo docker-compose -f /home/azuser/raga/docker-compose-optimized.yml up -d

