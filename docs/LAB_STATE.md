# État du Lab DevSecOps — 2026-02-08

## 1) Vue d'ensemble

Ce document trace l'état **factuel** du laboratoire DevSecOps pour le projet "Secure Release Platform".

**Objectif du projet** : Construire une chaîne DevSecOps complète (CI/CD, scans sécurité, déploiement automatisé, observabilité, rollback).

**Date de dernière mise à jour** : 2026-02-08 13:47 UTC

---

## 2) Environnement local (WSL)

### 2.1 Système
- **OS** : Ubuntu (WSL sous Windows)
- **Utilisateur** : `administrator`
- **Chemin projet** : `/home/administrator/lab-devops/secure-release-platform`


### 2.2 Outils installés
| Outil | Version | Statut |
|-------|---------|--------|
| Python | 3.12.3 | ✅ venv actif (`.venv`) |
| Docker | 29.1.3 | ✅ |
| Docker Compose | v5.0.0 | ✅ |
| Ansible | core 2.19.5 | ✅ |
| Terraform | v1.14.4 | ✅ |
| Jenkins | 2.541.1 | ✅ Installé via systemd (port 8080) |

### 2.5 Jenkins (WSL)
- **Installation** : Via systemd (pas Docker)
- **Version** : Jenkins 2.541.1
- **Service** : `jenkins.service` actif
- **URL** : `http://localhost:8080/`
- **État** : Opérationnel ✅
- **Alertes** :
  - Java 17 end of life (31 mars 2026)
  - Building on built-in node (security issue)
- **Plugins** : À documenter
- **Jobs** : Aucun (à créer)

### 2.3 État du repo Git

**Branch** : `main`

**Fichiers suivis par Git** (6 fichiers documentation) :
```
.gitignore
README.md
docs/DECISIONS.md
docs/PROJECT_STATE.md
docs/ROADMAP.md
docs/RUNBOOKS/README.md
```

**Fichiers NON suivis** (code applicatif présent localement) :
```
app/main.py
app/__init__.py
tests/test_health.py
Dockerfile
docker-compose.yml
requirements.txt
.env.example
```

**Problème identifié** : Le code applicatif n'est pas versionné → **Action requise** : `git add` puis `git commit` avant toute restructuration.

### 2.4 Tests
- **Framework** : pytest
- **Problème actuel** : `ModuleNotFoundError: No module named 'app'`
- **Cause** : pytest ne trouve pas le module `app/` (problème de `sys.path`)
- **Solution prévue** : Ajouter `pytest.ini` avec `pythonpath = .`

---

## 3) Infrastructure AWS

### 3.1 Instance EC2

