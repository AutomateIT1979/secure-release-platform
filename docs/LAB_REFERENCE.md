# Lab DevSecOps - Document de Référence Complet
**Date de création** : 2026-02-20  
**Dernière vérification** : 2026-02-20  
**Objectif** : Source de vérité factuelle pour éviter toute supposition

---

## ⚠️ AVERTISSEMENT IMPORTANT

Ce document contient UNIQUEMENT des informations **vérifiées et prouvées**.  
Les sections marquées "DERNIÈRE INFO CONNUE" indiquent des données historiques non vérifiées récemment.

---

## 1) ENVIRONNEMENT LOCAL (WSL) — ✅ VÉRIFIÉ 2026-02-20

### 1.1 Système
- **OS** : Ubuntu (WSL)
- **Utilisateur** : `administrator`
- **Chemin projet** : `/home/administrator/lab-devops/secure-release-platform`

### 1.2 Versions outils (vérifiées)
```
Python : 3.12.3
Docker : 29.1.3 (build f52814d)
Docker Compose : v5.0.0
Ansible : core 2.19.5
```

### 1.3 Structure du projet (vérifiée)
```
secure-release-platform/
├── app/                    # API FastAPI
│   ├── __init__.py
│   ├── database.py
│   ├── main.py
│   └── models.py
├── tests/                  # Tests pytest
│   ├── conftest.py
│   ├── test_health.py
│   ├── test_integration.py
│   └── test_version.py
├── ansible/
│   ├── inventories/
│   │   └── staging/
│   │       └── hosts.yml
│   └── playbooks/
│       ├── deploy_api.yml
│       ├── install_docker.yml
│       └── install_jenkins.yml
├── docs/
│   ├── DECISIONS.md
│   ├── GUIDE_COMPREHENSION.md
│   ├── LAB_STATE.md
│   ├── PROJECT_STATE.md
│   ├── ROADMAP.md
│   ├── SESSION_*.md (3 fichiers)
│   └── RUNBOOKS/
│       └── README.md
├── src/                    # VIDE (non utilisé)
├── Dockerfile
├── Jenkinsfile
├── docker-compose.yml
├── pytest.ini
├── requirements.txt
└── README.md
```

### 1.4 État Git (vérifié)
**Branch** : `main`  
**Dernier commit** : `6f26ba0` (2026-02-09)  
**Fichiers non versionnés** : `test.db` (base locale)

**5 derniers commits** :
```
6f26ba0 docs: update LAB_STATE with Jalon 4 status (Jenkins partial)
8318067 feat(jenkins): add Jenkins installation and CI/CD pipeline
dcefbfe feat(ansible): deploy API + PostgreSQL to EC2
41b0029 docs: update LAB_STATE with Jalon 2 completion (Ansible + Docker EC2)
809d288 feat(ansible): add Docker installation playbook for EC2
```

---

## 2) APPLICATION (MVP) — ✅ VÉRIFIÉ

### 2.1 Stack technique
- **Framework** : FastAPI (Python 3.12.3)
- **Base de données** : PostgreSQL (Docker)
- **ORM** : SQLAlchemy
- **Tests** : pytest

### 2.2 Routes API disponibles
```python
GET  /health              # Healthcheck
GET  /version             # Version API
GET  /projects            # Liste projets
POST /projects            # Créer projet
GET  /projects/{id}       # Détail projet
```

### 2.3 Tests
**Framework** : pytest + pytest-asyncio  
**Fichiers** : 4 fichiers de tests  
**Configuration** : `pytest.ini` avec `pythonpath = .`

**Commande** :
```bash
pytest -v
```

### 2.4 Docker
**Fichiers** :
- `Dockerfile` : Image API
- `docker-compose.yml` : API + PostgreSQL

**Commande lancement** :
```bash
docker compose up --build -d
curl http://localhost:8000/health
```

---

## 3) ANSIBLE — ✅ VÉRIFIÉ

### 3.1 Structure
```
ansible/
├── inventories/
│   └── staging/
│       └── hosts.yml      # Configuration EC2
└── playbooks/
    ├── install_docker.yml  # Installation Docker sur EC2
    ├── deploy_api.yml      # Déploiement API + PostgreSQL
    └── install_jenkins.yml # Installation Jenkins
```

### 3.2 Inventaire staging (hosts.yml)
Contient la configuration de l'instance EC2 cible.

