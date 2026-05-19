# DevOps Task Manager

A complete demonstration of a modern React frontend application deployed using a robust DevOps pipeline. This project includes Infrastructure as Code (Terraform), Containerization (Docker), Orchestration (Kubernetes/k3s), CI/CD (Jenkins), and Observability (Prometheus & Grafana).

## Project Structure

```text
devops-task-manager/
├── app/                  # React app (Vite + React + Vanilla CSS)
├── docker/               # Dockerfile and configurations
├── k8s/                  # Kubernetes Deployment and Service manifests
├── terraform/            # AWS EC2 Infrastructure as Code (provisions K3s)
├── jenkins/              # Jenkinsfile for CI/CD pipeline
└── monitoring/           # Prometheus + Grafana configs
```

## Setup Instructions

### 1. Local Development (React App)
Navigate to the `app` directory to run the beautiful Task Manager UI locally.
```bash
cd app
npm install
npm run dev
```

### 2. Infrastructure Provisioning
Use Terraform to spin up an AWS EC2 instance. The `user_data` script automatically installs Docker and a single-node `k3s` cluster.
```bash
cd terraform
terraform init
terraform apply
```

### 3. CI/CD Pipeline
Configure your external Jenkins server:
1. Ensure the Jenkins runner has Docker and `kubectl` installed.
2. Add Docker Hub credentials (`dockerhub-credentials`) and k3s Kubeconfig (`k3s-kubeconfig`) to Jenkins Credentials.
3. Create a Pipeline job pointing to the `jenkins/Jenkinsfile` in this repository.

### 4. Monitoring setup
Apply the Prometheus and Grafana manifests to the k3s cluster.
```bash
kubectl apply -f monitoring/prometheus.yaml
kubectl apply -f monitoring/grafana.yaml
```
- Prometheus will be accessible at `http://<EC2_PUBLIC_IP>:30090`
- Grafana will be accessible at `http://<EC2_PUBLIC_IP>:30030` (Default login: admin/admin123)

## Architecture Overview
- **Frontend**: A highly polished, responsive React application.
- **Docker**: A multi-stage build using Node.js for compilation and Nginx for serving static files.
- **Terraform**: Automates the creation of AWS EC2 instances, security groups, and bootstraps k3s.
- **Kubernetes**: Manages the deployment, scaling, and networking of the application and monitoring stack.
- **Jenkins**: Automates the transition from code commit to cluster deployment.
