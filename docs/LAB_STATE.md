# État du Lab DevSecOps — 2026-02-22

## 1) Vue d'ensemble

Ce document trace l'état **factuel** du laboratoire DevSecOps pour le projet "Secure Release Platform".

**Objectif du projet** : Construire une chaîne DevSecOps complète (CI/CD, scans sécurité, déploiement automatisé, observabilité).

**Date de dernière mise à jour** : 2026-02-22 19:00 UTC

**Statut global** : ✅ **PRODUCTION READY** (97% complété)

---

## 2) Environnement local (WSL)

### 2.1 Système
- **OS** : Ubuntu 24.04 (WSL sous Windows 11)
- **Utilisateur** : `administrator`
- **Chemin projet** : `/home/administrator/lab-devops/secure-release-platform`

### 2.2 Outils installés

| Outil | Version | Statut | Usage |
|-------|---------|--------|-------|
| Python | 3.12.3 | ✅ | venv actif (`.venv`) |
| Docker | 29.1.3 | ✅ | Build images localement |
| Docker Compose | v5.0.0 | ✅ | Stack locale (API + DB) |
| Ansible | core 2.19.5 | ✅ | Déploiements EC2 |
| Terraform | v1.14.4 | ✅ | IaC (EC2 scans) |
| AWS CLI | 2.33.11 | ✅ | Gestion AWS |
| pytest | 8.0.2 | ✅ | Tests unitaires (7/7) |

### 2.3 État du repo Git

**Remote** : https://github.com/AutomateIT1979/secure-release-platform.git  
**Branch** : `main`  
**Dernier commit** : `7f1679f` (2026-02-22)  
**Commits aujourd'hui** : 26 commits

**Derniers commits** :
```
7f1679f - feat(observability): deploy Prometheus + Grafana stack
83588a9 - feat(observability): add Prometheus metrics endpoint
2794e72 - feat(terraform): add dedicated EC2 for security scanning
cf4bde1 - docs: add Policy Gate documentation (build #10)
283f3ba - feat(jenkins): implement Policy Gate for security enforcement
```

**Fichiers non versionnés** :
- `test.db` (base locale tests)
- `app/main.py.backup` (backup instrumentation)
- `terraform/.terraform/` (état Terraform)
- `terraform/terraform.tfvars` (secrets gitignored)

### 2.4 Structure du projet
```
secure-release-platform/
├── app/                    # API FastAPI (instrumented Prometheus)
│   ├── main.py             # Routes + /metrics endpoint
│   ├── database.py
│   └── models.py
├── tests/                  # 7 tests pytest
├── ansible/
│   ├── inventories/staging/hosts.yml
│   └── playbooks/
│       ├── deploy_api.yml
│       ├── install_docker.yml
│       └── install_jenkins.yml
├── terraform/              # IaC EC2 scans
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── terraform.tfvars (gitignored)
├── observability/          # Prometheus + Grafana
│   ├── prometheus.yml
│   └── docker-compose-observability.yml
├── docs/                   # Documentation complète
│   ├── LAB_REFERENCE.md    # Source de vérité (25K)
│   ├── LAB_STATE.md        # Ce fichier
│   ├── DECISIONS.md
│   └── ROADMAP.md
├── Dockerfile
├── Jenkinsfile             # Pipeline DevSecOps
├── docker-compose.yml
├── pytest.ini
└── requirements.txt
```

---

## 3) Infrastructure AWS — ✅ VÉRIFIÉ (2026-02-22)

### 3.1 EC2 #1 - Jenkins + API + Observabilité

| Paramètre | Valeur |
|-----------|--------|
| **ID** | i-01c77636889cc7f4a |
| **Nom** | lab-devops-ec2 |
| **IP Publique** | 35.180.38.208 |
| **IP Privée** | 172.31.7.253 |
| **Type** | t3.small (2GB RAM, 2 vCPU) |
| **OS** | Ubuntu 22.04.5 LTS |
| **Uptime** | Stable depuis upgrade (2026-02-22) |
| **Usage RAM** | ~50% (1GB/2GB) |
| **Usage Disk** | 74.5% de 7.57GB |

**Services actifs** :
- ✅ Jenkins 2.541.1 (port 8080) : 10 builds complétés
- ✅ API FastAPI (port 8000) : /health OK, /metrics exposé
- ✅ PostgreSQL (port 5432) : Database production
- ✅ Prometheus (port 9090) : Scraping /metrics every 10s
- ✅ Grafana (port 3000) : v12.3.3, admin ready

**Security Group** : sg-0db21b6219faa2fca
- Port 22 (SSH) : 146.70.148.54/32
- Port 80 (HTTP) : 146.70.148.54/32
- Port 8000 (API) : 0.0.0.0/0 (public)
- Port 8080 (Jenkins) : 146.70.148.54/32
- Port 9090 (Prometheus) : 146.70.148.54/32
- Port 3000 (Grafana) : 146.70.148.54/32

**SSH** : `ssh -i ~/.ssh/lab-devops-key.pem ubuntu@35.180.38.208`

---

