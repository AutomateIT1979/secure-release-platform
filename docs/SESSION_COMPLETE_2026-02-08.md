# Session Complète DevSecOps — 2026-02-08

## 🎯 Vue d'ensemble

**Date** : 2026-02-08  
**Durée totale** : ~3h30  
**Objectif** : Construire une API FastAPI complète avec PostgreSQL, tests automatisés, et comprendre DevSecOps  

**Résultat** : 
- ✅ Jalon 1 complété (MVP local)
- ✅ API fonctionnelle avec base de données
- ✅ 10 commits Git propres
- ✅ Documentation complète (1000+ lignes)

---

## 📚 Structure de la session

### Session 1 : Audit et MVP local (12h30-14h10)
**Durée** : 1h40  
**Fichiers clés** : `docs/LAB_STATE.md`, `docs/GUIDE_COMPREHENSION.md`

### Session 2 : Pratique routes/Docker/Git (14h10-15h17)
**Durée** : 1h07  
**Fichiers clés** : `docs/SESSION_PRATIQUE_2026-02-08.md`

### Session 3 : PostgreSQL et CRUD (15h17-15h40)
**Durée** : 23min  
**Fichiers clés** : `app/database.py`, `app/models.py`

---

## ✅ Réalisations techniques

### 1) API FastAPI (5 routes)

#### Routes implémentées
```
GET  /health              → Healthcheck
GET  /version             → Version applicative
GET  /projects            → Liste tous les projets (depuis DB)
POST /projects            → Crée un nouveau projet (dans DB)
GET  /projects/{id}       → Récupère un projet par ID (depuis DB)
```

#### Fichier : `app/main.py`
```python
from fastapi import FastAPI, Depends, HTTPException
from sqlalchemy.orm import Session
from app.database import engine, get_db, Base
from app.models import Project as ProjectModel

# Créer les tables au démarrage
Base.metadata.create_all(bind=engine)

app = FastAPI(title="Secure Release Platform")

# Routes avec base de données
@app.get("/projects", response_model=List[ProjectResponse])
def list_projects(db: Session = Depends(get_db)):
    projects = db.query(ProjectModel).all()
    return projects

@app.post("/projects", response_model=ProjectResponse, status_code=201)
def create_project(project: ProjectCreate, db: Session = Depends(get_db)):
    db_project = ProjectModel(name=project.name, status=project.status)
    db.add(db_project)
    db.commit()
    db.refresh(db_project)
    return db_project
```

---

### 2) Base de données PostgreSQL

#### Configuration Docker Compose
```yaml
services:
  api:
    build: .
    ports:
      - "8000:8000"
    environment:
      - DATABASE_URL=postgresql://postgres:secretpassword@db:5432/secure_release_db
    depends_on:
      db:
        condition: service_healthy

  db:
    image: postgres:15-alpine
    environment:
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=secretpassword
      - POSTGRES_DB=secure_release_db
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 5s
```

#### Connexion SQLAlchemy : `app/database.py`
```python
import os
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.ext.declarative import declarative_base

DATABASE_URL = os.getenv("DATABASE_URL", "sqlite:///./test.db")
engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
```

#### Modèle Project : `app/models.py`
```python
from sqlalchemy import Column, Integer, String
from app.database import Base

class Project(Base):
    __tablename__ = "projects"
    
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    status = Column(String, nullable=False, default="planned")
```

---

### 3) Tests automatisés (3 tests)

#### Tests unitaires
```python
# tests/test_health.py
def test_health():
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "ok"}

# tests/test_version.py
def test_version_endpoint():
    response = client.get("/version")
    assert response.status_code == 200
    assert "version" in response.json()

# tests/test_projects.py
def test_list_projects_endpoint():
    response = client.get("/projects")
    assert response.status_code == 200
    data = response.json()
    assert "projects" in data or isinstance(data, list)
```

**Résultat** : `3 passed in 0.48s` ✅

---

### 4) Git (10 commits propres)

#### Historique complet
```
49fbd4b feat: add PostgreSQL database with CRUD operations
233e379 docs: add practice session recap (routes, Docker, Git)
28eccfe feat: add /projects endpoint with test
4b6f314 feat: add /version endpoint with test
feae4e7 docs: add session recap and update LAB_STATE (Jalon 1 completed)
9c4cfff docs: add comprehensive guide for understanding the project
9d1d7c3 feat: add FastAPI healthcheck, tests, Docker packaging and pytest config
6e9c1d4 docs: add LAB_STATE.md - complete lab audit (WSL + EC2 + Jenkins)
5bd5571 docs: add runbooks placeholder
8a4eb6b chore: initialize repo structure and documentation
```

#### Convention de commit utilisée
```
<type>: <description courte>

<description détaillée>
```

**Types** : `feat`, `fix`, `docs`, `test`, `refactor`, `chore`

---

## 🎓 Compétences acquises

