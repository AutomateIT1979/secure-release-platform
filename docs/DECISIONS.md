# Décisions techniques

- Backend: FastAPI (Python)
- DB: PostgreSQL
- Conteneurs: Docker + Docker Compose
- CI/CD: Jenkins
- Déploiement: Ansible
- Sécurité: gitleaks, semgrep, trivy, syft, cosign (plus tard)
- Observabilité: Prometheus + Grafana

Conventions:
- Images Docker taggées par commit SHA
- Environnements: staging puis prod
- Healthcheck obligatoire: /health
- Aucun secret dans Git (utiliser .env.example + Jenkins credentials)
