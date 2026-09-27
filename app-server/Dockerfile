# Stage 1: Builder
FROM python:3.12-slim AS builder

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir --user -r requirements.txt

# Stage 2: Runtime
FROM python:3.12-slim

RUN useradd -m -u 1001 appuser

WORKDIR /app

COPY --from=builder /root/.local /home/appuser/.local
COPY app.py .

ENV PATH=/home/appuser/.local/bin:$PATH

USER appuser

EXPOSE 5000 8000

CMD ["python", "app.py"]