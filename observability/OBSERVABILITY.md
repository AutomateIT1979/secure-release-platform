# Observabilité - Prometheus + Grafana

**Status** : ✅ Opérationnel (95% complété)  
**Date déploiement** : 2026-02-22

---

## Services Déployés

### Prometheus
- **URL** : http://35.180.38.208:9090
- **Version** : Latest (prom/prometheus:latest)
- **Scrape interval** : 10 secondes
- **Target** : FastAPI (api:8000/metrics)
- **Status** : ✅ Healthy

### Grafana
- **URL** : http://35.180.38.208:3000
- **Credentials** : admin / SecurePass2026!
- **Version** : 12.3.3
- **Status** : ✅ Database OK

---

## Datasource

**Prometheus Datasource** :
- ID : 1
- UID : bfe5d3pbp3nr4a
- URL : http://prometheus:9090
- Default : Yes ✅

---

## Dashboards

### 1. FastAPI HTTP Metrics
**UID** : b81d8f20-db78-4e9c-951d-93638c5e942a  
**URL** : http://35.180.38.208:3000/d/b81d8f20-db78-4e9c-951d-93638c5e942a/fastapi-http-metrics

**Panels** :
- HTTP Request Rate (rate per second)
- HTTP Status Codes (2xx, 4xx, 5xx)
- Request Duration p95 (latency)
- Active Requests (in-progress)
- Total Requests (counter)

### 2. Python Runtime Metrics
**UID** : 4c122fd6-6d7b-46df-97c6-ce89e9adcfd8  
**URL** : http://35.180.38.208:3000/d/4c122fd6-6d7b-46df-97c6-ce89e9adcfd8/python-runtime-metrics

**Panels** :
- Memory Usage (Resident + Virtual)
- CPU Usage (rate)
- Garbage Collection (Gen 0/1/2)
- Open File Descriptors
- Python Info

---

## Métriques Exposées

### HTTP Metrics (Prometheus FastAPI Instrumentator)
```
http_requests_total                    # Total requests by method, status, handler
http_request_size_bytes                # Request size
http_request_duration_seconds          # Request duration histogram
http_requests_inprogress               # Active requests
```

### Python Runtime Metrics
```
python_gc_objects_collected_total      # GC objects collected
python_gc_collections_total            # GC cycles
python_info                            # Python version info
process_resident_memory_bytes          # RSS memory
process_virtual_memory_bytes           # Virtual memory
process_cpu_seconds_total              # CPU time
process_open_fds                       # Open file descriptors
```

---

## Alerting (Configuration partielle)

**Status** : Infrastructure prête, configuration manuelle requise

**Alerte prévue** : API Health Check Failed
- Condition : `up{job="fastapi"} == 0`
- Duration : 5 minutes
- Severity : Critical

**Configuration manuelle nécessaire** :
1. Créer folder "Alerting" dans Grafana UI
2. Recréer l'alerte via l'interface
3. Configurer notification channels (email, Slack, etc.)

---

## Architecture
```
FastAPI:8000
    ↓ /metrics (exposition)
Prometheus:9090
    ↓ scrape every 10s
Grafana:3000
    ↓ visualisation
Dashboards + Alerting
```

---

## Métriques Projet

| Métrique | Valeur |
|----------|--------|
| Dashboards créés | 2 |
| Panels total | 10 |
| Datasources | 1 (Prometheus) |
| Refresh interval | 10 secondes |
| Time range | 1 heure (configurable) |

---

## Prochaines Étapes (Optionnelles)

- [ ] Configurer folder Alerting dans Grafana
- [ ] Créer alertes supplémentaires (Error rate > 5%, Response time > 1s)
- [ ] Configurer notification channels (email, Slack)
- [ ] Ajouter dashboard pour PostgreSQL metrics
- [ ] Exporter dashboards en JSON pour versioning

---

**Jalon 6 - Observabilité** : ✅ **95% Complété** 🎯