### 3.3 Playbooks disponibles
1. **install_docker.yml** : Installe Docker + Docker Compose sur EC2
2. **deploy_api.yml** : Déploie l'API + PostgreSQL via Docker Compose
3. **install_jenkins.yml** : Installe Jenkins sur EC2

**Commande type** :
```bash
ansible-playbook -i ansible/inventories/staging/hosts.yml \
  ansible/playbooks/install_docker.yml
```

---

## 4) CI/CD (JENKINS) — ✅ VÉRIFIÉ (fichier)

### 4.1 Jenkinsfile
**Emplacement** : Racine du projet (`./Jenkinsfile`)  
**Étapes prévues** :
1. Checkout code
2. Install dependencies
3. Run tests
4. Build Docker image
5. Deploy

**État** : Fichier créé et versionné, pipeline non testé.

---

## 5) INFRASTRUCTURE AWS — ⚠️ DERNIÈRE INFO CONNUE (2026-02-08)

### 5.1 Instance EC2
**⚠️ INFO NON VÉRIFIÉE DEPUIS LE 2026-02-08**

- **ID** : `i-01c77636889cc7f4a`
- **Nom** : `lab-devops-ec2`
- **IP publique** : `35.180.54.218` (peut avoir changé)
- **IP privée** : `172.31.7.253`
- **Région** : `eu-west-3` (Paris)
- **OS** : Ubuntu 22.04.5 LTS

### 5.2 Security Group
**⚠️ INFO NON VÉRIFIÉE DEPUIS LE 2026-02-08**

- **ID** : `sg-0db21b6219faa2fca`
- **Règles inbound** :
  - Port 22 (SSH) : `146.70.148.78/32` (IP locale, change régulièrement)
  - Port 80 (HTTP) : `146.70.148.78/32`
  - Port 8080 (Jenkins) : Ajouté lors de l'installation Jenkins

### 5.3 Outils installés sur EC2 (dernier état connu)
**⚠️ INFO NON VÉRIFIÉE DEPUIS LE 2026-02-08**

- ✅ Docker 29.2.1
- ✅ Docker Compose v2.24.5
- ✅ Nginx 1.18.0
- ✅ Jenkins 2.541.1
- ✅ Git 2.34.1
- ✅ Python 3.10.12

### 5.4 Connexion SSH
**Commande** :
```bash
ssh -i ~/.ssh/lab-devops-key.pem ubuntu@35.180.54.218
```

**⚠️ PROBLÈME CONNU** : L'IP publique locale change régulièrement, nécessite mise à jour du Security Group.

**Solution temporaire** :
```bash
# Obtenir IP actuelle
curl -s ifconfig.me

# Mettre à jour Security Group (nécessite AWS CLI configuré)
aws ec2 authorize-security-group-ingress \
  --group-id sg-0db21b6219faa2fca \
  --protocol tcp --port 22 \
  --cidr $(curl -s ifconfig.me)/32
```

---


### 5.5 Script d'auto-update Security Group
**Script** : `scripts/update-aws-sg.sh`  
**Usage** : `./scripts/update-aws-sg.sh`

**Fonctionnement** :
1. Détecte IP publique actuelle
2. Nettoie anciennes règles
3. Autorise nouvelle IP (ports 22, 80, 8080)

**Résout** : Problème d'IP dynamique (NordVPN + DHCP)

**Commande à exécuter avant chaque session** :
```bash
cd ~/lab-devops/secure-release-platform
./scripts/update-aws-sg.sh
```

## 6) JALONS COMPLÉTÉS — ✅ VÉRIFIÉ (Git)

### Jalon 1 — MVP local (✅ COMPLÉTÉ)
- API FastAPI avec 5 routes
- PostgreSQL intégré
- Tests passent (pytest)
- Docker Compose fonctionne

**Preuve** : Commits `9d1d7c3`, `feae4e7`

### Jalon 2 — Installation Docker EC2 (✅ COMPLÉTÉ)
- Playbook Ansible fonctionnel
- Docker + Docker Compose installés sur EC2

**Preuve** : Commits `809d288`, `41b0029`

### Jalon 3 — Déploiement API sur EC2 (✅ COMPLÉTÉ)
- API + PostgreSQL déployés sur EC2
- Playbook `deploy_api.yml` créé

**Preuve** : Commit `dcefbfe`

### Jalon 4 — Jenkins CI/CD (🔄 PARTIEL)
- Jenkins installé sur EC2
- Jenkinsfile créé
- **Bloqué** : Problème connectivité Jenkins (EC2) ↔ Git repo (WSL)