### Concepts DevSecOps
| Concept | Compréhension | Preuve |
|---------|---------------|--------|
| CI/CD | ✅ Compris | Tests locaux d'abord |
| Infrastructure as Code | ✅ Compris | Docker Compose YAML |
| Test-Driven Development | ✅ Compris | 3 tests automatisés |
| Persistance des données | ✅ Compris | Volume PostgreSQL |
| Microservices | ✅ Compris | API + DB séparés |

### Outils maîtrisés
| Outil | Niveau | Commandes clés |
|-------|--------|----------------|
| Git | ⭐⭐⭐ | status, diff, add, commit, log |
| Docker | ⭐⭐⭐ | up --build, down, logs, ps |
| pytest | ⭐⭐ | pytest -v, -q |
| FastAPI | ⭐⭐⭐ | routes, Depends, HTTPException |
| SQLAlchemy | ⭐⭐ | models, sessions, queries |
| PostgreSQL | ⭐⭐ | Connexion via SQLAlchemy |

---

## 💡 Moments "déclic" (breakthroughs)

### 1) Routes HTTP ≠ Dossiers
**Avant** : "Une route `/health` est un dossier ?"  
**Après** : "Non ! C'est une adresse web dans l'API, comme google.com/search"

**Preuve** : Swagger UI montrant les routes visuellement

---

### 2) Git : Les 3 zones
**Avant** : "Git c'est juste save ?"  
**Après** : "Non ! Working → Staging (git add) → Repository (git commit)"

**Preuve** : `git status` montrant les fichiers dans chaque zone

---

### 3) Docker rebuild obligatoire
**Avant** : "Pourquoi ma nouvelle route ne marche pas ?"  
**Après** : "`docker compose restart` ne rebuild pas, il faut `--build`"

**Preuve** : Route `/version` invisible tant qu'on n'a pas rebuild

---

### 4) Persistance avec volumes Docker
**Avant** : "Les données disparaissent au redémarrage ?"  
**Après** : "Non ! Volume Docker = stockage permanent sur disque"

**Preuve** : Après `docker compose down`, les 6 projets sont toujours là

---

## 📊 Métriques de la journée

### Code
- **Lignes de code Python** : ~150 lignes
- **Lignes de tests** : ~70 lignes
- **Lignes de config** : ~50 lignes (Docker, requirements)
- **Lignes de documentation** : 1000+ lignes

### Git
- **Commits** : 10
- **Fichiers versionnés** : 17
- **Branches** : 1 (main)

### Docker
- **Images** : 2 (API custom, PostgreSQL)
- **Conteneurs** : 2
- **Volumes** : 1 (postgres_data)
- **Réseaux** : 1 (app-network)

### API
- **Routes** : 5
- **Modèles SQLAlchemy** : 1 (Project)
- **Schémas Pydantic** : 2 (ProjectCreate, ProjectResponse)

---

## 🔍 Problèmes rencontrés et résolus

### Problème 1 : pytest ne trouve pas le module `app`
**Symptôme** : `ModuleNotFoundError: No module named 'app'`  
**Cause** : pytest ne cherche pas dans la racine du projet  
**Solution** : Créer `pytest.ini` avec `pythonpath = .`

---

### Problème 2 : Route `/version` invisible
**Symptôme** : `curl /version` retourne 404  
**Cause** : Code modifié mais image Docker pas rebuild  
**Solution** : `docker compose up --build` (pas juste `restart`)

---

### Problème 3 : `.env.example` bloqué par `.gitignore`
**Symptôme** : `git add .env.example` → ignored  
**Cause** : Règle `.env.*` trop large dans `.gitignore`  
**Solution** : Supprimer `.env.*`, garder uniquement `.env`

---

### Problème 4 : API crash au démarrage avec PostgreSQL
**Symptôme** : `ModuleNotFoundError: No module named 'psycopg2'`  
**Cause** : Driver PostgreSQL incorrect (`psycopg[binary]`)  
**Solution** : Changer pour `psycopg2-binary==2.9.9`

---

## 🛠️ Commandes essentielles mémorisées

### Git (workflow complet)
```bash
git status                    # Voir l'état (quelle zone)
git diff <fichier>            # Voir modifications ligne par ligne
git add <fichier>             # Zone 1 → Zone 2
git commit -m "message"       # Zone 2 → Zone 3
git log --oneline -n 10       # Historique
```

### Docker (workflow complet)
```bash
docker compose up --build -d  # Build + démarrer (détaché)
docker compose ps             # Voir conteneurs actifs
docker compose logs --tail=20 # Voir logs
docker compose down           # Arrêter et nettoyer
```

### pytest (tests automatisés)
```bash
pytest -v                     # Verbose (détaillé)
pytest -q                     # Quiet (concis)
pytest tests/test_health.py   # Test spécifique
```

### API (tests manuels)
```bash
# GET
curl http://localhost:8000/health

# POST avec JSON
curl -X POST http://localhost:8000/projects \
  -H "Content-Type: application/json" \
  -d '{"name":"Mon Projet","status":"active"}'
```

---

