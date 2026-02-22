# TAG: AUTOMATION-APPLICATION-API
# PURPOSE: FastAPI application with CRUD operations and observability
# SCOPE: REST API for project management with Prometheus metrics
# SAFETY: Health checks, database connection handling, metrics exposition

from fastapi import FastAPI, HTTPException, Depends, Response
from sqlalchemy.orm import Session
from typing import List

from app.database import SessionLocal, engine
from app.models import Base, Project

# Prometheus instrumentation
from prometheus_fastapi_instrumentator import Instrumentator
from prometheus_client import CONTENT_TYPE_LATEST, generate_latest

# Create database tables
Base.metadata.create_all(bind=engine)

# Initialize FastAPI app
app = FastAPI(
    title="Secure Release Platform API",
    description="API for managing software releases with DevSecOps practices",
    version="1.0.0"
)

# Initialize and instrument Prometheus
Instrumentator().instrument(app)

# Manual metrics endpoint (instead of .expose())
@app.get("/metrics")
async def metrics():
    """Prometheus metrics endpoint"""
    return Response(generate_latest(), media_type=CONTENT_TYPE_LATEST)

# Dependency
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@app.get("/health")
def health():
    """Health check endpoint"""
    return {"status": "ok"}

@app.get("/version")
def version():
    """Version endpoint"""
    return {"version": "1.0.0", "name": "Secure Release Platform"}

@app.get("/projects", response_model=List[dict])
def get_projects(db: Session = Depends(get_db)):
    """Get all projects"""
    projects = db.query(Project).all()
    return [{"id": p.id, "name": p.name, "description": p.description} for p in projects]

@app.post("/projects", response_model=dict, status_code=201)
def create_project(name: str, description: str = "", db: Session = Depends(get_db)):
    """Create a new project"""
    project = Project(name=name, description=description)
    db.add(project)
    db.commit()
    db.refresh(project)
    return {"id": project.id, "name": project.name, "description": project.description}

@app.get("/projects/{project_id}", response_model=dict)
def get_project(project_id: int, db: Session = Depends(get_db)):
    """Get a specific project by ID"""
    project = db.query(Project).filter(Project.id == project_id).first()
    if not project:
        raise HTTPException(status_code=404, detail="Project not found")
    return {"id": project.id, "name": project.name, "description": project.description}
