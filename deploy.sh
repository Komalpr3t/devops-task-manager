#!/bin/bash
set -e

REGION="us-east-1"
INSTANCE_TAG="Task-Manager-K3s-Node"
DOCKER_IMAGE="komalpreet1703/task-manager"
SSH_KEY_PATH="task-manager.pem"
USER="ubuntu"

EC2_IP=$(aws ec2 describe-instances \
    --region "$REGION" \
    --filters "Name=tag:Name,Values=$INSTANCE_TAG" "Name=instance-state-name,Values=running" \
    --query "Reservations[*].Instances[*].PublicIpAddress" \
    --output text)

if [ -z "$EC2_IP" ] || [ "$EC2_IP" == "None" ]; then
    echo "ERROR: No running EC2 instance found with tag '${INSTANCE_TAG}'"
    exit 1
fi

IMAGE_TAG="latest"
if [ ! -z "$1" ]; then
    IMAGE_TAG="$1"
fi

if [[ "$OSTYPE" == "darwin"* ]]; then
  sed -i '' "s|image: .*|image: ${DOCKER_IMAGE}:${IMAGE_TAG}|g" k8s/deployment.yaml
else
  sed -i "s|image: .*|image: ${DOCKER_IMAGE}:${IMAGE_TAG}|g" k8s/deployment.yaml
fi

scp -i "$SSH_KEY_PATH" -o StrictHostKeyChecking=no -r k8s ${USER}@${EC2_IP}:/home/ubuntu/

ssh -i "$SSH_KEY_PATH" -o StrictHostKeyChecking=no ${USER}@${EC2_IP} "
    export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
    kubectl apply -f /home/ubuntu/k8s/
    kubectl rollout status deployment/task-manager
    kubectl get pods -l app=task-manager
    kubectl get svc task-manager-service
"