**Preuve** : Commits `8318067`, `6f26ba0`

---

## 7) PROBLÈMES CONNUS ET SOLUTIONS

### 7.1 IP publique dynamique (CRITIQUE)
**Symptôme** : Connexion SSH échoue régulièrement  
**Cause** : IP publique locale change (changement de réseau)  
**Impact** : Bloque accès EC2, déploiements Ansible, Jenkins

**Solutions possibles** :
1. **IP Elastic AWS** (coût ~$3.65/mois si inactive)
2. **Bastion/VPN** 
3. **Security Group 0.0.0.0/0** (⚠️ risque sécurité)
4. **Script auto-update** Security Group au démarrage

**Statut** : ✅ RÉSOLU via script auto-update (commit 5e8c3fe)

### 7.2 Jenkins-Git connectivité
**Symptôme** : Jenkins (EC2) ne peut pas cloner le repo (WSL)  
**Cause** : Repo Git local sur WSL, Jenkins distant sur EC2  
**Impact** : Pipeline Jenkins non fonctionnel

**Solutions possibles** :
1. **Git remote** (GitHub/GitLab) — recommandé
2. **Git bare repo** sur EC2
3. **Jenkins sur WSL** (perd avantage isolation)

**Statut** : Non résolu, bloque Jalon 4.

---

## 8) PROCHAINES ÉTAPES RECOMMANDÉES

### Priorité 1 — Débloquer Jalon 4
1. Choisir architecture Git (GitHub vs bare repo EC2)
2. Configurer Jenkins pour accéder au repo
3. Tester pipeline complet

### Priorité 2 — Résoudre IP dynamique
1. Évaluer coût Elastic IP
2. Implémenter solution pérenne
3. Documenter procédure

### Priorité 3 — Jalon 5 (DevSecOps)
1. Intégrer scans sécurité (trivy, semgrep, gitleaks)
2. Policy gate (blocage si CRITICAL)
3. Générer SBOM

### Priorité 4 — Jalon 6 (Observabilité)
1. Prometheus + Grafana
2. Logs structurés JSON
3. Alerting

---

## 9) COMMANDES ESSENTIELLES

### Tests locaux
```bash
cd ~/lab-devops/secure-release-platform
pytest -v
docker compose up --build -d
curl http://localhost:8000/health
```

### Déploiement Ansible
```bash
ansible-playbook -i ansible/inventories/staging/hosts.yml \
  ansible/playbooks/deploy_api.yml
```

### Git
```bash
git status
git log --oneline -10
```

### Audit rapide
```bash
# Versions
python3 --version
docker --version
ansible --version

# État projet
git status --porcelain
docker compose ps
```

---

## 10) CHECKLIST PUBLICATION GITHUB

- [x] Code applicatif versionné
- [x] Tests passent
- [x] Docker Compose fonctionne
- [x] Playbooks Ansible créés
- [x] Jenkinsfile créé
- [ ] Pipeline Jenkins fonctionnel
- [ ] Scans sécurité intégrés
- [ ] Documentation complète
- [ ] README orienté démo
- [ ] Aucun secret dans le repo

---

## 11) NOTES DE SÉCURITÉ

### Secrets
- ⚠️ `.env.example` fourni (pas de `.env` dans Git)
- ⚠️ Clé SSH `~/.ssh/lab-devops-key.pem` (permissions 400, NON versionnée)
- ⚠️ Utiliser Jenkins Credentials pour secrets production

### Git
- `.gitignore` configuré (`.venv`, `__pycache__`, `*.pyc`, `.env`)
- Aucun secret commité (vérifié)

---

## ANNEXE A — HISTORIQUE DES MODIFICATIONS

| Date | Auteur | Modification |
|------|--------|--------------|
| 2026-02-20 | administrator | Création document de référence consolidé |
| 2026-02-09 | administrator | Dernier commit Git (Jalon 4 partiel) |
| 2026-02-08 | administrator | Jalons 1-3 complétés |

---

## ANNEXE B — SOURCES DE VÉRITÉ

**Fichiers clés** :
- `docs/LAB_REFERENCE.md` : Ce document (source de vérité globale)
- `docs/LAB_STATE.md` : État détaillé (historique)
- `docs/DECISIONS.md` : Décisions techniques
- `docs/ROADMAP.md` : Jalons et DoD

**Règle** : En cas de conflit, `LAB_REFERENCE.md` fait foi.


---

## 12) SYSTÈME D'AUDIT ET SYNCHRONISATION

