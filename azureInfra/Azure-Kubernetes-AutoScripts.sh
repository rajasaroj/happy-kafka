#!/bin/bash

# Create Kubernetes cluster with below specifications:
# --load-balancer-sku => Load balancer type: basic (Because firm policy restrict standard one which creates public ips)
# --attach-acr        => Intergrated ACR: because all of our images stored here from Azure pipeline
# --vnet-subnet-id    => Specific Vnet and Subnet: vnet=infrastructure and subnet=default-1
az aks create --resource-group az-raga-poc --name az-raga-etm-kube --node-count 2 --enable-addons monitoring --generate-ssh-keys --attach-acr ragaetmdemo --load-balancer-sku basic --vnet-subnet-id /subscriptions/2b662324-593f-4cb9-9e69-7c7ca8916694/resourceGroups/infrastructure/providers/Microsoft.Network/virtualNetworks/default/subnets/default-1

# IInstall the Kubernetes CLI
az aks install-cli

# Connect to cluster using kubectl
az aks get-credentials --resource-group az-raga-poc --name az-raga-etm-kube

# Create Secrets to Authenticate Your AKS Cluster with ACR
kubectl create secret docker-registry acr-secret --docker-server ragaetmdemo.azurecr.io.azurecr.io --docker-username ragaetmdemo --docker-password eU3sRXcQYJhMPrhWHQhW6RbUEip/xsK0bLExfbgjFG+ACRAvhE9s
output: secret/acr-secret created

# Upload the kubernetes Deployment:
kubectl apply -f azure-kubernetes-deployment.yml

# Pods logs 
kubectl logs -f az-raga-kafka-producer-deployment-c67dbfc55-kwsxc -c ragaetmdemo





################################ For Testing And Debugging ##################################################################

# Get Acr login server and container registry name
az acr list --resource-group az-raga-poc --query "[].{acrLoginServer:loginServer}" --output table
output:
AcrLoginServer
----------------------
ragaetmdemo.azurecr.io

# Get Images details from ACR
az acr repository list --name ragaetmdemo
az acr repository show-tags --name ragaetmdemo --repository happykafkapoc


# For Testing Purpose
# Docker login to acr
docker login ragaetmdemo.azurecr.io -u ragaetmdemo -p eU3sRXcQYJhMPrhWHQhW6RbUEip/xsK0bLExfbgjFG+ACRAvhE9s
docker pull ragaetmdemo.azurecr.io/happykafkapoc:46
docker run -d --name kafka-producer -p 8080:80 ragaetmdemo.azurecr.io/happykafkapoc:46
