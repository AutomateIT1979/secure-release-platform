from sqlalchemy import Column, Integer, String
from app.database import Base

class Project(Base):
    __tablename__ = "projects"
    
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    status = Column(String, nullable=False, default="planned")
    
    def __repr__(self):
        return f"<Project(id={self.id}, name='{self.name}', status='{self.status}')>"
