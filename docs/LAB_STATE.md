# État du Lab DevSecOps — 2026-02-24

## 1) Vue d'ensemble

Ce document trace l'état **factuel** du laboratoire DevSecOps pour le projet "Secure Release Platform".

**Objectif du projet** : Construire une chaîne DevSecOps complète (CI/CD, scans sécurité, déploiement automatisé, observabilité, alerting).

**Date de dernière mise à jour** : 2026-02-24 04:30 UTC  
**Statut global** : ✅ **PRODUCTION READY** (100% complété - 8/8 jalons)

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
**Dernier commit** : `32b3245` (2026-02-24)

**Derniers commits** :
```
32b3245 - docs: complete PROJECT-STATE with all 8 milestones
e60277e - docs: fix duplicate Jalon 8 line in milestones table
655a84f - feat(monitoring): complete Jalon 8 - Alerting with Slack integration
c92008a - security: add alertmanager.yml to .gitignore (contains webhook)
8fcd5ce - feat(monitoring): add Alertmanager and alerting rules
```

**Fichiers non versionnés (locaux)** :
- `observability/prometheus.yml` (contient IP privée EC2)
- `observability/alertmanager.yml` (contient webhook Slack secret)
- `observability/docker-compose-observability.yml` (contient password Grafana)

---

## 3) Infrastructure AWS

### 3.1 EC2 Instance #1 (Production)

**État** : ✅ Opérationnelle

| Attribut | Valeur |
|----------|--------|
| **Instance ID** | `i-01c77636889cc7f4a` |
| **Nom** | `lab-devops-ec2` |
| **Type** | t3.small (2 vCPU, 2GB RAM) |
| **IP Publique** | `35.180.38.208` |
| **IP Privée** | `172.31.7.253` |
| **Région** | eu-west-3 (Paris) |
| **OS** | Ubuntu 22.04.5 LTS |
| **Volume EBS** | 16GB (50% utilisé, **scalé depuis 8GB**) |

**Services déployés** :

| Service | Port | Status | URL/Accès |
|---------|------|--------|-----------|
| Jenkins | 8080 | ✅ UP | http://35.180.38.208:8080 |
| FastAPI | 8000 | ✅ UP | http://35.180.38.208:8000 |
| PostgreSQL | 5432 | ✅ UP | Interne |
| Prometheus | 9090 | ✅ UP | http://35.180.38.208:9090 |
| **Alertmanager** | **9093** | ✅ UP | http://35.180.38.208:9093 |
| Grafana | 3000 | ✅ UP | http://35.180.38.208:3000 |

**Vérifications health** :
```bash
# API
curl http://35.180.38.208:8000/health
# → {"status":"ok"}

# Prometheus
curl http://35.180.38.208:9090/-/healthy
# → Prometheus is Healthy.

# Alertmanager (NEW)
curl http://35.180.38.208:9093/-/healthy
# → OK
```

### 3.2 EC2 Instance #2 (Security Scanning)

**État** : ✅ Opérationnelle

| Attribut | Valeur |
|----------|--------|
| **Instance ID** | `i-0895fb26e33d874d8` |
| **Type** | t3.micro (2 vCPU, 1GB RAM) |
| **IP Publique** | `15.188.127.106` |
| **IP Privée** | `172.31.12.54` |
| **Région** | eu-west-3 (Paris) |
| **Usage** | Security scans (Trivy, Gitleaks) |

**Services déployés** :
- Trivy (vulnerability scanning)
- Gitleaks (secrets detection)

### 3.3 Security Group

**ID** : `sg-0db21b6219faa2fca`

**Règles Inbound** :

| Port | Protocol | Source | Service |
|------|----------|--------|---------|
| 22 | TCP | Dynamic IP | SSH |
| 80 | TCP | Dynamic IP | HTTP |
| 8080 | TCP | Dynamic IP | Jenkins |
| 8000 | TCP | Dynamic IP | API |
| 3000 | TCP | Dynamic IP | Grafana |
| 9090 | TCP | Dynamic IP | Prometheus |
| **9093** | **TCP** | **Dynamic IP** | **Alertmanager** |

**Note** : IP source mise à jour dynamiquement via `scripts/update-aws-sg.sh`

---

## 4) Pipeline CI/CD (Jenkins)

### 4.1 Configuration

