#!/bin/bash

# Log file path
log_file="/home/azuser/raga/script_log.txt"

# Create Directory For raga
mkdir /home/azuser/raga

# Function to log messages to the log file
log() {
  echo "$(date +"%Y-%m-%d %H:%M:%S"): $1" >> "$log_file"
}

# Log script execution start
log "Script execution started."

for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt-get remove $pkg; done

# Add Docker's official GPG key and log the result
log "Adding Docker's official GPG key..."
sudo apt-get update >> "$log_file" 2>&1
sudo apt-get install -y ca-certificates curl gnupg >> "$log_file" 2>&1
sudo install -m 0755 -d /etc/apt/keyrings >> "$log_file" 2>&1
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg >> "$log_file" 2>&1
sudo chmod a+r /etc/apt/keyrings/docker.gpg >> "$log_file" 2>&1

# Add the repository to Apt sources and log the result
log "Adding Docker repository to Apt sources..."
sudo -E DEBIAN_FRONTEND=noninteractive bash -c 'echo "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" > /etc/apt/sources.list.d/docker.list' >> "$log_file" 2>&1
sudo apt-get update >> "$log_file" 2>&1

# Install Docker and log the result
log "Installing Docker..."
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin >> "$log_file" 2>&1

# Add Docker Compose and log the result
log "Installing Docker Compose..."
sudo apt install -y docker-compose >> "$log_file" 2>&1

# Add Az Client and log the result
log "Installing Azure CLI..."
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash >> "$log_file" 2>&1

# Az Client Login ...
log "Az Client Login CLI..."

vault_name="az-raga-vault"
secret_name="az-raga-stream"
tenant_id="8d09f28d-2b54-4761-98f1-de38762cd939"
user_app_id="1b036220-2a5b-4b03-a582-2117f7711325"

access_token=$(curl -H Metadata:true "http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https://vault.azure.net" -s | grep -o '"access_token":"[^"]*' | cut -d '"' -f 4)
secret_value=$(curl -X GET "https://${vault_name}.vault.azure.net/secrets/${secret_name}/?api-version=7.2" -H "Authorization: Bearer ${access_token}" -s | grep -o '"value":"[^"]*' | cut -d '"' -f 4)

az login --service-principal --tenant ${tenant_id} -u ${user_app_id} -p ${secret_value} >> "$log_file" 2>&1



# Download Docker-compose files
log "Downloading docker-compose-optimized.yml from storage container..."
az storage blob download --account-name adevtestlab7019 --container-name scripts --file /home/azuser/raga/docker-compose-optimized.yml --name docker-compose-optimized.yml --account-name adevtestlab7019 --account-key GvSg3qcey0kUXECmR6+CHA/Yzbk/hNrKxm2NMyosEGCFbJ+G6z9JyAZrFwMeqYv/t6gr9XvjZRkn+AStwcThyg==  >> "$log_file" 2>&1

file_path="/home/azuser/raga/docker-compose-optimized.yml"

if [ -f "$file_path" ]; then
  log "docker-compose-optimized.yml is present at $file_path"
  chmod -775 /home/azuser/raga/docker-compose-optimized.yml
else
  log "docker-compose-optimized.yml is not present at $file_path"
fi

# Log script execution completion
log "Script execution completed."

# Spin up Kafka Services and log the result
log "Starting Kafka Services..."
sudo docker-compose -f /home/azuser/raga/docker-compose-optimized.yml up -d >> "$log_file" 2>&1
