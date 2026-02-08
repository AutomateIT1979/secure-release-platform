import os
from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

# Récupérer l'URL de la DB depuis variable d'environnement
DATABASE_URL = os.getenv("DATABASE_URL", "sqlite:///./test.db")

# Créer le moteur SQLAlchemy
engine = create_engine(DATABASE_URL)

# Session pour interagir avec la DB
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Base pour les modèles
Base = declarative_base()

# Dependency pour obtenir une session DB
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