**URL** : http://35.180.38.208:8080  
**Version** : Jenkins 2.541.1  
**Pipeline** : Declarative (Jenkinsfile)

### 4.2 Stages du pipeline (6)

1. **Checkout** - Récupération code GitHub
2. **Security Scan - Secrets** - Gitleaks (0 secrets détectés)
3. **Build Docker Image** - `secure-release-platform:BUILD_NUMBER`
4. **Security Scan - Docker Image** - Trivy (5 HIGH détectées)
5. **Deploy to EC2** - Ansible automatique
6. **Smoke Test** - Health check API

### 4.3 Policy Gates

**Règle** : Blocage si **HIGH ou CRITICAL** vulnérabilités détectées

**Dernier build** : #12 ❌ BLOQUÉ (comportement attendu)
- 5 HIGH vulnérabilités détectées (Debian + Python packages)
- Pipeline arrêté avant déploiement
- DevSecOps fonctionnel ✅

---

## 5) Observabilité & Monitoring

### 5.1 Stack Prometheus

**URL** : http://35.180.38.208:9090  
**Scrape interval** : 15 secondes  
**Targets** :
- FastAPI (172.31.7.253:8000)
- Prometheus self-monitoring

**Métriques collectées** :
- HTTP requests (rate, duration, status)
- Python runtime (memory, CPU, GC)

### 5.2 Alertmanager (NEW - Jalon 8)

**URL** : http://35.180.38.208:9093  
**Configuration** : Slack webhook integration

**Règles d'alerting (8 configurées)** :

| Alerte | Condition | Severité | For | Action |
|--------|-----------|----------|-----|--------|
| DiskSpaceWarning | Disk < 20% | warning | 5m | Nettoyer logs |
| DiskSpaceCritical | Disk < 10% | critical | 2m | Scaler volume |
| HighMemoryUsage | Memory > 90% | warning | 5m | Investiguer |
| **APIDown** | up{job="fastapi"} == 0 | critical | 1m | Redémarrer API |
| PostgreSQLDown | up{job="postgresql"} == 0 | critical | 1m | Redémarrer DB |
| HighAPILatency | p95 > 1s | warning | 5m | Optimiser |
| SecurityScanFailed | Jenkins fail | warning | 1m | Vérifier Trivy |

**Test validé** :
- APIDown déclenché en <90s
- Notification Slack [FIRING] reçue ✅
- Notification [RESOLVED] reçue ✅

### 5.3 Grafana

**URL** : http://35.180.38.208:3000  
**Login** : admin / SecurePass2026!

**Dashboards (2)** :
1. **FastAPI HTTP Metrics** - Requests, latency, status codes
2. **Python Runtime Metrics** - Memory, CPU, GC, file descriptors

