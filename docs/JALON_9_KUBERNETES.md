# Jalon 9 : Migration vers Kubernetes (AKS)

**Date de début** : 2026-02-25  
**Statut** : 🔄 EN COURS  
**Objectif** : Migrer l'application FastAPI vers Azure Kubernetes Service (AKS)

---

## 🎯 Objectifs

### Objectif Principal
Démontrer la capacité à orchestrer des conteneurs en production avec Kubernetes, standard industrie pour 80%+ des entreprises.

### Objectifs Secondaires
- ✅ Compétence multi-cloud (AWS → Azure)
- ✅ Maîtrise Kubernetes (pods, deployments, services)
- ✅ Auto-scaling automatique
- ✅ Zero-downtime deployments
- ✅ Infrastructure déclarative (YAML)

---

## 🏗️ Architecture Cible

### Avant (AWS EC2 - Actuel)
```
┌─────────────────────────────────────┐
│      AWS EC2 (t3.small)             │
│  ┌──────────┐  ┌──────────────┐    │
│  │ FastAPI  │  │ PostgreSQL   │    │
│  │  :8000   │  │    :5432     │    │
│  └──────────┘  └──────────────┘    │
│  ┌──────────┐  ┌──────────────┐    │
│  │Prometheus│  │ Alertmanager │    │
│  └──────────┘  └──────────────┘    │
└─────────────────────────────────────┘
```

### Après (Azure AKS - Jalon 9)
```
┌────────────────────────────────────────────────────┐
│         Azure Kubernetes Service (AKS)             │
│  ┌──────────────────────────────────────────────┐ │
│  │              Kubernetes Cluster               │ │
│  │  ┌─────────┐  ┌─────────┐  ┌─────────┐      │ │
│  │  │ Node 1  │  │ Node 2  │  │ Node 3  │      │ │
│  │  │(B2s)    │  │(B2s)    │  │(B2s)    │      │ │
│  │  └─────────┘  └─────────┘  └─────────┘      │ │
│  │                                               │ │
│  │  Pods:                                        │ │
│  │  ┌──────────────┐  ┌──────────────┐         │ │
│  │  │ fastapi-pod  │  │ fastapi-pod  │         │ │
│  │  │  (replica 1) │  │  (replica 2) │         │ │
│  │  └──────────────┘  └──────────────┘         │ │
│  │  ┌──────────────┐                            │ │
│  │  │postgres-pod  │                            │ │
│  │  │ (StatefulSet)│                            │ │
│  │  └──────────────┘                            │ │
│  └──────────────────────────────────────────────┘ │
│                                                    │
│  ┌──────────────────┐  ┌──────────────────┐      │
│  │  Load Balancer   │  │ Ingress NGINX    │      │
│  │  (Public IP)     │  │  (Routing)       │      │
│  └──────────────────┘  └──────────────────┘      │
└────────────────────────────────────────────────────┘
         ▲
         │
    Internet Traffic
```

---

## 📋 Prérequis

### Outils à Installer (WSL)

1. **Azure CLI**
```bash
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
az --version
```

2. **kubectl** (Kubernetes CLI)
```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
kubectl version --client
```

3. **Helm** (Package manager Kubernetes)
```bash
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
helm version
```

### Azure Subscription
- ✅ Abonnement actif : "Azure subscription 1"
- ✅ Crédit disponible : 167,45€
- ⚠️ Budget Jalon 9 : ~50-60€ (phase 1)

---

## 🎯 Definition of Done (DoD)

### Phase 1 : Setup AKS (Jalon 9.1)
- [ ] Cluster AKS créé (2 nodes Standard_B2s)
- [ ] Azure Container Registry (ACR) créé
- [ ] kubectl configuré et connecté au cluster
- [ ] Namespace `secure-platform` créé
- [ ] Health check cluster : `kubectl get nodes` → 2 nodes Ready

### Phase 2 : Containerisation (Jalon 9.2)
- [ ] Image Docker FastAPI buildée
- [ ] Image pushée vers ACR
- [ ] ACR connecté à AKS (pull images)
- [ ] Vérification : `az acr repository list`

### Phase 3 : Déploiement Kubernetes (Jalon 9.3)
- [ ] Deployment FastAPI créé (2 replicas)
- [ ] Service LoadBalancer exposé (port 80)
- [ ] PostgreSQL déployé (StatefulSet)
- [ ] ConfigMap pour variables env
- [ ] Secret pour credentials DB
- [ ] Health check : `curl http://<EXTERNAL-IP>/health`

