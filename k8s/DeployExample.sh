#!/bin/bash

# Change Current Directory
cd $(dirname $0)

# Set Docker Registry
export REGISTRY_SERVER
export REGISTRY_USER
export REGISTRY_PASS
export REGISTRY=$REGISTRY_SERVER

cd ../compose

# Build Docker Images
docker compose build dind ssh vscode

# Tag Docker Image For Push Registry
docker tag dind:latest $REGISTRY/dind:latest
docker tag ssh:latest $REGISTRY/ssh:latest
docker tag vscode:latest $REGISTRY/vscode:latest

# Push Docker Image
docker push $REGISTRY/dind:latest
docker push $REGISTRY/ssh:latest
docker push $REGISTRY/vscode:latest

cd ../k8s

# Deploy NameSpace
kubectl apply -f DevEnvNS.yml

# Deploy Docker Registry Secret
kubectl -n dev-env create secret docker-registry my-registry \
  --docker-server=$REGISTRY_SERVER  \
  --docker-username=$REGISTRY_USER \
  --docker-password=$REGISTRY_PASS

# Deploy PVCs
kubectl apply -f common/CommonPVC.yml
kubectl apply -f Dind/DindPVC.yml
kubectl apply -f VSCode/VSCodePVC.yml

# Deploy Secrets
# kubectl apply -f common/CommonSecret.yml
kubectl apply -f common/CommonSecretExample.yml
# kubectl apply -f Oauth2Proxy/Oauth2ProxySecret.yml
kubectl apply -f Oauth2Proxy/Oauth2ProxySecretExample.yml
# kubectl apply -f Ssh/SshSecret.yml
kubectl apply -f Ssh/SshSecretExample.yml

# Deploy Apps
# kubectl apply -f Oauth2Proxy/Oauth2ProxyConfig.yml
kubectl apply -f Oauth2Proxy/Oauth2ProxyConfigExample.yml

# Deploy Apps
# kubectl apply -f Dind/Dind.yml
kubectl apply -f Dind/DindExample.yml
# kubectl apply -f Ssh/Ssh.yml
kubectl apply -f Ssh/SshExample.yml
# kubectl apply -f VSCode/VSCode.yml
kubectl apply -f VSCode/VSCodeExample.yml
kubectl apply -f Oauth2Proxy/Oauth2Proxy.yml