**Détails** :
- **ID** : `i-01c77636889cc7f4a`
- **Nom** : `lab-devops-ec2`
- **État** : `running`
- **IP publique** : `35.180.54.218`
- **IP privée** : `172.31.7.253`
- **Région** : `eu-west-3` (Paris, déduit de l'IP)

**Système** :
- **OS** : Ubuntu 22.04.5 LTS
- **Kernel** : 6.8.0-1044-aws
- **Architecture** : x86_64

### 3.2 Security Group

**ID** : `sg-0db21b6219faa2fca`  
**Nom** : `lab-devops-web-sg`

**Règles inbound** :
| Port | Protocole | Source | Usage |
|------|-----------|--------|-------|
| 22 | TCP | `146.70.148.78/32` | SSH (IP mise à jour le 2026-02-08) |
| 80 | TCP | `146.70.148.78/32` | HTTP (Nginx) |

**Note** : L'IP publique change régulièrement → nécessite mise à jour manuelle du Security Group.

### 3.3 Outils installés sur EC2

| Outil | Version | Statut |
|-------|---------|--------|
| Nginx | 1.18.0 | ✅ Actif (port 80) |
| Git | 2.34.1 | ✅ |
| Python | 3.10.12 | ✅ |
| Docker | ❌ | **Non installé** |
| Docker Compose | ❌ | **Non installé** |
| Jenkins | ❌ | **Non installé** |
| Ansible | ❌ | **Non installé** |
| Terraform | ❌ | **Non installé** |

### 3.4 Services actifs
- **Nginx** : écoute sur port 80 (serveur web par défaut)
- **SSH** : écoute sur port 22

### 3.5 Répertoires
- `/var/www/html` : page par défaut Nginx
- `/opt/` : vide (prévu pour applications)

---

## 4) Connexion SSH

**Méthode** : SSH avec clé privée

**Commande** :
```bash
ssh -i ~/.ssh/lab-devops-key.pem ubuntu@35.180.54.218
```

**Clé** : `~/.ssh/lab-devops-key.pem` (permissions 400)

**Utilisateur EC2** : `ubuntu`

---

## 5) État du projet applicatif (MVP)

### 5.1 API (Backend)
- **Stack** : FastAPI (Python)
- **Endpoints prévus** :
  - `GET /health` → healthcheck
  - `GET /version` → version applicative
  - CRUD simple (à ajouter)

**État actuel** :
- Fichiers présents localement (`app/main.py`, `app/__init__.py`)
- **NON versionnés** dans Git
- **Tests** : `tests/test_health.py` présent
- **Problème** : pytest échoue (import `app` non résolu)

### 5.2 Base de données
- **Stack prévue** : PostgreSQL (Docker)
- **État actuel** : **Non déployée**

### 5.3 Packaging
- **Docker** : `Dockerfile` présent (non versionné)
- **Docker Compose** : `docker-compose.yml` présent (non versionné)
- **État actuel** : Jamais testé (`docker compose up` pas encore exécuté)

---

## 6) Pipeline CI/CD (objectif)

### 6.1 Jenkins
- **Installation** : ✅ Installé sur WSL via systemd
- **État actuel** : ✅ Installé sur WSL (version 2.541.1, port 8080)
- **Jenkinsfile** : **Non créé**

### 6.2 Étapes pipeline prévues
1. Lint/format
2. Tests unitaires + intégration
3. Build image Docker
4. Scans sécurité (SAST, SCA, secrets, SBOM, image scan)
5. Policy gate (blocage si CRITICAL)
6. Déploiement staging (Ansible)
7. Smoke test (`/health`)
8. Promotion prod (manuel) + rollback auto si KO

**État actuel** : **Rien de déployé**

---

## 7) Déploiement (Ansible)

### 7.1 Ansible (local WSL)
- **Version** : core 2.19.5
- **Playbooks** : **Non créés**
- **Inventaires** : **Non créés**

### 7.2 Cible déploiement
- **Serveur** : EC2 `35.180.54.218`
- **Prérequis** : Docker + Docker Compose (à installer)
- **État actuel** : **Pas de Docker sur EC2**

---

## 8) DevSecOps (scans sécurité)

### 8.1 Outils prévus
| Outil | Usage | Statut |
|-------|-------|--------|
| gitleaks | Secret scanning | ❌ Non installé |
| semgrep | SAST (code statique) | ❌ Non installé |
| trivy | Image scanning | ❌ Non installé |
| syft | SBOM generation | ❌ Non installé |

### 8.2 Policy gate
- **Règle** : Pipeline échoue si findings CRITICAL
- **État actuel** : **Non implémenté**

---

## 9) Observabilité

### 9.1 Logs
- **Format prévu** : JSON structuré
- **État actuel** : **Non implémenté**

### 9.2 Métriques
- **Stack prévue** : Prometheus + Grafana
- **État actuel** : **Non déployée**

### 9.3 Alerting
- **Stack prévue** : Alertmanager
- **État actuel** : **Non déployé**

---

## 10) Prochaines étapes (ordre recommandé)

### Jalon 1 — Fixer le blocage actuel (local WSL)
1. ✅ **FAIT** : Connexion SSH EC2 rétablie (IP mise à jour)
2. ✅ **FAIT** : pytest.ini ajouté, tests passent pour fixer l'import `app`
3. ✅ Code applicatif versionné (commit 9d1d7c3) (`git add app/ tests/ Dockerfile docker-compose.yml requirements.txt`)
4. ✅ Docker Compose testé (healthcheck OK)
5. ✅ Healthcheck OK : {"status":"ok"} : `curl http://localhost:8000/health`

### Jalon 2 — Préparer EC2
1. Installer Docker + Docker Compose sur EC2 (via Ansible ou script)
2. Tester déploiement manuel de l'API sur EC2

### Jalon 3 — CI/CD
1. Installer Jenkins (EC2 ou Docker)
2. Créer `Jenkinsfile` basique
3. Intégrer scans sécurité

### Jalon 4 — Déploiement automatisé
1. Créer playbook Ansible
2. Automatiser déploiement staging/prod
3. Implémenter rollback

### Jalon 5 — Observabilité
1. Logs structurés JSON
2. Prometheus + Grafana
3. Alerting

---

## 11) Commandes de diagnostic rapide

### WSL
```bash
cd ~/lab-devops/secure-release-platform
git status
pytest -q
docker compose up --build
```

### EC2
```bash
ssh -i ~/.ssh/lab-devops-key.pem ubuntu@35.180.54.218
docker --version
systemctl status nginx
```

### AWS CLI
```bash
# Lister instances
aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId,State.Name,PublicIpAddress,Tags[?Key==`Name`].Value|[0]]' --output table

# Voir Security Group
aws ec2 describe-security-groups --group-ids sg-0db21b6219faa2fca --query 'SecurityGroups[0].IpPermissions[*].[IpProtocol,FromPort,ToPort,IpRanges[*].CidrIp]' --output table

# Mettre à jour IP SSH
aws ec2 authorize-security-group-ingress --group-id sg-0db21b6219faa2fca --protocol tcp --port 22 --cidr $(curl -s ifconfig.me)/32
```

---

## 12) Notes importantes

### Sécurité
- ⚠️ IP publique change régulièrement → Security Group doit être mis à jour
- ⚠️ Aucun secret dans Git (utiliser `.env.example` + Vault/Jenkins Credentials)
- ⚠️ Clé SSH `.pem` ne doit JAMAIS être versionnée

### Git
- Code applicatif présent localement mais **non versionné**
- Avant `git mv` : TOUJOURS `git add` + `git commit` d'abord

### Documentation
- Source de vérité : `docs/LAB_STATE.md` (ce fichier)
- Mettre à jour après chaque jalon

---

## 13) Checklist "Prêt pour GitHub"

- [ ] Code applicatif versionné
- [ ] Tests passent (pytest vert)
- [ ] Docker Compose fonctionne
- [ ] Jenkinsfile créé
- [ ] Playbook Ansible créé
- [ ] Scans sécurité intégrés
- [ ] Documentation complète (README, RUNBOOKS)
- [ ] Preuves (captures, rapports) dans `docs/evidence/`
- [ ] Aucun secret dans le repo

---

## MISE À JOUR - 2026-02-08 (fin de journée)

### Session complète : MVP local + Tests d'intégration

**Durée** : ~4h (12h30-16h30)

**Réalisations** :
- ✅ API FastAPI : 5 routes fonctionnelles
- ✅ PostgreSQL : intégré avec Docker Compose
- ✅ Tests : 7 tests (2 unitaires + 5 intégration)
- ✅ Git : 12 commits propres
- ✅ Documentation : 1500+ lignes

**État actuel** :
```bash
# Tests
pytest -v  # 7 passed ✅

# Docker
docker compose up --build -d  # API + PostgreSQL ✅

# Routes
curl http://localhost:8000/health  # {"status":"ok"} ✅
curl http://localhost:8000/projects  # Liste projets depuis DB ✅
```

**Prochaines étapes** :
1. Jalon 2 : Déploiement EC2 (Ansible)
2. Jalon 3 : CI/CD Jenkins
3. Jalon 4 : DevSecOps scans

**Fichiers clés** :
- `app/main.py` : API complète
- `app/database.py` : Connexion PostgreSQL
- `app/models.py` : Modèle Project
- `tests/conftest.py` : Fixtures pytest
- `tests/test_integration.py` : Tests d'intégration
- `docker-compose.yml` : 2 services

**Commandes essentielles** :
```bash
# Tests
pytest -v

# Docker
docker compose up --build -d
docker compose logs --follow
docker compose down

# Git
git log --oneline --decorate -n 12

# API
curl http://localhost:8000/docs  # Swagger UI
```
