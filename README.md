# DevOps Task Manager

This repository houses the code, infrastructure configurations, and automation resources for deploying and monitoring the **Task Manager** application. 

The architecture is split into a **One-Time Infrastructure Setup** phase (using Terraform to launch a minimal AWS EC2 instance running `k3s` container orchestration) and a **Lightweight Recurring CI/CD Pipeline** (using a local Windows Jenkins server deploying remotely). Cluster monitoring runs locally on the developer's machine via a **hybrid observability stack** to avoid overloading the virtual server.

For the comprehensive technical specification, design details, port maps, and in-depth troubleshooting logs, please refer to the main [PROJECT_REPORT.md](PROJECT_REPORT.md) or the compiled [PROJECT_REPORT.pdf](PROJECT_REPORT.pdf).

---

## Repository Map

- `/app` — Frontend user interface built using Vite + React.
- `/docker` — Contains the `Dockerfile` used by Jenkins to build the containerized Nginx-hosted production bundle.
- `/jenkins` — Stores the `Jenkinsfile` executing local-to-remote deployment commands.
- `/k8s` — Kubernetes manifests for deployment, application service routing, and the `kube-state-metrics` cluster agent.
- `/monitoring` — Scrape and container-compose configurations for running Prometheus and Grafana locally.
- `/terraform` — Declarative Infrastructure as Code (IaC) configuration files provisioning the AWS EC2 node.

---

## Onboarding Quickstart

### 1. Provision Infrastructure (One-Time)
Run Terraform inside the `/terraform` folder to deploy the host machine:
```bash
cd terraform
terraform init
terraform apply -auto-approve
```

### 2. Configure Local Observatory Stack (Hybrid Monitoring)
1. Edit the `/monitoring/prometheus-local.yml` configuration and verify that target IP addresses match your active AWS EC2 node public IP address.
2. Spin up the containers from the `/monitoring` folder:
   ```bash
   cd monitoring
   docker compose up -d
   ```
3. View the local metrics UI:
   - Prometheus: `http://localhost:9091`
   - Grafana: `http://localhost:3000`

### 3. Deploy App Updates
The recurrent deployment flow runs automatically inside your local Jenkins server on every source push. 

To run manually:
Trigger a manual build on the **devops-task-manager** project inside the Jenkins dashboard. Jenkins will automatically fetch the latest code, build/push the Docker image, copy the manifests, and roll out the update on the remote k3s cluster.