### 12.1 Usage dans Claude Desktop Projects

**⚠️ IMPORTANT** : Ce fichier est utilisé comme "Project Knowledge" dans Claude Desktop.

**Fichiers du projet Claude Desktop** :
- `Secure_Release_Platform_DevSecOps_Project.md` : Planification initiale (obsolète)
- `LAB_REFERENCE.md` : **Source de vérité actuelle** ← CE FICHIER

**Règle de priorité** : En cas de conflit, `LAB_REFERENCE.md` fait foi.

---

### 12.2 Protocole de mise à jour

**Quand mettre à jour ce fichier** :
- ✅ Après chaque jalon complété
- ✅ Après modification infrastructure AWS
- ✅ Après ajout/modification d'outils
- ✅ Quand une section "DERNIÈRE INFO CONNUE" devient obsolète

**Comment mettre à jour** :
1. Modifier `docs/LAB_REFERENCE.md` dans le repo Git
2. Commit + Push
3. **Mettre à jour dans TOUS les projets Claude Desktop qui l'utilisent**

---

### 12.3 Checklist d'audit (à exécuter avant chaque session)

**Commandes de vérification** :
```bash
cd ~/lab-devops/secure-release-platform

# 1) Vérifier versions outils
echo "=== VERSIONS ==="
python3 --version
docker --version
ansible --version

# 2) Vérifier état Git
echo "=== GIT ==="
git status --porcelain
git log --oneline -3

# 3) Vérifier structure projet
echo "=== STRUCTURE ==="
ls -1 app/ tests/ ansible/playbooks/

# 4) Vérifier connectivité AWS (si applicable)
echo "=== AWS ==="
aws sts get-caller-identity 2>/dev/null || echo "AWS CLI non configuré ou erreur"

# 5) Date du dernier audit
echo "=== AUDIT ==="
echo "Dernière vérification LAB_REFERENCE.md : $(stat -c %y docs/LAB_REFERENCE.md | cut -d' ' -f1)"
echo "Date actuelle : $(date +%Y-%m-%d)"
```

**Résultat attendu** : Si écart > 7 jours, mettre à jour `LAB_REFERENCE.md`.

---

### 12.4 Synchronisation multi-projets Claude Desktop

**Si ce fichier est utilisé dans plusieurs projets Claude Desktop** :

1. **Projet principal** : `DevOps` (ce projet)
2. **Projets secondaires** : Lister ici

**⚠️ RAPPEL** : Après modification de `LAB_REFERENCE.md` :
1. Commit dans Git
2. Copier dans `/mnt/project/` de CHAQUE projet Claude Desktop
3. Vérifier que tous les projets ont la même version

**Commande de vérification** :
```bash
# Dans chaque projet Claude Desktop
md5sum docs/LAB_REFERENCE.md
# Tous doivent avoir le même hash
```

---

### 12.5 Avertissements pour l'IA

**Instructions pour Claude (ou toute IA)** :

1. **TOUJOURS** lire `LAB_REFERENCE.md` avant de répondre à une question sur le Lab
2. **VÉRIFIER** la date de "Dernière vérification" en début de document
3. **SIGNALER** si une info semble obsolète (> 14 jours)
4. **NE JAMAIS** supposer l'état de l'infrastructure AWS sans vérification
5. **EXIGER** des preuves (commandes + outputs) avant de conclure

**En cas de doute** :
- Proposer UNE commande de diagnostic
- Attendre l'output avant de continuer
- Mettre à jour `LAB_REFERENCE.md` si nécessaire

---

### 12.6 Historique des audits

| Date | Auditeur | Changements détectés | Actions |
|------|----------|---------------------|---------|
| 2026-02-20 | administrator | Création document initial | N/A |
| | | | |
| | | | |

**Instructions** : Ajouter une ligne après chaque audit complet.

---

## ANNEXE C — TEMPLATE COMMIT MESSAGE

Pour maintenir la cohérence Git, utiliser ces préfixes :
```
feat: Nouvelle fonctionnalité
fix: Correction de bug
docs: Documentation uniquement
test: Ajout/modification tests
chore: Tâches de maintenance
refactor: Refactoring code
ci: CI/CD pipeline
ansible: Playbooks Ansible
```

**Exemple** :
```bash
git commit -m "docs: update LAB_REFERENCE.md - audit 2026-02-20"
```

---

**FIN DU DOCUMENT**
**Dernière modification** : 2026-02-20 par administrator
**Version** : 1.1
**Hash** : À calculer après commit