### 3.2 EC2 #2 - Security Scans (Terraform)

| Paramètre | Valeur |
|-----------|--------|
| **ID** | i-0895fb26e33d874d8 |
| **Nom** | lab-devops-scans-ec2 |
| **IP Publique** | 15.188.127.106 |
| **IP Privée** | 172.31.12.54 |
| **Type** | t3.micro (1GB RAM, 2 vCPU) |
| **OS** | Ubuntu 22.04 LTS |
| **Managed By** | Terraform ✨ |
| **Uptime** | Depuis création (2026-02-22 17:11 UTC) |
| **Usage RAM** | ~34% (340MB/1GB) |

**Outils pré-installés** :
- ✅ Docker 29.2.1
- ✅ Trivy (aquasec/trivy:latest) - 245MB
- ✅ Gitleaks (zricethezav/gitleaks:latest) - 75.8MB

**Security Group** : sg-05350268f9cd57c3b
- Port 22 (SSH) : 146.70.148.54/32

**SSH** : `ssh -i ~/.ssh/lab-devops-key.pem ubuntu@15.188.127.106`

**Terraform state** : Local (`terraform/terraform.tfstate`)

---

### 3.3 Coûts AWS

| Ressource | Coût/mois | Heures/mois | Total mensuel |
|-----------|-----------|-------------|---------------|
| EC2 t3.small | $0.0208/h | 730h | ~$15.18 |
| EC2 t3.micro | $0.0104/h | 730h | ~$7.59 |
| **Total** | | | **~$22.77/mois** |

**Budget** : $110 USD crédits AWS (expire 2026-06-09)  
**Couverture** : ~4.8 mois

---

## 4) CI/CD Pipeline — ✅ OPÉRATIONNEL (Jenkins)

### 4.1 Jenkins Configuration

**URL** : http://35.180.38.208:8080  
**Version** : Jenkins 2.541.1  
**Job** : `secure-release-platform-pipeline`  
**Builds total** : 10 (6 SUCCESS, 4 FAILURE instructifs)

**Pipeline stages** :
1. Checkout (Git)
2. Security Scan - Secrets (Gitleaks)
3. Build Docker Image
4. Security Scan - Docker Image [POLICY GATE] (Trivy)
5. Deploy to EC2
6. Smoke Test (curl /health + /version)

### 4.2 Builds History

| Build | Status | Commit | Notes |
|-------|--------|--------|-------|
| #1-5 | Tests | - | Setup initial |
| #6 | ✅ SUCCESS | 475afc5 | Jalon 4 complété |
| #7 | ✅ SUCCESS | 033133f | DevSecOps scans (6 HIGH) |
| #8 | ❌ FAILURE | 116bd9d | Conflit dépendances |
| #9 | ✅ SUCCESS | a62f98c | Patches appliqués (5 HIGH) |
| #10 | ❌ FAILURE | 283f3ba | **Policy Gate** (blocage attendu) |

**Dernier build** : #10 (FAILURE volontaire - démontre enforcement)

### 4.3 Security Scans Results

**Gitleaks** : ✅ 0 secret détecté  
**Trivy** : ⚠️ 5 HIGH vulnérabilités

**Vulnérabilités actuelles** :
- Debian : 2 HIGH (glibc CVE-2026-0861)
- Python : 3 HIGH
  1. jaraco.context 5.3.0 (CVE-2026-23949) - vendored setuptools
  2. starlette 0.40.0 (CVE-2025-62727) - nécessite 0.49.1
  3. wheel 0.45.1 (CVE-2026-24049) - vendored setuptools