### Phase 4 : Validation Production (Jalon 9.4)
- [ ] API accessible via IP publique
- [ ] Tests pytest passent depuis pod
- [ ] Logs accessibles : `kubectl logs -f <pod>`
- [ ] Rollout update testé (zero-downtime)
- [ ] Documentation : commandes essentielles

**Critères de succès global** :
```bash
# Test final
kubectl get pods  # → 2 fastapi pods Running
kubectl get svc   # → LoadBalancer avec EXTERNAL-IP
curl http://<EXTERNAL-IP>/health  # → {"status":"ok"}
```

---

## 📐 Plan Détaillé

### Étape 1 : Setup Azure & AKS (~2 heures)

**1.1 Connexion Azure**
```bash
# Connexion
az login

# Vérifier subscription
az account list --output table
az account set --subscription "Azure subscription 1"

# Vérifier crédit
az consumption usage list --output table
```

**1.2 Créer Resource Group**
```bash
# Région Europe West (Pays-Bas, proche Paris)
az group create \
  --name devops-kubernetes-rg \
  --location westeurope
```

**1.3 Créer Azure Container Registry (ACR)**
```bash
az acr create \
  --resource-group devops-kubernetes-rg \
  --name secureplatformacr \
  --sku Basic \
  --location westeurope

# Activer admin (pour pull images)
az acr update -n secureplatformacr --admin-enabled true

# Récupérer credentials
az acr credential show --name secureplatformacr
```

**1.4 Créer Cluster AKS**
```bash
# Créer cluster (2 nodes, Basic tier)
az aks create \
  --resource-group devops-kubernetes-rg \
  --name secure-platform-aks \
  --node-count 2 \
  --node-vm-size Standard_B2s \
  --enable-managed-identity \
  --attach-acr secureplatformacr \
  --generate-ssh-keys \
  --location westeurope

# ⏱️ Temps : 5-10 minutes
```

**1.5 Configurer kubectl**
```bash
# Télécharger credentials cluster
az aks get-credentials \
  --resource-group devops-kubernetes-rg \
  --name secure-platform-aks

# Vérifier connexion
kubectl get nodes
# Output attendu:
# NAME                                STATUS   ROLES   AGE   VERSION
# aks-nodepool1-xxxxx-vmss000000     Ready    agent   2m    v1.28.x
# aks-nodepool1-xxxxx-vmss000001     Ready    agent   2m    v1.28.x
```

---

### Étape 2 : Build & Push Image Docker (~30 min)

**2.1 Login ACR**
```bash
# Récupérer login server
ACR_LOGIN_SERVER=$(az acr show \
  --name secureplatformacr \
  --query loginServer \
  --output tsv)

echo $ACR_LOGIN_SERVER
# Output: secureplatformacr.azurecr.io

# Login Docker
az acr login --name secureplatformacr
```

**2.2 Build & Tag Image**
```bash
cd ~/lab-devops/secure-release-platform

# Build image
docker build -t fastapi-app:v1.0 .

# Tag pour ACR
docker tag fastapi-app:v1.0 \
  $ACR_LOGIN_SERVER/fastapi-app:v1.0
```

**2.3 Push vers ACR**
```bash
docker push $ACR_LOGIN_SERVER/fastapi-app:v1.0

# Vérifier
az acr repository list --name secureplatformacr --output table
# Output: fastapi-app
```

---

### Étape 3 : Déploiement Kubernetes (~2 heures)

**3.1 Créer Namespace**
```bash
kubectl create namespace secure-platform
kubectl config set-context --current --namespace=secure-platform
```

**3.2 Créer Fichiers Kubernetes**

Créer `kubernetes/` directory avec :
- `deployment-fastapi.yaml` (Deployment 2 replicas)
- `service-fastapi.yaml` (LoadBalancer)
- `deployment-postgres.yaml` (StatefulSet)
- `service-postgres.yaml` (ClusterIP)
- `configmap.yaml` (Variables env)
- `secret.yaml` (DB credentials)

**3.3 Déployer PostgreSQL**
```bash
kubectl apply -f kubernetes/deployment-postgres.yaml
kubectl apply -f kubernetes/service-postgres.yaml

# Vérifier
kubectl get pods -l app=postgres
kubectl get pvc  # Persistent Volume Claim
```

**3.4 Déployer FastAPI**
```bash
kubectl apply -f kubernetes/configmap.yaml
kubectl apply -f kubernetes/secret.yaml
kubectl apply -f kubernetes/deployment-fastapi.yaml
kubectl apply -f kubernetes/service-fastapi.yaml

# Attendre External IP (2-3 min)
kubectl get svc fastapi-service --watch
```