## 📁 Structure finale du projet
```
secure-release-platform/
├── .gitignore
├── README.md
├── .env.example
├── requirements.txt
├── pytest.ini
├── Dockerfile
├── docker-compose.yml
├── app/
│   ├── __init__.py
│   ├── main.py          (5 routes)
│   ├── database.py      (connexion SQLAlchemy)
│   └── models.py        (modèle Project)
├── tests/
│   ├── test_health.py
│   ├── test_version.py
│   └── test_projects.py
└── docs/
    ├── DECISIONS.md
    ├── PROJECT_STATE.md
    ├── ROADMAP.md
    ├── LAB_STATE.md                     (327 lignes)
    ├── GUIDE_COMPREHENSION.md           (700+ lignes)
    ├── SESSION_PRATIQUE_2026-02-08.md   (232 lignes)
    └── SESSION_COMPLETE_2026-02-08.md   (ce fichier)
```

---

## 🚀 Prochaines étapes (Roadmap)

### Jalon 1 bis : Tests d'intégration avec DB (NEXT)
**Objectif** : Tester l'API avec la vraie base de données.

**Actions** :
1. Créer `conftest.py` (fixtures pytest)
2. Modifier tests pour utiliser DB de test
3. Tests d'intégration : POST puis GET

**Temps estimé** : 30-45 min

---

### Jalon 2 : Déploiement sur EC2 (après tests)
**Objectif** : Installer Docker sur EC2 avec Ansible.

**Actions** :
1. Créer playbook Ansible `playbooks/install_docker.yml`
2. Créer inventaire `inventories/staging/hosts.yml`
3. Exécuter playbook
4. Tester déploiement manuel

**Temps estimé** : 1-2h

---

### Jalon 3 : CI/CD Jenkins
**Objectif** : Automatiser tests + build.

**Actions** :
1. Créer `Jenkinsfile`
2. Configurer Jenkins (webhook ou poll SCM)
3. Pipeline : lint → tests → build → archiver

**Temps estimé** : 2-3h

---

## 💭 Réflexions et apprentissages

### Ce qui a bien fonctionné
- ✅ Approche progressive (1 étape à la fois)
- ✅ Vérification systématique avant action
- ✅ Documentation au fur et à mesure
- ✅ Tests immédiatement après chaque route
- ✅ Git commits fréquents et descriptifs

### Ce qui était difficile
- ❌ Comprendre que routes ≠ dossiers (concept abstrait)
- ❌ Git : les 3 zones (besoin de visualisation)
- ❌ Docker rebuild : savoir quand c'est nécessaire
- ❌ Driver PostgreSQL : psycopg vs psycopg2

### Ce qui est maintenant clair
- ✅ Routes HTTP = adresses web dans l'API
- ✅ Docker = conteneur portable qui isole l'application
- ✅ Git = machine à remonter le temps avec 3 étapes
- ✅ pytest = tests automatisés pour gagner du temps
- ✅ Volume Docker = persistance des données

---

## 🎯 Checklist finale de compréhension

### Concepts
- [x] Je sais ce qu'est une route HTTP
- [x] Je comprends le rôle de Docker
- [x] Je maîtrise les 3 zones Git
- [x] Je sais ce qu'est la persistance des données
- [x] Je comprends le lien API ↔ Base de données

### Pratique
- [x] Je sais créer une route FastAPI
- [x] Je sais écrire un test avec pytest
- [x] Je sais faire un commit Git propre
- [x] Je sais rebuilder une image Docker
- [x] Je sais tester une API avec curl

### Prêt pour la suite
- [x] Je peux expliquer le projet en 2 minutes
- [x] Je connais les prochaines étapes (Jalon 2, 3, 4...)
- [x] Je sais où trouver la documentation (docs/)
- [x] Je peux continuer seul en cas de besoin

---

## 📖 Ressources créées

### Documentation technique
1. `LAB_STATE.md` : État factuel complet du lab
2. `GUIDE_COMPREHENSION.md` : Guide pédagogique DevSecOps
3. `SESSION_PRATIQUE_2026-02-08.md` : Récap session pratique
4. `SESSION_COMPLETE_2026-02-08.md` : Récap complet (ce fichier)

### Code fonctionnel
1. API FastAPI (5 routes) avec PostgreSQL
2. 3 tests automatisés (pytest)
3. Docker Compose (2 services)
4. 10 commits Git propres

---

## 🎉 Conclusion

**Mission accomplie** : En 3h30, tu es passé de 0 à une API complète avec base de données, tests automatisés, et documentation exhaustive.

**Compétences acquises** : Git, Docker, FastAPI, SQLAlchemy, PostgreSQL, pytest, DevSecOps.

**Prochaine étape** : Tests d'intégration avec DB pour vraiment maîtriser le workflow complet.

**Rappel important** : Tu n'as pas exécuté "bêtement" des commandes. Tu as **construit méthodiquement** quelque chose de concret avec une logique claire.

---

**Date de création** : 2026-02-08  
**Dernière mise à jour** : 2026-02-08 15:40  
**Auteur** : Session avec Claude (IA DevSecOps)
