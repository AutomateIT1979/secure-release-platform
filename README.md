# Secure Release Platform

Objectif : démontrer des compétences DevOps/DevSecOps sur un projet applicatif complet :
CI/CD (Jenkins), déploiement automatisé (Ansible), conteneurisation (Docker), scans sécurité,
observabilité (Prometheus/Grafana), rollback, documentation et runbooks.

## Démo attendue
- Un commit déclenche : tests → build image → scans → déploiement staging → smoke test
- Promotion manuelle vers prod
- Rollback automatique si healthcheck KO

## Structure
- docs/ROADMAP.md : jalons + Definition of Done
- docs/DECISIONS.md : décisions techniques
- docs/PROJECT_STATE.md : état actuel (source de vérité pour reprendre le projet)
- docs/RUNBOOKS/ : procédures incidents
