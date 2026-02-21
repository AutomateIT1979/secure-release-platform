# TAG: AUTOMATION-BATCH-P1-PY
# PURPOSE: FastAPI REST API for Secure Release Platform
# SCOPE: Backend application server
# SAFETY: Input validation on all endpoints, rate limiting recommended

"""
Secure Release Platform - REST API

Framework: FastAPI 0.104.1
Python: 3.12+
Database: PostgreSQL (via SQLAlchemy)
Port: 8000

Endpoints:
  GET  /health              → {"status":"ok"}
  GET  /version             → {"version":"1.0"}
  GET  /projects            → List all projects
  GET  /projects/{id}       → Get single project  
  POST /projects            → Create new project

Tests: pytest (7 passing)
Docs: http://localhost:8000/docs (Swagger UI)

Author: DevOps Developer
Created: 2026-02-08
Updated: 2026-02-17
"""
from fastapi import FastAPI, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from pydantic import BaseModel

from app.database import engine, get_db, Base
from app.models import Project as ProjectModel

# Créer les tables au démarrage
Base.metadata.create_all(bind=engine)

app = FastAPI(title="Secure Release Platform")

# Schémas Pydantic pour validation
class ProjectCreate(BaseModel):
    name: str
    status: str = "planned"

class ProjectResponse(BaseModel):
    id: int
    name: str
    status: str
    
    class Config:
        from_attributes = True

@app.get("/health")
def health():
    return {"status": "ok"}

@app.get("/version")
def version():
    return {
        "version": "1.0.0",
        "commit": "9d1d7c3",
        "build_date": "2026-02-08"
    }

@app.get("/projects", response_model=List[ProjectResponse])
def list_projects(db: Session = Depends(get_db)):
    """Retourne la liste des projets depuis la base de données"""
    projects = db.query(ProjectModel).all()
    return projects

@app.post("/projects", response_model=ProjectResponse, status_code=201)
def create_project(project: ProjectCreate, db: Session = Depends(get_db)):
    """Crée un nouveau projet dans la base de données"""
    db_project = ProjectModel(name=project.name, status=project.status)
    db.add(db_project)
    db.commit()
    db.refresh(db_project)
    return db_project

@app.get("/projects/{project_id}", response_model=ProjectResponse)
def get_project(project_id: int, db: Session = Depends(get_db)):
    """Récupère un projet par son ID"""
    project = db.query(ProjectModel).filter(ProjectModel.id == project_id).first()
    if project is None:
        raise HTTPException(status_code=404, detail="Project not found")
    return project
