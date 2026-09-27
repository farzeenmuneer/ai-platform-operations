# AI Platform Operations: Distributed SRE Architecture using Docker, Prometheus & Karpenter

This project demonstrates an AI inference platform with custom Prometheus telemetry, self-healing Linux systemd services, and Kubernetes autoscaling configs. It simulates how companies serve LLM models at scale while tracking AI-specific SRE metrics.

## Architecture

```
User Prompt → AI Inference API (Flask) → Custom Prometheus Metrics
                                              ↓
                                   Prometheus Scraper (every 5s)
                                              ↓
                                    Grafana Dashboard (visualization)
                                              ↓
                         Bash Health Script → Log Rotation + DB Ping
                                              ↓
                        Karpenter Autoscale → GPU Nodes (Cloud-Ready)
```
---

## Detailed Steps to Execute the Code

### Prerequisites

* Docker Desktop installed and running
* Git Bash (Windows) or Terminal (Mac/Linux)
* Git installed

### 1. Clone the Repository

```bash
git clone https://github.com/YOUR-USERNAME/ai-platform-operations.git
cd ai-platform-operations
```

### 2. Verify Docker is Running

```bash
docker --version
docker ps
```

### 3. Build and Start the Stack

```bash
docker compose up -d --build
```

This starts three containers:
* AI Inference API (port 5000)
* Prometheus (port 9090)
* Grafana (port 3000)

### 4. Verify Containers Are Running

```bash
docker ps
```

You should see 3 containers in `Up` status.

### 5. Test the AI Inference API

```bash
curl -X POST http://localhost:5000/v1/models/predict \
  -H "Content-Type: application/json" \
  -d '{"model":"mistral-7b","prompt":"Explain DevOps"}'
```

Expected output:

```json
{
  "cost_usd": 0.000176,
  "latency_seconds": 1.014,
  "model": "mistral-7b",
  "response": "Inference output for: 'Explain DevOps'",
  "tokens": 117
}
```

### 6. Verify Custom Prometheus Metrics

```bash
curl http://localhost:8000/metrics | grep ai_
```

Expected output:

```text
ai_tokens_processed_total{model="mistral-7b"} 1161.0
ai_inference_duration_seconds_sum{model="mistral-7b"} 12.45
ai_infrastructure_cost_usd{model="mistral-7b"} 0.001742
```

### 7. Open Prometheus UI

Navigate to: http://localhost:9090

Search for: `ai_tokens_processed_total`

Click **Execute** → **Graph** to see the metrics timeline.

### 8. Open Grafana Dashboard

Navigate to: http://localhost:3000


Add Prometheus as a data source:
* URL: `http://prometheus:9090`

Create a panel using `ai_tokens_processed_total`.

### 9. Stop the Stack

```bash
docker compose down
```

To restart later:

```bash
docker compose up -d
```

---
## Technologies Used

* Python
* Flask 
* Prometheus
* Grafana
* Docker & Docker Compose
* Linux Bash / systemd
* Terraform
* Karpenter v1
* Git & GitHub

## Outputs

* AI Inference API endpoint: http://localhost:5000/v1/models/predict
* Prometheus metrics endpoint: http://localhost:8000/metrics
* Prometheus UI: http://localhost:9090
* Grafana dashboard: http://localhost:3000
* Custom SRE metrics tracked:
  * `ai_tokens_processed_total`
  * `ai_inference_duration_seconds`
  * `ai_infrastructure_cost_usd`
```
