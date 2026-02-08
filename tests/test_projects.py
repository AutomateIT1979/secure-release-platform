from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_list_projects_endpoint():
    """Test que /projects retourne la liste des projets"""
    response = client.get("/projects")
    
    # Vérifier code HTTP 200
    assert response.status_code == 200
    
    # Vérifier structure de la réponse
    data = response.json()
    assert "projects" in data
    assert isinstance(data["projects"], list)
    
    # Vérifier qu'il y a au moins 1 projet
    assert len(data["projects"]) > 0
    
    # Vérifier structure d'un projet
    first_project = data["projects"][0]
    assert "id" in first_project
    assert "name" in first_project
    assert "status" in first_project
    
    # Vérifier les valeurs du premier projet
    assert first_project["id"] == 1
    assert first_project["name"] == "Secure Release Platform"
    assert first_project["status"] == "active"