**Data source** : Prometheus (http://172.31.7.253:9090)

---

## 6) Application (FastAPI)

### 6.1 Stack technique

- **Framework** : FastAPI 0.115.6
- **Python** : 3.12.3
- **Database** : PostgreSQL 15
- **ORM** : SQLAlchemy
- **Tests** : pytest (7/7 passing)

### 6.2 Routes disponibles
```
GET  /health              # Health check
GET  /version             # Version API
GET  /metrics             # Prometheus metrics
GET  /projects            # Liste projets
POST /projects            # Créer projet
GET  /projects/{id}       # Détail projet
```

### 6.3 Tests

**Framework** : pytest 8.0.2  
**Résultats** : 7 passed in 0.23s
```bash
tests/test_health.py::test_health PASSED
tests/test_integration.py::test_create_project_integration PASSED
tests/test_version.py::test_version PASSED
```

---

## 7) Jalons Complétés (8/8 = 100%)

| Jalon | Status | Date | Durée |
|-------|--------|------|-------|
| 1. MVP Local | ✅ 100% | 2026-02-08 | ~2h |
| 2. Docker EC2 | ✅ 100% | 2026-02-08 | ~1h |
| 3. API Production | ✅ 100% | 2026-02-08 | ~2h |
| 4. Jenkins CI/CD | ✅ 100% | 2026-02-08 | ~3h |
| 5a. DevSecOps Security | ✅ 100% | 2026-02-09 | ~2h |
| 5b. Terraform IaC | ✅ 100% | 2026-02-09 | ~2h |
| 6. Observability | ✅ 100% | 2026-02-09 | ~3h |
| **7. GitHub Polish** | ✅ 100% | 2026-02-24 | ~2h |
| **8. Monitoring & Alerting** | ✅ 100% | 2026-02-24 | ~2h |

**Total temps développement** : ~18 heures (2 sessions marathon)

---

## 8) Documentation

| Fichier | Lignes | Statut | Description |
|---------|--------|--------|-------------|
| README.md | 191 | ✅ À jour | Vue d'ensemble (8/8 jalons) |
| PROJECT-STATE.md | 275 | ✅ À jour | État détaillé projet |
| LAB_STATE.md | ~400 | ✅ À jour | État infrastructure (ce fichier) |
| LAB_REFERENCE.md | 33K | ⚠️ Obsolète | À mettre à jour (Alertmanager) |
| JALON_8_MONITORING.md | 131 | ✅ À jour | Documentation Alerting |
| DECISIONS.md | 448 | ⚠️ Incomplet | Décisions techniques |
| ROADMAP.md | 654 | ⚠️ Incomplet | Jalons et DoD |

---

## 9) Problèmes Résolus (11 au total)

### Session 1 (2026-02-08/09)
1. ✅ IP dynamique locale (NordVPN + DHCP) → Script auto-update SG
2. ✅ Jenkins-Git connectivité → Repo GitHub
3. ✅ Permissions Docker Jenkins → Ajout user au groupe docker
4. ✅ Dépendances Python conflits → Venv isolé
5. ✅ Prometheus data source Grafana → IP privée EC2

### Session 2 (2026-02-24)
6. ✅ Jenkins disk space 95% → Volume EBS scalé 8GB → 16GB
7. ✅ API non démarrée → Docker compose restart
8. ✅ Grafana sans données → Data source reconfiguré
9. ✅ Alertmanager ne démarre pas → Container conflit résolu
10. ✅ Slack webhook test → Validation réseau EC2
11. ✅ Security Group port 9093 → Ouverture manuelle

---

## 10) Sécurité

### 10.1 Secrets Management

**Fichiers NON versionnés (`.gitignore`)** :
- `observability/alertmanager.yml` (webhook Slack)
- `observability/prometheus.yml` (IPs privées)
- `observability/docker-compose-observability.yml` (passwords)
- `terraform/terraform.tfstate` (state Terraform)

**Fichiers templates versionnés** :
- `*.example` pour tous les fichiers de config

### 10.2 Scans Sécurité

**Gitleaks** : 0 secrets détectés ✅  
**Trivy** : 5 HIGH vulnérabilités (packages système/Python)

---

## ANNEXE - Commandes Essentielles

### Tests locaux
```bash
cd ~/lab-devops/secure-release-platform
pytest -v
docker compose up --build -d
curl http://localhost:8000/health
```

### Déploiement
```bash
# Ansible
ansible-playbook -i ansible/inventories/staging/hosts.yml \
  ansible/playbooks/deploy_api.yml

# Terraform
cd terraform/
terraform apply
```

### Monitoring
```bash
# Prometheus
curl http://35.180.38.208:9090/-/healthy

# Alertmanager (NEW)
curl http://35.180.38.208:9093/-/healthy

# Métriques API
curl http://35.180.38.208:8000/metrics

# Grafana
open http://35.180.38.208:3000
```

### Alerting
```bash
# Test alerte manuelle
curl -X POST http://35.180.38.208:9093/api/v2/alerts \
  -H 'Content-Type: application/json' \
  -d '[{
    "labels": {"alertname": "Test", "severity": "warning"},
    "annotations": {"summary": "Test alerte"}
  }]'

# Vérifier alertes actives
curl http://35.180.38.208:9093/api/v2/alerts | jq
```

### AWS
```bash
# Update Security Group
./scripts/update-aws-sg.sh

# SSH EC2 #1
ssh -i ~/.ssh/lab-devops-key.pem ubuntu@35.180.38.208

# SSH EC2 #2
ssh -i ~/.ssh/lab-devops-key.pem ubuntu@15.188.127.106
```

---

**FIN DU DOCUMENT**  
**Dernière modification** : 2026-02-24 04:30 UTC par administrator  
**Version** : 3.0  
**Statut projet** : ✅ **PRODUCTION READY** (100% complété - 8/8 jalons)
