# Local Monitoring & Remote Observability Architecture

This directory contains the files needed to run **Prometheus** and **Grafana** locally on your developer machine, scraping metrics from the remote **AWS EC2 k3s Cluster**.

---

## 1. Setup Exporters on remote EC2 Node

To allow your local Prometheus to gather cluster and host statistics, configure the following lightweight exporters:

### 1.1 Node Exporter (Host Metrics)
Connect to your EC2 instance via SSH and run:
```bash
wget https://github.com/prometheus/node_exporter/releases/download/v1.7.0/node_exporter-1.7.0.linux-amd64.tar.gz
tar -xvf node_exporter-1.7.0.linux-amd64.tar.gz
sudo mv node_exporter-1.7.0.linux-amd64/node_exporter /usr/local/bin/

sudo tee /etc/systemd/system/node_exporter.service <<EOF
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=ubuntu
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now node_exporter
```
Verification command:
```bash
curl http://localhost:9100/metrics
```

### 1.2 Kube-State-Metrics (Cluster State Metrics)
The manifest file `k8s/kube-state-metrics.yaml` is deployed automatically when the CI/CD pipeline applies the `k8s/` directory. It exposes metrics on NodePort `30091`.
Manual deployment (optional):
```bash
kubectl apply -f ../k8s/kube-state-metrics.yaml
```
Verification command:
```bash
kubectl get svc -n kube-system kube-state-metrics
```

---

## 2. Start Local Observability Stack

On your local Windows machine:

1. **Configure Target IP:** Open `monitoring/prometheus-local.yml` and replace `<REMOTE-EC2-PUBLIC-IP>` with your EC2 public IP address.
2. **Start Containers:** Run the following command inside this directory:
   ```bash
   docker compose up -d
   ```
3. **Access Interfaces:**
   - **Prometheus UI:** `http://localhost:9090`
   - **Grafana Dashboard:** `http://localhost:3000` (Default: `admin` / `admin123`)
