# Jalon 8 : Monitoring & Alerting

**Date début** : 2026-02-24  
**Statut** : 🔄 EN COURS  
**Objectif** : Alertes proactives pour éviter les incidents en production

---

## 🎯 Objectifs

- Détecter les problèmes AVANT qu'ils cassent le pipeline
- Recevoir des alertes Slack pour incidents critiques
- Monitorer espace disque, services, et performance

---

## 📋 Composants à implémenter

### 1. Alertmanager
- [ ] Installation via Docker Compose
- [ ] Configuration routing (Slack)
- [ ] Intégration avec Prometheus

### 2. Règles d'alerting Prometheus
- [ ] Disk space > 80% (WARNING)
- [ ] Disk space > 90% (CRITICAL)
- [ ] Service down (API, Jenkins, PostgreSQL)
- [ ] High memory usage > 90%
- [ ] API latency > 1s (p95)

### 3. Slack Integration
- [ ] Créer Slack webhook
- [ ] Configurer Alertmanager routing
- [ ] Tester notifications

### 4. Documentation
- [ ] Runbook pour chaque alerte
- [ ] Guide troubleshooting
- [ ] Screenshots alertes

---

## 🏗️ Architecture cible
```
Prometheus → Alertmanager → Slack
     ↓
  Grafana (dashboards)
```

---

## 📊 Alertes prioritaires

| Alerte | Condition | Severité | Action |
|--------|-----------|----------|--------|
| DiskSpaceWarning | > 80% | WARNING | Nettoyer logs |
| DiskSpaceCritical | > 90% | CRITICAL | Scaler volume |
| ServiceDown | Health check fail | CRITICAL | Redémarrer service |
| HighMemory | > 90% | WARNING | Investiguer |
| APILatency | p95 > 1s | WARNING | Optimiser code |

---

## 🚀 Next Steps

1. Installer Alertmanager
2. Configurer règles Prometheus
3. Setup Slack webhook
4. Tester alertes
