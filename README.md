# 🚀 Secure Release Platform - DevSecOps Pipeline

> Complete end-to-end DevSecOps platform demonstrating CI/CD automation, security scanning, Infrastructure as Code, and production observability.

[![CI/CD Status](https://img.shields.io/badge/CI%2FCD-Jenkins-blue?logo=jenkins)](http://YOUR_EC2_PUBLIC_IP_1:8080)
[![Security](https://img.shields.io/badge/Security-Trivy%20%2B%20Gitleaks-green?logo=security)](https://github.com/AutomateIT1979/secure-release-platform)
[![Infrastructure](https://img.shields.io/badge/Infrastructure-Terraform%20%2B%20Ansible-purple?logo=terraform)](https://github.com/AutomateIT1979/secure-release-platform)
[![Monitoring](https://img.shields.io/badge/Monitoring-Prometheus%20%2B%20Grafana-orange?logo=grafana)](http://YOUR_EC2_PUBLIC_IP_1:3000)

---

## 📊 Project Stats

| Metric | Value |
|--------|-------|
| **Development Time** | 15+ hours (marathon session) |
| **Git Commits** | 33+ commits |
| **Jenkins Builds** | 10+ successful builds |
| **Lines of Code/Config** | 2,800+ lines |
| **Technologies Mastered** | 16+ technologies |
| **Infrastructure** | 2 AWS EC2 instances |
| **Services Deployed** | 5 production services |
| **Completion Rate** | 100% (7/7 milestones) |

---

## 🏗️ Architecture Overview
```mermaid
graph TB
    subgraph EC2_1["🖥️ EC2 Instance #1 (t3.small - Production)"]
        subgraph Jenkins["⚙️ Jenkins CI/CD Pipeline (6 stages)"]
            J1[1. Checkout]
            J2[2. Security: Secrets Scan - Gitleaks]
            J3[3. Build: Docker Image]
            J4[4. Security: Container Scan - Trivy]
            J5[5. Deploy to Production]
            J6[6. Smoke Test]
            J1 --> J2 --> J3 --> J4 --> J5 --> J6
        end
        
        subgraph API["🚀 FastAPI Application + PostgreSQL"]
            API1[REST API - CRUD operations]
            API2[Prometheus metrics instrumentation]
            API3[Health checks & versioning]
        end
        
        subgraph OBS["📊 Observability Stack"]
            PROM[Prometheus: Metrics collection - 10s scrape]
            GRAF[Grafana: 2 dashboards - HTTP + Runtime]
        end
    end
    
    subgraph EC2_2["🖥️ EC2 Instance #2 (t3.micro - Security Scanning)"]
        TERRA[Deployed via Terraform - Infrastructure as Code]
        subgraph SEC["🔒 Security Scanning Services"]
            TRIVY[Trivy: Container vulnerability scanning]
            GITLEAKS[Gitleaks: Secret detection]
        end
    end
    
    Jenkins -.->|triggers| API
    API -->|exposes| PROM
    PROM -->|data source| GRAF
    Jenkins -->|scans on| SEC

    style EC2_1 fill:#e1f5ff,stroke:#01579b,stroke-width:2px
    style EC2_2 fill:#fff3e0,stroke:#e65100,stroke-width:2px
    style Jenkins fill:#e8f5e9,stroke:#2e7d32,stroke-width:2px
    style API fill:#f3e5f5,stroke:#6a1b9a,stroke-width:2px
    style OBS fill:#fff9c4,stroke:#f57f17,stroke-width:2px
    style SEC fill:#ffebee,stroke:#c62828,stroke-width:2px
```

**Infrastructure Details:**
- **EC2 #1**: Jenkins + FastAPI + PostgreSQL + Prometheus + Grafana
- **EC2 #2**: Trivy + Gitleaks (Terraform-managed)
- **Communication**: Private IPs within VPC, public IPs for external access

---


## ✨ Key Features

### 🔄 CI/CD Automation
- ✅ **6-stage Jenkins pipeline** with automated testing, building, and deployment
- ✅ **Policy gates** blocking builds with CRITICAL vulnerabilities
- ✅ **Automated smoke tests** validating deployments
- ✅ **10+ successful builds** demonstrating reliability

### 🔒 DevSecOps Integration
- ✅ **Trivy container scanning** detecting vulnerabilities pre-deployment
- ✅ **Gitleaks secret detection** preventing credential leaks
- ✅ **Security-first approach** with enforcement at build time
- ✅ **0 secrets exposed** - sanitized repository for public release

### ☁️ Infrastructure as Code
- ✅ **Terraform** managing dedicated EC2 for security scans
- ✅ **Ansible** automating Docker installation and API deployment
- ✅ **Reproducible infrastructure** with version-controlled configs
- ✅ **Multi-instance architecture** separating concerns

### 📈 Production Observability
- ✅ **Prometheus** collecting custom application metrics
- ✅ **Grafana dashboards** visualizing HTTP metrics and Python runtime
- ✅ **Real-time monitoring** tracking 286+ requests
- ✅ **Production-ready** metrics instrumentation

---

## 🛠️ Tech Stack

### Backend & Application
![Python](https://img.shields.io/badge/Python-3.12-blue?logo=python)
![FastAPI](https://img.shields.io/badge/FastAPI-0.115.6-009688?logo=fastapi)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15-336791?logo=postgresql)
![SQLAlchemy](https://img.shields.io/badge/SQLAlchemy-ORM-red)

### CI/CD & Automation
![Jenkins](https://img.shields.io/badge/Jenkins-2.541-red?logo=jenkins)
![Docker](https://img.shields.io/badge/Docker-29.1-2496ED?logo=docker)
![GitHub](https://img.shields.io/badge/GitHub-Actions-black?logo=github)

### Security & Scanning
![Trivy](https://img.shields.io/badge/Trivy-Aqua-blue?logo=aqua)
![Gitleaks](https://img.shields.io/badge/Gitleaks-Secret%20Detection-yellow)

### Infrastructure & Provisioning
![Terraform](https://img.shields.io/badge/Terraform-1.5+-844FBA?logo=terraform)
![Ansible](https://img.shields.io/badge/Ansible-Automation-red?logo=ansible)
![AWS](https://img.shields.io/badge/AWS-EC2-orange?logo=amazon-aws)

### Monitoring & Observability
![Prometheus](https://img.shields.io/badge/Prometheus-Metrics-orange?logo=prometheus)
![Grafana](https://img.shields.io/badge/Grafana-Dashboards-orange?logo=grafana)

---

## 🎯 Completed Milestones (7/7 = 100%)

| Milestone | Status | Description |
|-----------|--------|-------------|
| **1. MVP Local** | ✅ 100% | FastAPI API + PostgreSQL + Docker + Tests (7/7) |
| **2. Docker EC2** | ✅ 100% | Ansible playbook deploying Docker to AWS EC2 |
| **3. API Production** | ✅ 100% | Production deployment with Ansible automation |
| **4. Jenkins CI/CD** | ✅ 100% | Complete 6-stage pipeline with 10 builds |
| **5a. DevSecOps Security** | ✅ 100% | Trivy + Gitleaks + Policy gates |
| **5b. Terraform IaC** | ✅ 100% | Dedicated EC2 for security scanning |
| **6. Observability** | ✅ 100% | Prometheus + Grafana + 2 dashboards |

---

## 📸 Screenshots

### Jenkins CI/CD Pipeline
*6-stage DevSecOps pipeline with security gates*
![Jenkins Pipeline](docs/screenshots/jenkins-pipeline.png)

### Grafana Dashboards
*Real-time application monitoring*
![Grafana HTTP Metrics](docs/screenshots/grafana-http-metrics.png)
![Grafana Runtime](docs/screenshots/grafana-runtime.png)

### Trivy Security Scan
*Container vulnerability detection*
![Trivy Scan](docs/screenshots/trivy-scan.png)

---

## 🚀 Getting Started

### Prerequisites
- AWS Account with EC2 access
- Terraform 1.5+
- Ansible 2.19+
- Docker & Docker Compose
- Python 3.12+

### Quick Start

1. **Clone the repository**
```bash
git clone https://github.com/AutomateIT1979/secure-release-platform.git
cd secure-release-platform
```

2. **Set up local environment**
```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

3. **Run tests**
```bash
pytest -v
```

4. **Start local stack**
```bash
docker-compose up --build -d
curl http://localhost:8000/health
```

5. **Deploy to AWS**
```bash
# Configure AWS credentials
# Update ansible/inventories/staging/hosts.yml with your EC2 IP

# Deploy infrastructure
cd terraform
terraform init
terraform apply

# Deploy application
ansible-playbook -i ansible/inventories/staging/hosts.yml \
  ansible/playbooks/deploy_api.yml
```

---

## 📚 Documentation

| Document | Description |
|----------|-------------|
| [LAB_REFERENCE.md](docs/LAB_REFERENCE.md) | Complete technical reference & source of truth |
| [LAB_STATE.md](docs/LAB_STATE.md) | Current project state & infrastructure details |
| [ROADMAP.md](docs/ROADMAP.md) | Milestones & Definition of Done |
| [DECISIONS.md](docs/DECISIONS.md) | Technical decisions & rationale |
| [OBSERVABILITY.md](observability/OBSERVABILITY.md) | Monitoring setup & dashboards |

---

## 🏆 Key Achievements

### Technical Excellence
- 🎯 **100% milestone completion** - All 7 milestones delivered
- 🔥 **15-hour marathon session** - Sustained focus and delivery
- 🐛 **11 complex problems solved** - Including EC2 upgrades, dependency conflicts, networking issues
- 📝 **50K+ documentation** - Comprehensive technical documentation
- ✅ **Zero security incidents** - Sanitized repository with no exposed secrets

### DevOps Practices Demonstrated
- **Infrastructure as Code** - Terraform + Ansible automation
- **Security-First Development** - Automated scanning with policy enforcement
- **Production Monitoring** - Full observability stack
- **CI/CD Automation** - End-to-end Jenkins pipeline
- **Documentation Standards** - Comprehensive technical docs

---

## 🔐 Security Notice

This repository has been **sanitized for public release**:
- ✅ All IP addresses replaced with placeholders
- ✅ All credentials removed from version history
- ✅ Sensitive configuration files excluded via `.gitignore`
- ✅ Example templates provided for local setup

**Local configuration files** (not tracked in Git):
- `observability/prometheus.yml` - Use `.example` as template
- `observability/docker-compose-observability.yml` - Use `.example` as template
- `terraform/terraform.tfstate` - Generated locally

---

## 📞 Contact & Links

**Author**: N8n DevOps Engineer  
**LinkedIn**: [AutomateIT1979](https://www.linkedin.com/in/automateit1979/)  
**GitHub**: [AutomateIT1979](https://github.com/AutomateIT1979)

**Live Demo** (when EC2 running):
- API: `http://YOUR_EC2_PUBLIC_IP:8000`
- Jenkins: `http://YOUR_EC2_PUBLIC_IP:8080`
- Grafana: `http://YOUR_EC2_PUBLIC_IP:3000`

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- Built as part of professional DevSecOps portfolio development
- Demonstrates real-world enterprise DevOps practices
- Designed for LinkedIn and GitHub portfolio presentation

---

**⭐ If you find this project helpful, please star the repository!**
