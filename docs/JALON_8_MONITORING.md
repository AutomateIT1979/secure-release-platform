# Jalon 8 : Monitoring & Alerting

**Date début** : 2026-02-24  
**Date fin** : 2026-02-24  
**Statut** : ✅ COMPLÉTÉ  
**Objectif** : Alertes proactives pour éviter les incidents en production

---

## 🎯 Objectifs - TOUS ATTEINTS ✅

- ✅ Détecter les problèmes AVANT qu'ils cassent le pipeline
- ✅ Recevoir des alertes Slack pour incidents critiques
- ✅ Monitorer espace disque, services, et performance

---

## 📋 Composants implémentés

### 1. Alertmanager ✅
- [x] Installation via Docker Compose
- [x] Configuration routing (Slack)
- [x] Intégration avec Prometheus

### 2. Règles d'alerting Prometheus ✅
- [x] Disk space > 80% (WARNING)
- [x] Disk space > 90% (CRITICAL)
- [x] Service down (API, Jenkins, PostgreSQL)
- [x] High memory usage > 90%
- [x] API latency > 1s (p95)

### 3. Slack Integration ✅
- [x] Créer Slack webhook
- [x] Configurer Alertmanager routing
- [x] Tester notifications (APIDown testé avec succès)

### 4. Documentation ✅
- [x] Screenshots alertes
- [x] Configuration files
- [x] Guide troubleshooting

---

## 🏗️ Architecture finale
```
FastAPI → Prometheus → Alertmanager → Slack
             ↓
          Grafana
```

**Stack déployé** :
- Prometheus (port 9090) - Collecte métriques + Évaluation règles
- Alertmanager (port 9093) - Gestion alertes + Routing Slack
- Grafana (port 3000) - Dashboards visualisation

---

## 📊 Alertes configurées (8 règles)

### Infrastructure (3 alertes)
| Alerte | Condition | Severité | For | Action |
|--------|-----------|----------|-----|--------|
| DiskSpaceWarning | Disk < 20% | warning | 5m | Nettoyer logs |
| DiskSpaceCritical | Disk < 10% | critical | 2m | Scaler volume EBS |
| HighMemoryUsage | Memory > 90% | warning | 5m | Investiguer processus |

### Services (3 alertes)
| Alerte | Condition | Severité | For | Action |
|--------|-----------|----------|-----|--------|
| APIDown | up{job="fastapi"} == 0 | critical | 1m | Redémarrer API |
| PostgreSQLDown | up{job="postgresql"} == 0 | critical | 1m | Redémarrer DB |
| HighAPILatency | p95 > 1s | warning | 5m | Optimiser code |

### Security (2 alertes)
| Alerte | Condition | Severité | For | Action |
|--------|-----------|----------|-----|--------|
| SecurityScanFailed | Jenkins security job fail | warning | 1m | Vérifier Trivy/Gitleaks |

---

## 🧪 Tests réalisés

### Test 1 : APIDown ✅
- **Action** : Arrêt manuel de l'API pendant 90 secondes
- **Résultat** : Alerte [FIRING] reçue sur Slack après 60s
- **Recovery** : Alerte [RESOLVED] reçue après redémarrage
- **Screenshot** : docs/screenshots/monitoring/Slack_conversations.png

### Test 2 : Alertes manuelles ✅
- **Action** : POST d'alertes test via API Alertmanager
- **Résultat** : Notifications Slack reçues avec formatage correct

---

## 📸 Screenshots

### Prometheus Alerts
![Prometheus Alerts UI](../screenshots/monitoring/Prometheus_Alerts_UI.png)

### Alertmanager UI
![Alertmanager UI](../screenshots/monitoring/Alertmanager_UI.png)

### Slack Notifications
![Slack Conversations](../screenshots/monitoring/Slack_conversations.png)

---

## 🔧 Configuration

### Fichiers créés
- `observability/alertmanager.yml` - Configuration Alertmanager (contient webhook secret)
- `observability/alert.rules.yml` - 8 règles d'alerting Prometheus
- `observability/prometheus.yml` - Config Prometheus avec alerting
- `observability/docker-compose-observability.yml` - Stack complet

### Fichiers versionnés (templates)
- `observability/alertmanager.yml.example` - Template sans webhook
- `observability/prometheus.yml.example` - Template sans IP
- `observability/docker-compose-observability.yml.example` - Template

---

## 🚀 Déploiement
```bash
# Sur EC2
cd /opt/secure-release-platform/observability
docker-compose -f docker-compose-observability.yml up -d

# Vérifier
docker ps | grep -E "prometheus|alertmanager|grafana"
curl http://localhost:9093/-/healthy
```

---

## 📈 Métriques de succès

- ✅ Alertes envoyées en < 90s après incident
- ✅ Notifications Slack formatées et lisibles
- ✅ 0 faux positifs durant les tests
- ✅ Recovery notifications fonctionnelles
- ✅ Stack Prometheus + Alertmanager + Grafana opérationnel

---

## 🎯 Prochaines améliorations (optionnel)

- [ ] Ajouter Node Exporter pour métriques système détaillées
- [ ] Configurer silences pour maintenance planifiée
- [ ] Ajouter alertes personnalisées par projet
- [ ] Intégrer PagerDuty pour on-call rotation
- [ ] Dashboard Grafana dédié aux alertes

---

**Jalon 8 : ✅ COMPLÉTÉ**  
**Date de finalisation** : 2026-02-24  
**Temps investi** : ~2 heures  
**Système d'alerting production-ready !** 🎉