**3.5 Tester API**
```bash
# Récupérer External IP
EXTERNAL_IP=$(kubectl get svc fastapi-service \
  -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

echo "API URL: http://$EXTERNAL_IP"

# Health check
curl http://$EXTERNAL_IP/health
# Output: {"status":"ok"}

# Version
curl http://$EXTERNAL_IP/version
```

---

### Étape 4 : Validation & Documentation (~1 heure)

**4.1 Tests de Rollout**
```bash
# Modifier image (simulation)
kubectl set image deployment/fastapi-deployment \
  fastapi=secureplatformacr.azurecr.io/fastapi-app:v1.1

# Observer rollout
kubectl rollout status deployment/fastapi-deployment

# Rollback si nécessaire
kubectl rollout undo deployment/fastapi-deployment
```

**4.2 Vérifications**
```bash
# Pods
kubectl get pods -o wide

# Logs
kubectl logs -f deployment/fastapi-deployment

# Describe (debug)
kubectl describe pod <pod-name>

# Shell dans pod
kubectl exec -it <pod-name> -- /bin/bash
```

**4.3 Screenshots**
- [ ] Dashboard Kubernetes (si activé)
- [ ] Output `kubectl get all`
- [ ] API accessible via IP publique
- [ ] Logs pods

---

## 💰 Budget Tracking

| Ressource | Coût estimé/jour | Coût/mois | Notes |
|-----------|------------------|-----------|-------|
| AKS (2 nodes B2s) | ~1.30€ | ~40€ | Core compute |
| Load Balancer | ~0.50€ | ~15€ | Public IP + routing |
| ACR Basic | ~0.17€ | ~5€ | Registry images |
| Stockage 50GB | ~0.17€ | ~5€ | Persistent volumes |
| **TOTAL Phase 1** | **~2.14€** | **~65€** | |

**Durée prévue Phase 1** : 2 semaines = ~30€

**Marge restante** : 167,45€ - 30€ = ~137€ (pour Jalons 10, 11, 12)

---

## 🔧 Commandes Essentielles

### Debug
```bash
# Vérifier tous les objets
kubectl get all -n secure-platform

# Logs en temps réel
kubectl logs -f <pod-name>

# Events cluster
kubectl get events --sort-by='.lastTimestamp'

# Ressources consommées
kubectl top nodes
kubectl top pods
```

### Nettoyage (si besoin)
```bash
# Supprimer deployment
kubectl delete deployment fastapi-deployment

# Supprimer namespace (tout dedans)
kubectl delete namespace secure-platform

# Supprimer cluster AKS (économiser budget)
az aks delete \
  --resource-group devops-kubernetes-rg \
  --name secure-platform-aks \
  --yes --no-wait
```

---

## 📚 Ressources

**Documentation** :
- [Azure AKS Docs](https://learn.microsoft.com/en-us/azure/aks/)
- [Kubernetes Docs](https://kubernetes.io/docs/home/)
- [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)

**Commandes Terraform (optionnel - Jalon 10)** :
```hcl
# Si on veut IaC pour AKS plus tard
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "secure-platform-aks"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "secureplatform"
  # ...
}
```

---

## 🎯 Critères de Réussite

### Technique
- [ ] Cluster AKS opérationnel (2 nodes)
- [ ] API accessible via LoadBalancer
- [ ] PostgreSQL persistent (PVC)
- [ ] Rollout update zero-downtime
- [ ] Logs accessibles

### Portfolio
- [ ] Architecture diagram AKS
- [ ] Screenshots déploiement
- [ ] Commandes documentées
- [ ] Comparaison AWS vs Azure
- [ ] Coût réel tracké

### Compétences
- [ ] Maîtrise kubectl
- [ ] Compréhension pods/deployments/services
- [ ] Troubleshooting Kubernetes
- [ ] Multi-cloud (AWS + Azure)

---

## 🚀 Prochaines Étapes (Jalons 10-12)

### Jalon 10 : GitOps avec ArgoCD
- ArgoCD installé sur AKS
- Déploiements automatiques depuis Git
- UI ArgoCD accessible

### Jalon 11 : Production Features
- HorizontalPodAutoscaler (auto-scaling)
- Ingress NGINX (routing avancé)
- Liveness/Readiness probes
- Rolling updates configurés

### Jalon 12 : Observability Kubernetes
- Prometheus Operator
- Grafana dashboards (pods, nodes)
- Alerting intégré

---

**Date de création** : 2026-02-25  
**Auteur** : administrator  
**Statut** : 📝 PLANIFICATION COMPLÈTE
