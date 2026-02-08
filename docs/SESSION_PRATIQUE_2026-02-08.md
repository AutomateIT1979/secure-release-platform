# Session Pratique — Routes HTTP, Docker, Git (2026-02-08)

## 🎯 Objectif de la session
Comprendre en pratiquant : routes HTTP, Docker, Git (3 zones), pytest.

---

## ✅ Ce que j'ai appris

### 1) Routes HTTP ≠ Dossiers
**Révélation** : Une route comme `/health` n'est PAS un dossier physique, c'est une "adresse" dans l'API web.

**Analogie** : Restaurant avec plusieurs comptoirs
- `/health` = comptoir "santé"
- `/version` = comptoir "info"
- `/projects` = comptoir "projets"

**En pratique** :
```bash
curl http://localhost:8000/health
# Réponse : {"status":"ok"}
```

### 2) Docker = Conteneur qui exécute l'API
**Révélation** : Docker contient l'API qui tourne sur le port 8000. Tous les clients (curl, navigateur, pytest) contactent Docker.

**Schéma mental** :
```
[Navigateur] → HTTP → [Docker:8000] → [API FastAPI] → Réponse JSON
```

**Commandes clés** :
- `docker compose up --build` : Rebuild image + démarrer
- `docker compose logs` : Voir les requêtes HTTP en temps réel
- `docker compose down` : Arrêter

### 3) Git : Les 3 zones
**Révélation** : Git a 3 zones, pas juste "save".
```
Zone 1: Working Directory (tu codes)
   ↓ git add
Zone 2: Staging Area (tu prépares)
   ↓ git commit
Zone 3: Repository (tu enregistres définitivement)
```

**Commandes clés** :
- `git status` : Voir dans quelle zone sont les fichiers
- `git diff` : Voir les modifications exactes (lignes +/-)
- `git add <fichier>` : Zone 1 → Zone 2
- `git commit -m "message"` : Zone 2 → Zone 3
- `git log --oneline` : Voir l'historique

### 4) pytest = Tests automatisés HTTP
**Révélation** : pytest fait des vraies requêtes HTTP vers l'API et vérifie les réponses.

**Exemple** :
```python
def test_version_endpoint():
    response = client.get("/version")  # Requête HTTP
    assert response.status_code == 200  # Vérif code
    assert "version" in response.json()  # Vérif contenu
```

---

## 🛠️ Ce que j'ai construit

### Routes API (3 routes)
1. `GET /health` → `{"status":"ok"}`
2. `GET /version` → `{"version":"1.0.0","commit":"9d1d7c3","build_date":"2026-02-08"}`
3. `GET /projects` → Liste de 3 projets (id, name, status)

### Tests automatisés (3 tests)
1. `test_health.py` → Vérifie `/health`
2. `test_version.py` → Vérifie `/version` (structure + valeurs)
3. `test_projects.py` → Vérifie `/projects` (structure + données)

**Résultat pytest** : `3 passed in 0.48s` ✅

### Commits Git (8 commits propres)
```
28eccfe feat: add /projects endpoint with test
4b6f314 feat: add /version endpoint with test
feae4e7 docs: add session recap (Jalon 1 completed)
9c4cfff docs: add comprehensive guide
9d1d7c3 feat: add FastAPI healthcheck
6e9c1d4 docs: add LAB_STATE.md
5bd5571 docs: add runbooks placeholder
8a4eb6b chore: initialize repo structure
```

---

## 💡 Moments "déclic"

### Déclic 1 : Swagger UI
**Avant** : Je ne comprenais pas bien ce qu'était une route.  
**Après** : J'ai vu visuellement les 3 routes dans `http://localhost:8000/docs`, cliqué sur "Execute", et vu la réponse JSON en direct.

### Déclic 2 : `git diff`
**Avant** : Je ne savais pas comment voir ce qui avait changé.  
**Après** : `git diff` montre ligne par ligne ce qui est ajouté (+) ou supprimé (-).

