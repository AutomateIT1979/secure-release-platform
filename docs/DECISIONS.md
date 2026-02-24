# Décisions Techniques - Secure Release Platform

**Date de création** : 2026-02-08  
**Dernière mise à jour** : 2026-02-24  
**Statut projet** : 100% complété (8/8 jalons)

---

## 1. Architecture & Stack Technique

### 1.1 Backend - FastAPI (Jalon 1)

**Décision** : Utiliser FastAPI comme framework API  
**Date** : 2026-02-08  
**Rationale** :
- Performance native (async/await)
- Documentation automatique (OpenAPI/Swagger)
- Validation Pydantic intégrée
- Support natif Prometheus metrics

**Alternatives considérées** :
- Django REST : Trop lourd pour ce cas d'usage
- Flask : Moins moderne, pas async natif

### 1.2 Base de données - PostgreSQL (Jalon 1)

**Décision** : PostgreSQL 15  
**Date** : 2026-02-08  
**Rationale** :
- ACID compliant
- Standard industrie
- Excellent support SQLAlchemy
- Docker officiel maintenu

### 1.3 Conteneurisation - Docker (Jalon 1)

**Décision** : Docker + Docker Compose  
**Date** : 2026-02-08  
**Rationale** :
- Isolation environnements
- Reproductibilité builds
- Standard DevOps
- Multi-stage builds pour images légères

**Convention** : Images taggées par `BUILD_NUMBER` Jenkins

---

## 2. Infrastructure & Déploiement

### 2.1 Cloud Provider - AWS (Jalon 2)

**Décision** : AWS EC2 (région eu-west-3 Paris)  
**Date** : 2026-02-08  
**Rationale** :
- Familiarité avec AWS
- Région Europe (RGPD)
- Free tier disponible
- Support Terraform mature

### 2.2 Configuration Management - Ansible (Jalon 2)

**Décision** : Ansible pour déploiements  
**Date** : 2026-02-08  
**Rationale** :
- Agentless (SSH only)
- YAML déclaratif
- Idempotent
- Courbe apprentissage faible

**Alternatives considérées** :
- Chef/Puppet : Trop complexe, nécessite agents
- Scripts Bash : Pas idempotent, difficilement maintenable

### 2.3 Infrastructure as Code - Terraform (Jalon 5b)

**Décision** : Terraform pour EC2 #2 (security scanning)  
**Date** : 2026-02-09  
**Rationale** :
- Séparation infrastructure vs configuration
- State management
- Plan/Apply workflow sécurisé
- Multi-cloud potentiel

**Pourquoi pas Ansible** : Ansible meilleur pour config, Terraform pour infra

---

## 3. CI/CD & Automation

### 3.1 Pipeline - Jenkins (Jalon 4)

**Décision** : Jenkins pour CI/CD  
**Date** : 2026-02-08  
**Rationale** :
- Open source, self-hosted
- Contrôle total sur infra
- Plugins matures (Docker, Ansible)
- Jenkinsfile as Code

**Alternatives considérées** :
- GitHub Actions : Coût pour runners privés
- GitLab CI : Nécessite GitLab complet
- CircleCI : Vendor lock-in

### 3.2 Git Repository - GitHub (Jalon 4)

**Décision** : GitHub comme remote Git  
**Date** : 2026-02-08  
**Rationale** :
- Intégration Jenkins native
- Portfolio public (LinkedIn)
- GitHub Actions disponible si besoin
- Community standards

**Problème résolu** : Jenkins (EC2) ne pouvait pas accéder repo local (WSL)

---

## 4. Sécurité (DevSecOps)

### 4.1 Secrets Scanning - Gitleaks (Jalon 5a)

**Décision** : Gitleaks pour détection secrets  
**Date** : 2026-02-09  
**Rationale** :
- Rapide (<5s)
- Patterns exhaustifs
- Intégration CI/CD simple
- Gratuit open source

### 4.2 Vulnerability Scanning - Trivy (Jalon 5a)

**Décision** : Trivy pour scan conteneurs  
**Date** : 2026-02-09  
**Rationale** :
- SBOM generation
- CVE database à jour
- Support multi-formats (Docker, Filesystem)
- Rapide et léger

**Alternatives considérées** :
- Snyk : Payant au-delà d'un seuil
- Clair : Nécessite PostgreSQL séparé
- Anchore : Plus complexe à setup

### 4.3 Policy Gates (Jalon 5a)

**Décision** : Bloquer build si HIGH ou CRITICAL  
**Date** : 2026-02-09  
**Rationale** :
- Empêche déploiement code vulnérable
- DevSecOps best practice
- Forçage culture sécurité

**Implémentation** : `--exit-code 1` dans Trivy

### 4.4 Secrets Management (Jalon 7)

**Décision** : `.gitignore` + `.example` templates  
**Date** : 2026-02-24  
**Rationale** :
- Simplicité
- Zéro secret dans Git
- Templates pour reproductibilité
- Compatible repository public

**Fichiers exclus** :
- `observability/alertmanager.yml` (webhook Slack)
- `observability/prometheus.yml` (IPs privées)
- `terraform/terraform.tfstate`

---

## 5. Observabilité

### 5.1 Metrics - Prometheus (Jalon 6)

**Décision** : Prometheus pour métriques  
**Date** : 2026-02-09  
**Rationale** :
- Standard industrie pour métriques
- Pull model (scalable)
- PromQL puissant
- Intégration FastAPI native

**Configuration** : Scrape interval 15s

