# Valeton GP-50 editor backend — for ECS/Fargate behind an ALB.
# Serves the full FastAPI app (UI + /api/device/* incl. the AI patch endpoint).
# Inventory loads from the committed factory snapshot (app/static/data/presets.json)
# when no pedal / local exports are present, so the container is self-sufficient.
# AWS creds come from the task role; AWS_REGION + BEDROCK_MODEL_ID via env.
FROM python:3.12-slim

WORKDIR /srv
ENV PYTHONUNBUFFERED=1 PIP_NO_CACHE_DIR=1

COPY requirements-app.txt .
RUN pip install -r requirements-app.txt

# product code + the bundled catalog/snapshot data
COPY app ./app
COPY patch ./patch

EXPOSE 8756
# ALB health check hits GET /health
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8756"]