### Déclic 3 : Docker rebuild
**Avant** : Je ne comprenais pas pourquoi la route `/version` ne marchait pas alors que j'avais modifié le code.  
**Après** : `docker compose restart` ne rebuild pas → il faut `docker compose up --build` pour prendre en compte le nouveau code.

### Déclic 4 : Les 3 zones Git
**Avant** : Je trouvais Git confus.  
**Après** : Visualiser les 3 zones (Working → Staging → Repository) a tout clarifié.

---

## 📝 Commandes mémorisées

### Docker
```bash
docker compose up --build -d     # Build + démarrer (détaché)
docker compose logs --follow     # Voir les logs en temps réel
docker compose down              # Arrêter et nettoyer
docker compose ps                # Voir les conteneurs actifs
```

### Git
```bash
git status                       # État actuel (quelle zone)
git diff <fichier>               # Voir modifications
git add <fichier>                # Zone 1 → Zone 2
git commit -m "message"          # Zone 2 → Zone 3
git log --oneline -n 10          # Historique (10 derniers commits)
```

### pytest
```bash
pytest -v                        # Lancer tests (verbose)
pytest -q                        # Lancer tests (quiet)
pytest tests/test_health.py      # Lancer un test spécifique
```

### API (curl)
```bash
curl http://localhost:8000/health
curl http://localhost:8000/version
curl http://localhost:8000/projects
```

---

## 🎓 Concepts DevSecOps appliqués

### Test-Driven Development (TDD)
1. Code une route
2. Écris un test
3. Vérifie que le test passe
4. Commit

**Pourquoi ?** Garantir que le code marche AVANT de déployer.

### CI/CD (prochaine étape)
**Objectif Jalon 3** : Jenkins lancera automatiquement `pytest` à chaque push Git.
- Si tests passent → build Docker → déploiement
- Si tests échouent → pipeline bloqué

### Infrastructure as Code (IaC)
**Docker Compose** = code qui décrit l'infrastructure.
```yaml
services:
  api:
    build: .
    ports:
      - "8000:8000"
```

---

## ✅ Checklist de compréhension

- [x] Je sais ce qu'est une route HTTP (adresse web, pas dossier)
- [x] Je comprends le rôle de Docker (conteneur qui exécute l'API)
- [x] Je maîtrise les 3 zones Git (Working → Staging → Repository)
- [x] Je sais lire `git status` et `git diff`
- [x] Je sais créer un commit propre
- [x] Je comprends pytest (tests automatisés HTTP)
- [x] Je sais utiliser Swagger UI pour tester une route
- [x] Je comprends pourquoi `--build` est nécessaire

---

## 🚀 Prochaines étapes

### Option A : Jalon 2 (Ansible + EC2)
**Objectif** : Installer Docker sur EC2 avec Ansible.
- Créer playbook Ansible
- Déployer sur EC2
- Tester l'API à distance

### Option B : Continuer à pratiquer (API plus complexe)
**Objectif** : Ajouter une base de données PostgreSQL.
- Route POST `/projects` (créer un projet)
- Route DELETE `/projects/{id}` (supprimer un projet)
- Persistance en base de données

### Option C : Jalon 3 (CI/CD Jenkins)
**Objectif** : Automatiser tests + build.
- Créer Jenkinsfile
- Pipeline : lint → tests → build → archiver

---

## 💭 Réflexions personnelles

### Ce qui m'a surpris
- Les routes HTTP ne sont pas des dossiers (je pensais que `/health` était un dossier)
- Docker doit rebuilder l'image quand le code change
- Git a 3 zones, pas juste "save"

### Ce qui était difficile
- Comprendre `git diff` au début (les + et -)
- Savoir quand utiliser `git add` vs `git commit`

### Ce qui est maintenant clair
- Routes HTTP = adresses web
- Docker = conteneur portable
- Git = machine à remonter le temps avec 3 étapes
- pytest = tests automatisés pour gagner du temps

---

**Date** : 2026-02-08  
**Durée** : 2h  
**Résultat** : 3 routes, 3 tests, 8 commits, concepts clés maîtrisés ✅
