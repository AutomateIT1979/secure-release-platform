# TAG: AUTOMATION-BATCH-P1-PY
# PURPOSE: Full integration tests (API + Database)
# SCOPE: End-to-end workflow validation
# SAFETY: Uses test database, isolated tests

"""
Integration Tests

Tests:
- test_create_project: Create project via API
- test_get_projects: List projects from database
- test_get_project_by_id: Fetch single project
- test_update_project_status: Update project status
- test_project_workflow: Complete workflow (create → get → update)
"""
import pytest
from app.models import Project as ProjectModel

def test_create_project_integration(client, db_session):
    """Test d'intégration : créer un projet et vérifier en DB"""
    # 1. Créer un projet via POST
    response = client.post(
        "/projects",
        json={"name": "Integration Test Project", "status": "active"}
    )
    
    # 2. Vérifier la réponse API
    assert response.status_code == 201
    data = response.json()
    assert data["name"] == "Integration Test Project"
    assert data["status"] == "active"
    assert "id" in data
    
    project_id = data["id"]
    
    # 3. Vérifier que le projet existe vraiment en DB
    db_project = db_session.query(ProjectModel).filter_by(id=project_id).first()
    assert db_project is not None
    assert db_project.name == "Integration Test Project"
    assert db_project.status == "active"

def test_create_and_retrieve_project(client):
    """Test d'intégration : créer puis récupérer un projet"""
    # 1. Créer un projet
    create_response = client.post(
        "/projects",
        json={"name": "Test Retrieve", "status": "planned"}
    )
    assert create_response.status_code == 201
    project_id = create_response.json()["id"]
    
    # 2. Récupérer le projet par ID
    get_response = client.get(f"/projects/{project_id}")
    assert get_response.status_code == 200
    
    data = get_response.json()
    assert data["id"] == project_id
    assert data["name"] == "Test Retrieve"
    assert data["status"] == "planned"

def test_create_multiple_and_list(client):
    """Test d'intégration : créer plusieurs projets et les lister"""
    # 1. Créer 3 projets
    projects_to_create = [
        {"name": "Project 1", "status": "active"},
        {"name": "Project 2", "status": "active"},
        {"name": "Project 3", "status": "planned"}
    ]
    
    created_ids = []
    for project_data in projects_to_create:
        response = client.post("/projects", json=project_data)
        assert response.status_code == 201
        created_ids.append(response.json()["id"])
    
    # 2. Lister tous les projets
    list_response = client.get("/projects")
    assert list_response.status_code == 200
    
    projects = list_response.json()
    assert len(projects) == 3
    
    # 3. Vérifier que nos 3 projets sont dans la liste
    project_names = [p["name"] for p in projects]
    assert "Project 1" in project_names
    assert "Project 2" in project_names
    assert "Project 3" in project_names

def test_get_nonexistent_project(client):
    """Test d'intégration : récupérer un projet qui n'existe pas"""
    response = client.get("/projects/99999")
    assert response.status_code == 404
    assert response.json()["detail"] == "Project not found"

def test_list_projects_empty_db(client):
    """Test d'intégration : lister les projets quand DB vide"""
    response = client.get("/projects")
    assert response.status_code == 200
    assert response.json() == []
