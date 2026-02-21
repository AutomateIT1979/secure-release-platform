# TAG: INFRASTRUCTURE-DEPLOY-P2-DK
# PURPOSE: Build FastAPI application container for production
# SCOPE: Production Docker image
# SAFETY: Use secrets from environment variables, never hardcode

# Build FastAPI application container
# - Base: Python 3.12 slim
# - Port: 8000
# - Health check: /health endpoint
# - Dependencies: see requirements.txt
FROM python:3.11-slim

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app ./app
EXPOSE 8000

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
