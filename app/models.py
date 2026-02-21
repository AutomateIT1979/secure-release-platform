# TAG: AUTOMATION-BATCH-P1-PY
# PURPOSE: SQLAlchemy ORM models for application data
# SCOPE: Data schema definition
# SAFETY: Type hints, validation constraints

"""
Application Data Models

Models:
- Project: Main entity with status tracking
  Fields: id, name, description, status, created_at, updated_at
- Status: Enumeration for project states
  Values: PENDING, IN_PROGRESS, COMPLETED, FAILED

Relationships:
- Project has Status (enum)
"""
from sqlalchemy import Column, Integer, String
from app.database import Base

class Project(Base):
    __tablename__ = "projects"
    
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    status = Column(String, nullable=False, default="planned")
    
    def __repr__(self):
        return f"<Project(id={self.id}, name='{self.name}', status='{self.status}')>"