**Évolution** : 6 HIGH (build #7) → 5 HIGH (build #9) = -16% ✅

---

## 5) Application (MVP) — ✅ PRODUCTION

### 5.1 Stack Technique

- **Framework** : FastAPI 0.115.6
- **Base de données** : PostgreSQL 15 (Docker)
- **ORM** : SQLAlchemy 2.0.27
- **Tests** : pytest 8.0.2 (7/7 passing)
- **Observabilité** : Prometheus + Grafana

### 5.2 Routes API
```
GET  /health              # Healthcheck
GET  /version             # Version API
GET  /metrics             # Prometheus metrics ← NEW
GET  /projects            # Liste projets
POST /projects            # Créer projet
GET  /projects/{id}       # Détail projet
```

**URL publique** : http://35.180.38.208:8000

### 5.3 Métriques Exposées (/metrics)

- **Python runtime** : GC collections, memory
- **Process** : virtual/resident memory, CPU time, open FDs
- **HTTP** : request count, size, duration (instrumented)

---

## 6) Observabilité — ⏳ 80% COMPLÉTÉ

### 6.1 Prometheus

**URL** : http://35.180.38.208:9090  
**Status** : ✅ Healthy  
**Version** : Latest (prom/prometheus:latest)  
**Scrape interval** : 10 secondes  
**Target** : FastAPI (api:8000/metrics)

**Volume** : prometheus_data (persistent)

### 6.2 Grafana

**URL** : http://35.180.38.208:3000  
**Credentials** : admin / SecurePass2026!  
**Version** : 12.3.3  
**Status** : ✅ Database OK

**Volume** : grafana_data (persistent)

### 6.3 TODO

- [ ] Configurer datasource Prometheus dans Grafana
- [ ] Créer dashboards (HTTP, Python runtime)
- [ ] Configurer alerting rules (API down, error rate)

---

## 7) Jalons — Progression

| Jalon | Statut | % | Date | Preuve |
|-------|--------|---|------|--------|
| 1 - MVP local | ✅ | 100% | 2026-02-08 | Tests 7/7, Docker OK |
| 2 - Docker EC2 | ✅ | 100% | 2026-02-08 | Ansible OK |
| 3 - API Prod | ✅ | 100% | 2026-02-08 | http://35.180.38.208:8000 |
| 4 - Jenkins CI/CD | ✅ | 100% | 2026-02-22 | Build #6 SUCCESS |
| 5a - DevSecOps | ✅ | 100% | 2026-02-22 | Builds #7-10, Policy Gate |
| 5b - Terraform | ✅ | 100% | 2026-02-22 | EC2 i-0895fb26e33d874d8 |
| 6 - Observabilité | ⏳ | 80% | 2026-02-22 | Prometheus + Grafana OK |

**Score global** : 6.8/7 = **97% complété** 🎯

---

## 8) Problèmes Résolus

### 8.1 IP Dynamique (RÉSOLU ✅)
**Solution** : Script `scripts/update-aws-sg.sh`  
**Usage** : Exécuter avant chaque session  
**Statut** : Automatisé

### 8.2 EC2 Resources (RÉSOLU ✅)
**Problème** : t3.micro insuffisant (freeze Jenkins)  
**Solution** : Upgrade → t3.small (2GB RAM)  
**Statut** : Stable depuis upgrade

### 8.3 Dependency Conflicts (RÉSOLU ✅)
**Problème** : FastAPI 0.110 incompatible starlette 0.40  
**Solution** : Upgrade FastAPI → 0.115.6  
**Statut** : Build #9 SUCCESS

### 8.4 Prometheus .expose() (RÉSOLU ✅)
**Problème** : `.expose()` ne créait pas l'endpoint  
**Solution** : Approche manuelle `generate_latest()`  
**Statut** : /metrics fonctionnel

---

## 9) Session 2026-02-22 — Résumé

### Statistiques

| Métrique | Valeur |
|----------|--------|
| **Durée** | ~12 heures |
| **Commits** | 26 commits |
| **Builds Jenkins** | 10 (6 success, 4 instructifs) |
| **EC2 créées** | 1 (Terraform) |
| **Services déployés** | 2 (Prometheus + Grafana) |
| **Jalons complétés** | 3.8/4 (95%) |

### Accomplissements

1. ✅ **Jalon 4** : Jenkins CI/CD pipeline complet
2. ✅ **Jalon 5a** : DevSecOps (Trivy + Gitleaks + Policy Gate)
3. ✅ **Jalon 5b** : Terraform IaC (EC2 scans dédiée)
4. ⏳ **Jalon 6** : Observabilité (Prometheus + Grafana déployés)

### Défis Techniques Surmontés

1. EC2 overload → Upgrade t3.micro → t3.small
2. Jenkins freeze → Permissions Docker résolues
3. Dependency conflicts → FastAPI upgrade
4. Ansible YAML linting → 3 playbooks corrigés
5. Prometheus instrumentation → Approche manuelle
6. Multi-EC2 architecture → Terraform automation
7. Policy Gate → Enforcement démontré (Build #10)

---

## 10) Prochaines Étapes

### Court Terme (1-2h)
- [ ] Configurer Prometheus datasource Grafana
- [ ] Créer 2-3 dashboards basiques
- [ ] Configurer 1 alerte (API down)

### Moyen Terme (3-5h)
- [ ] README.md portfolio avec screenshots
- [ ] Architecture diagrams
- [ ] Badges GitHub (tests, security)

### Publication
- [ ] Post LinkedIn avec highlights
- [ ] GitHub public avec documentation

---

## ANNEXE - Commandes Essentielles

### Tests locaux
```bash
pytest -v
docker compose up --build -d
curl http://localhost:8000/health
```

### Déploiement
```bash
# Ansible
ansible-playbook -i ansible/inventories/staging/hosts.yml ansible/playbooks/deploy_api.yml

# Terraform
cd terraform/
terraform apply
```

### Monitoring
```bash
# Prometheus
curl http://35.180.38.208:9090/-/healthy

# Métriques API
curl http://35.180.38.208:8000/metrics

# Grafana
open http://35.180.38.208:3000
```

### AWS
```bash
# Update Security Group
./scripts/update-aws-sg.sh

# SSH EC2
ssh -i ~/.ssh/lab-devops-key.pem ubuntu@35.180.38.208
```

---

**FIN DU DOCUMENT**  
**Dernière modification** : 2026-02-22 19:00 UTC par administrator  
**Version** : 2.0  
**Statut projet** : ✅ **PRODUCTION READY** (97% complété)
