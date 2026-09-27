from flask import Flask, request, jsonify
from prometheus_client import start_http_server, Counter, Histogram
import time
import random

app = Flask(__name__)


# ============================================
# CUSTOM SRE METRICS
# ============================================
TOKEN_COUNT = Counter(
    'ai_tokens_processed_total',
    'Total volume of LLM tokens generated',
    ['model']
)

LATENCY_SECS = Histogram(
    'ai_inference_duration_seconds',
    'Inference round-trip runtime latency',
    ['model'],
    buckets=(0.1, 0.25, 0.5, 1.0, 2.0, 5.0, float("inf"))
)

BILLING_COST = Counter(
    'ai_infrastructure_cost_usd',
    'Calculated cloud running cost parameter',
    ['model']
)


@app.route('/health', methods=['GET'])
def health():
    """Health check endpoint for monitoring."""
    return jsonify({"status": "healthy", "service": "ai-inference-api"}), 200


@app.route('/v1/models/predict', methods=['POST'])
def predict():
    """Simulated LLM inference endpoint."""
    start_time = time.time()
    data = request.json or {}
    model = data.get("model", "mistral-7b")
    prompt = data.get("prompt", "")

    # Simulate AI processing delay
    execution_delay = random.uniform(0.15, 1.10)
    time.sleep(execution_delay)

    # Simulate token generation
    generated_tokens = random.randint(30, 180)
    simulated_cost = (generated_tokens / 1000) * 0.0015

    # Record metrics
    TOKEN_COUNT.labels(model=model).inc(generated_tokens)
    LATENCY_SECS.labels(model=model).observe(time.time() - start_time)
    BILLING_COST.labels(model=model).inc(simulated_cost)

    return jsonify({
        "response": f"Inference output for: '{prompt[:50]}'",
        "model": model,
        "tokens": generated_tokens,
        "latency_seconds": round(time.time() - start_time, 3),
        "cost_usd": round(simulated_cost, 6)
    })


if __name__ == '__main__':
    start_http_server(8000)
    print("[INFO] Prometheus metrics server running on port 8000")
    app.run(host='0.0.0.0', port=5000)