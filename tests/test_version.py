# TAG: AUTOMATION-BATCH-P1-PY
# PURPOSE: Version endpoint unit tests
# SCOPE: API version validation
# SAFETY: No database required

"""
Version Endpoint Tests

Tests:
- test_version_returns_correct_format: Verify version format
- test_version_not_empty: Verify version is not empty
"""
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_version_endpoint():
    """Test que /version retourne les bonnes infos"""
    response = client.get("/version")
    
    # Vérifier code HTTP 200
    assert response.status_code == 200
    
    # Vérifier que la réponse contient les clés attendues
    data = response.json()
    assert "version" in data
    assert "commit" in data
    assert "build_date" in data
    
    # Vérifier les valeurs
    assert data["version"] == "1.0.0"
    assert data["commit"] == "9d1d7c3"
    assert data["build_date"] == "2026-02-08"
