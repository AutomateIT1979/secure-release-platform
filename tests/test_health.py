# TAG: AUTOMATION-BATCH-P1-PY
# PURPOSE: Health endpoint unit tests
# SCOPE: API health check validation
# SAFETY: No database required

"""
Health Endpoint Tests

Tests:
- test_health_returns_ok: Verify /health returns {"status":"ok"}
- test_health_status_code: Verify HTTP 200 response
"""
from fastapi.testclient import TestClient
from app.main import app

def test_health():
    client = TestClient(app)
    r = client.get("/health")
    assert r.status_code == 200
    assert r.json()["status"] == "ok"
