# Roadmap

## Jalon 1 — MVP local
- API + DB + migrations + tests
- Dockerfile + docker-compose local
Done: `docker compose up` + `/health` OK + tests OK

## Jalon 2 — CI
- Jenkins: lint + tests + build image
Done: push → pipeline vert/rouge + artefacts publiés

## Jalon 3 — CD staging
- Ansible déploie sur VM cible
- Smoke test + rollback N-1
Done: déploiement auto + rollback si KO

## Jalon 4 — DevSecOps
- gitleaks + semgrep + trivy + SBOM
- gate sur CRITICAL
Done: pipeline bloque si critique

## Jalon 5 — Observabilité
- logs JSON, métriques Prometheus, dashboard Grafana, alert basique
Done: alerte sur API down ou 5xx élevé