### 5.2 Dashboards - Grafana (Jalon 6)

**Décision** : Grafana pour visualisation  
**Date** : 2026-02-09  
**Rationale** :
- UI intuitive
- Templating avancé
- Alerting (non utilisé, voir Jalon 8)
- Multi-datasources

**Dashboards créés** :
1. FastAPI HTTP Metrics
2. Python Runtime Metrics

### 5.3 Alerting - Alertmanager (Jalon 8)

**Décision** : Alertmanager séparé (pas Grafana Alerting)  
**Date** : 2026-02-24  
**Rationale** :
- Architecture Prometheus native (Prometheus → Alertmanager)
- Routing sophistiqué
- Grouping/Inhibition/Silencing
- Grafana Alerting moins mature

**Alternatives considérées** :
- Grafana Alerting : Plus simple mais moins puissant
- PagerDuty : Payant, overkill pour ce projet

### 5.4 Notifications - Slack (Jalon 8)

**Décision** : Slack webhook pour notifications  
**Date** : 2026-02-24  
**Rationale** :
- Gratuit (free workspace)
- Setup simple (webhook)
- Formatage riche (markdown)
- Standard industrie

**Alternatives considérées** :
- Email SMTP : Moins visuel pour portfolio
- MS Teams : Moins flexible
- Discord : Moins professionnel

---

## 6. Infrastructure Sizing

### 6.1 EC2 #1 - t3.small (Production)

**Décision initiale** : t3.micro → **Upgrade** t3.small  
**Date upgrade** : 2026-02-24  
**Rationale** :
- t3.micro insuffisant (Jenkins + 5 services)
- t3.small : 2 vCPU, 2GB RAM (confortable)
- Coût acceptable (~$15/mois)

### 6.2 Volume EBS - 16GB

**Décision initiale** : 8GB → **Upgrade** 16GB  
**Date upgrade** : 2026-02-24  
**Rationale** :
- Jenkins offline à 95% disk usage
- Docker images + logs consomment espace
- 16GB = 50% usage (marge confortable)

### 6.3 EC2 #2 - t3.micro (Security)

**Décision** : EC2 dédiée security scanning  
**Date** : 2026-02-09  
**Rationale** :
- Isolation security tools
- Évite surcharge EC2 principale
- Terraform démonstration
- t3.micro suffisant (scans légers)

---

## 7. Conventions & Standards

### 7.1 Git Workflow

**Décision** : Trunk-based development (single branch `main`)  
**Rationale** : Projet solo, pas besoin de branches

### 7.2 Commits

**Convention** : Conventional Commits  
**Format** : `type(scope): description`  
**Types** : feat, fix, docs, test, chore, refactor, ci, ansible

### 7.3 Health Checks

**Décision** : Endpoint `/health` obligatoire  
**Rationale** : Monitoring, load balancers, smoke tests

### 7.4 Documentation

**Décision** : Markdown dans `/docs`  
**Fichiers principaux** :
- `LAB_REFERENCE.md` : Source de vérité technique
- `LAB_STATE.md` : État infrastructure
- `PROJECT-STATE.md` : État jalons

### 7.5 Tests

**Décision** : Pytest avec coverage  
**Minimum** : Health check + API endpoints  
**CI** : Tests bloquent build si échec

---

## 8. Choix **Non** Faits (et Pourquoi)

### 8.1 Kubernetes

**Pourquoi non** : Overkill pour 2 services, complexité inutile

### 8.2 Microservices

**Pourquoi non** : Application simple, monolithe approprié

### 8.3 Load Balancer

**Pourquoi non** : Single instance, pas de HA nécessaire pour démo

### 8.4 Auto-scaling

**Pourquoi non** : Coût, complexité, pas nécessaire pour portfolio

### 8.5 Multi-region

**Pourquoi non** : Coût, complexité, démo single-region suffisante

---

## 9. Problèmes Résolus & Décisions Correctives

### 9.1 IP Dynamique (Jalon 2)

**Problème** : IP publique locale change (NordVPN + DHCP)  
**Solution** : Script `update-aws-sg.sh` auto-update Security Group  
**Décision** : Accepter IP dynamique, automatiser mise à jour

### 9.2 Jenkins-Git Connectivité (Jalon 4)

**Problème** : Jenkins (EC2) ne peut pas clone repo local (WSL)  
**Solution** : Repository GitHub public  
**Décision** : GitHub comme source of truth

### 9.3 Grafana Data Source (Jalon 6)

**Problème** : `http://prometheus:9090` (DNS Docker) inaccessible depuis Grafana  
**Solution** : IP privée EC2 `http://172.31.7.253:9090`  
**Décision** : Utiliser IPs privées pour communication inter-services

### 9.4 Disk Space Critical (Jalon 7)

**Problème** : Jenkins offline à 95% disk usage  
**Solution** : Volume EBS 8GB → 16GB  
**Décision** : Scaler infra quand nécessaire, accepter coût marginal

---

## 10. Leçons Apprises

1. **Vérifier avant supposer** : Toujours valider état système
2. **Scalabilité progressive** : Commencer petit, scaler si besoin
3. **Documentation continue** : Documenter décisions au fur et à mesure
4. **Security by design** : Intégrer sécurité dès le début, pas après
5. **Monitoring essentiel** : Alerting aurait évité disk space issue

---

**Dernière mise à jour** : 2026-02-24  
**Par** : administrator  
**Statut** : Complet (8/8 jalons documentés)
