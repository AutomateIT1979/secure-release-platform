# Guide de Compréhension — Projet Secure Release Platform

**Date** : 2026-02-08  
**Objectif** : Comprendre ce qu'on a construit et pourquoi, sans se sentir perdu.

---

## 🎯 Vue d'ensemble : Qu'est-ce qu'on construit ?

Tu construis une **plateforme DevSecOps complète** pour démontrer tes compétences en :
- **Dev** : Coder une API (FastAPI)
- **Sec** : Intégrer des scans de sécurité (SAST, secrets, vulnérabilités)
- **Ops** : Automatiser le déploiement (CI/CD, Ansible, rollback)

**Analogie simple** : C'est comme construire une usine automatisée qui :
1. Prend ton code (matière première)
2. Le teste et le scanne (contrôle qualité)
3. Le package (emballage)
4. Le déploie automatiquement sur un serveur (livraison)
5. Surveille qu'il marche bien (monitoring)

**Pourquoi c'est important ?** : C'est ce que font les vraies entreprises tech (Google, Amazon, Netflix) pour déployer du code en production de manière fiable et sécurisée.

---

## 📚 Les 3 piliers du projet

### 1) Application (le "quoi")
- **API FastAPI** : Un serveur web simple avec un endpoint `/health`
- **Tests** : pytest pour valider que ça marche
- **Docker** : Empaqueter l'API dans un conteneur (portabilité)

### 2) Infrastructure (le "où")
- **WSL (local)** : Ton environnement de développement
- **EC2 (cloud)** : Un serveur Amazon pour héberger l'API en "production"
- **Jenkins** : Outil pour automatiser les tâches (tests, build, déploiement)

### 3) Pipeline (le "comment")
- **CI/CD** : Automatisation complète (du push Git au déploiement)
- **Scans sécurité** : Vérifier qu'il n'y a pas de failles
- **Ansible** : Automatiser la configuration des serveurs
- **Observabilité** : Surveiller que tout marche (logs, métriques, alertes)

---

## 🔍 Qu'est-ce qu'on a fait jusqu'ici ? (Session 2026-02-08)

### Étape 0 : Audit initial (diagnostic complet)
**Problème** : On ne savait pas l'état réel du lab.

**Solution** :
- Vérifié les outils installés (WSL : Docker, Ansible, Terraform, Jenkins)
- Audité l'instance EC2 (Nginx installé, Docker manquant)
- Identifié les blocages (pytest échouait, code non versionné)
- Créé `docs/LAB_STATE.md` pour documenter l'état réel

**Pourquoi c'était important ?** : Impossible d'avancer sans savoir où on en est. C'est comme réparer une voiture : d'abord diagnostiquer, ensuite réparer.

---

### Étape 1 : Rétablir la connexion SSH à EC2
**Problème** : `ssh ubuntu@35.180.54.218` échouait (`Connection timed out`).

**Cause** : L'IP publique a changé (146.70.148.30 → 146.70.148.78), le Security Group bloquait la nouvelle IP.

**Solution** :
```bash
# Supprimer ancienne règle SSH
aws ec2 revoke-security-group-ingress --group-id sg-0db21b6219faa2fca --protocol tcp --port 22 --cidr 146.70.148.30/32

# Ajouter nouvelle règle SSH
aws ec2 authorize-security-group-ingress --group-id sg-0db21b6219faa2fca --protocol tcp --port 22 --cidr 146.70.148.78/32
```

**Concept clé — Security Group** : C'est un pare-feu virtuel AWS. Il décide qui peut accéder à ton serveur EC2 et sur quels ports.

**Analogie** : C'est comme une liste de portiers à l'entrée d'un club : "Seule l'IP 146.70.148.78 peut entrer par la porte SSH (port 22)".

---

### Étape 2 : Fixer le problème pytest
**Problème** : `pytest -q` échouait avec `ModuleNotFoundError: No module named 'app'`.

**Cause** : pytest ne trouvait pas le module `app/` car il n'était pas dans `sys.path`.

**Solution** : Créer `pytest.ini` avec `pythonpath = .` pour dire à pytest de chercher depuis la racine du projet.

**Fichier créé** :
```ini
[pytest]
pythonpath = .
testpaths = tests
python_files = test_*.py
addopts = -v --tb=short
```

**Résultat** : `1 passed in 0.53s` ✅

**Pourquoi c'était bloquant ?** : Impossible de valider que le code marche sans tests. Les tests sont la **base de confiance** pour déployer en production.

---

### Étape 3 : Versionner le code dans Git
**Problème 1** : Le code applicatif (`app/`, `tests/`, `Dockerfile`, etc.) n'était pas versionné dans Git.

**Problème 2** : `.gitignore` bloquait `.env.example` (règle trop large `.env.*`).

**Solution** :
1. Corriger `.gitignore` : supprimer `.env.*`, garder uniquement `.env`
2. Versionner tout le code : `git add app/ tests/ Dockerfile docker-compose.yml requirements.txt pytest.ini .env.example`
3. Commit : `git commit -m "feat: add FastAPI healthcheck, tests, Docker packaging and pytest config"`

**Concept clé — Git** : Système de contrôle de version. Chaque modification est enregistrée (commit) avec un message expliquant ce qui a changé.

**Pourquoi c'était important ?** : 
- Historique complet des modifications
- Possibilité de revenir en arrière si bug
- Collaboration en équipe
- Traçabilité (qui a fait quoi, quand, pourquoi)

---

### Étape 4 : Tester le conteneur Docker
**Problème** : On ne savait pas si l'API marchait vraiment dans un conteneur Docker.

**Solution** :
```bash
docker compose up --build -d
curl http://localhost:8000/health
```

**Résultat** : `{"status":"ok"}` ✅

**Concept clé — Docker** : Un conteneur est comme une "boîte" qui contient ton application + toutes ses dépendances (Python, librairies, etc.). Cette boîte peut tourner partout (WSL, EC2, n'importe quel serveur).

**Analogie** : C'est comme un container de transport maritime : peu importe où tu l'envoies (cargo, train, camion), le contenu reste identique et fonctionne de la même manière.

**Pourquoi c'était critique ?** : Docker garantit que "ça marche sur ma machine" = "ça marchera en production". Plus de problèmes de "ça marche chez moi mais pas chez toi".

---

## 🧠 Concepts DevSecOps expliqués simplement

### CI/CD (Intégration Continue / Déploiement Continu)
**Définition** : Automatiser toute la chaîne du code jusqu'à la production.

**Sans CI/CD** (manuel) :
1. Tu codes localement
2. Tu testes à la main
3. Tu copies le code sur le serveur (scp, sftp...)
4. Tu redémarres le service à la main
5. Si ça casse, tu débugues en panique
→ **Lent, risqué, fatiguant**

**Avec CI/CD** (automatique) :
1. Tu push ton code Git
2. Jenkins détecte le push, lance les tests automatiquement
3. Si tests OK : build l'image Docker
4. Scans de sécurité automatiques
5. Déploiement automatique sur staging puis prod
6. Si problème : rollback automatique
→ **Rapide, fiable, sérénité**

---

### SAST / SCA / SBOM (Scans de sécurité)
**Pourquoi ?** : Ton code peut contenir des failles de sécurité sans que tu le saches.

**SAST (Static Application Security Testing)** :
- Analyse ton code source pour détecter des failles (injections SQL, XSS, etc.)
- Outil prévu : **semgrep**
- Exemple : "Tu utilises `eval()` en Python, c'est dangereux !"

**SCA (Software Composition Analysis)** :
- Analyse tes dépendances (librairies externes) pour détecter des vulnérabilités connues
- Outil prévu : **trivy**
- Exemple : "Ta librairie `requests` version 2.25.0 a une faille critique, mets à jour !"

**SBOM (Software Bill of Materials)** :
- Liste complète de tous les composants de ton application
- Outil prévu : **syft**
- Exemple : "Ton appli utilise : Python 3.11, FastAPI 0.115.6, uvicorn 0.34.0..."

**Secret scanning** :
- Détecte si tu as commité des secrets (clés API, mots de passe) dans Git
- Outil prévu : **gitleaks**
- Exemple : "Tu as commité une clé AWS dans le fichier `.env` !"

**Concept clé — Policy gate** : Si un scan trouve une vulnérabilité CRITIQUE, le pipeline s'arrête automatiquement. Le code ne peut pas aller en production.

**Analogie** : C'est comme un contrôle de sécurité à l'aéroport : si tu as un objet interdit, tu ne passes pas.

---

### Ansible (Automatisation de configuration)
**Définition** : Outil pour automatiser la configuration des serveurs.

**Sans Ansible** (manuel) :
1. SSH sur le serveur
2. `sudo apt install docker`
3. Copier les fichiers
4. Configurer Nginx
5. Redémarrer les services
→ **Répétitif, erreurs possibles, pas reproductible**

**Avec Ansible** (automatique) :
1. Tu écris un "playbook" (recette) une fois
2. Ansible l'exécute sur tous tes serveurs
3. Reproductible à l'infini
→ **Fiable, rapide, documenté**

**Exemple de playbook** :
```yaml
- name: Installer Docker sur EC2
  hosts: staging
  tasks:
    - name: Installer Docker
      apt:
        name: docker.io
        state: present
    - name: Démarrer Docker
      service:
        name: docker
        state: started
```

**Analogie** : C'est comme une recette de cuisine. Une fois écrite, n'importe qui peut la suivre et obtenir le même résultat.

---

### Observabilité (Logs, Métriques, Alertes)
**Définition** : Comprendre ce qui se passe dans ton application en production.

**3 piliers** :

**1) Logs (journaux)** :
- Enregistrement de tout ce qui se passe
- Format recommandé : JSON structuré
- Exemple : `{"timestamp":"2026-02-08T13:47:00Z", "level":"INFO", "message":"Request GET /health", "response_time_ms":12}`

**2) Métriques (mesures)** :
- Valeurs numériques pour suivre la santé de l'appli
- Outils prévus : Prometheus (collecte) + Grafana (visualisation)
- Exemples :
  - Nombre de requêtes par seconde
  - Taux d'erreur 5xx (%)
  - Latence p95 (temps de réponse au 95e percentile)

**3) Alertes (notifications)** :
- Automatiser la détection de problèmes
- Outil prévu : Alertmanager
- Exemples :
  - "API down depuis 5 minutes" → Slack/Email
  - "Taux d'erreur 5xx > 5%" → PagerDuty

**Analogie** : C'est comme le tableau de bord d'une voiture :
- Logs = boîte noire (enregistre tout)
- Métriques = compteur de vitesse, jauge d'essence
- Alertes = voyant rouge qui s'allume si problème

---

## 🗺️ Où en est-on ? (Roadmap)

### ✅ Jalon 1 — MVP local (COMPLÉTÉ)
- ✅ API FastAPI avec `/health`
- ✅ Tests pytest passent
- ✅ Docker Compose fonctionne
- ✅ Healthcheck OK

### ⏭️ Jalon 2 — Préparer EC2
**Objectif** : Installer Docker sur EC2 pour pouvoir y déployer l'API.

**Actions** :
1. Créer un playbook Ansible pour installer Docker sur EC2
2. Exécuter le playbook : `ansible-playbook -i inventories/staging playbooks/install_docker.yml`
3. Vérifier : `ssh ubuntu@35.180.54.218 "docker --version"`

**Pourquoi ?** : Actuellement, EC2 n'a pas Docker → impossible de déployer des conteneurs.

---

### ⏭️ Jalon 3 — CI/CD (Jenkins)
**Objectif** : Automatiser tests + build + scans à chaque push Git.

**Actions** :
1. Créer un `Jenkinsfile` (pipeline as code)
2. Configurer Jenkins pour surveiller le repo Git
3. Pipeline basique :
   - Stage 1 : Lint/format (vérifier style du code)
   - Stage 2 : Tests (`pytest`)
   - Stage 3 : Build image Docker
   - Stage 4 : Archiver les artefacts (logs, rapports)

**Pourquoi ?** : Automatiser pour gagner du temps et éviter les erreurs humaines.

---

### ⏭️ Jalon 4 — DevSecOps (Scans sécurité)
**Objectif** : Intégrer les scans de sécurité dans le pipeline Jenkins.

**Actions** :
1. Installer les outils : gitleaks, semgrep, trivy, syft
2. Ajouter des stages dans le Jenkinsfile :
   - Stage : Secret scanning (gitleaks)
   - Stage : SAST (semgrep)
   - Stage : Image scan (trivy)
   - Stage : SBOM generation (syft)
3. Policy gate : bloquer si CRITICAL

**Pourquoi ?** : Éviter de déployer du code avec des failles de sécurité.

---

### ⏭️ Jalon 5 — Déploiement automatisé (Ansible + rollback)
**Objectif** : Déployer automatiquement sur staging puis prod, avec rollback si échec.

**Actions** :
1. Créer playbook Ansible pour déploiement
2. Intégrer dans Jenkins :
   - Stage : Déploiement staging
   - Stage : Smoke test (`curl /health`)
   - Stage : Promotion prod (manuel)
3. Rollback automatique si smoke test échoue

**Pourquoi ?** : Déployer en production sans stress, avec filet de sécurité.

---

### ⏭️ Jalon 6 — Observabilité
**Objectif** : Surveiller l'API en production.

**Actions** :
1. Logs structurés JSON dans l'API
2. Exposer métriques Prometheus (`/metrics`)
3. Déployer Prometheus + Grafana
4. Créer un dashboard Grafana
5. Configurer Alertmanager

**Pourquoi ?** : Détecter les problèmes avant que les utilisateurs se plaignent.

---

## 🔧 Commandes essentielles à retenir

### Git
```bash
# Voir l'état du repo
git status

# Versionner des fichiers
git add <fichiers>
git commit -m "message"

# Voir l'historique
git log --oneline --decorate -n 10
```

### pytest
```bash
# Lancer les tests
pytest -q

# Avec verbose
pytest -v
```

### Docker
```bash
# Build et lancer
docker compose up --build

# En arrière-plan
docker compose up --build -d

# Voir les logs
docker compose logs

# Arrêter
docker compose down

# Voir les conteneurs actifs
docker compose ps
```

### SSH (EC2)
```bash
# Se connecter
ssh -i ~/.ssh/lab-devops-key.pem ubuntu@35.180.54.218

# Exécuter une commande à distance
ssh -i ~/.ssh/lab-devops-key.pem ubuntu@35.180.54.218 "docker --version"
```

### AWS CLI
```bash
# Lister les instances EC2
aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId,State.Name,PublicIpAddress,Tags[?Key==`Name`].Value|[0]]' --output table

# Mettre à jour Security Group (autoriser son IP)
aws ec2 authorize-security-group-ingress --group-id sg-0db21b6219faa2fca --protocol tcp --port 22 --cidr $(curl -s ifconfig.me)/32
```

---

## 📖 Glossaire (termes à connaître)

| Terme | Définition simple |
|-------|-------------------|
| **CI/CD** | Automatisation complète du code jusqu'à la production |
| **Container** | Boîte contenant ton appli + dépendances, portable partout |
| **Docker Compose** | Outil pour orchestrer plusieurs conteneurs |
| **EC2** | Serveur virtuel sur Amazon AWS |
| **FastAPI** | Framework Python pour créer des API web rapidement |
| **Healthcheck** | Endpoint `/health` pour vérifier que l'API est vivante |
| **Jenkins** | Outil d'automatisation CI/CD (open source) |
| **Pipeline** | Série d'étapes automatisées (tests → build → deploy) |
| **Playbook** | Fichier YAML décrivant des tâches Ansible |
| **Policy gate** | Bloque le pipeline si conditions non respectées |
| **Pytest** | Framework de tests Python |
| **Rollback** | Retour à la version précédente si problème |
| **SAST** | Scan de sécurité du code source |
| **Security Group** | Pare-feu virtuel AWS |
| **Smoke test** | Test rapide pour vérifier que ça marche (ex: `/health`) |
| **SSH** | Protocole pour se connecter à un serveur distant |
| **Staging** | Environnement de pré-production (copie de prod pour tests) |
| **venv** | Environnement Python isolé (dépendances séparées) |
| **WSL** | Windows Subsystem for Linux (Linux dans Windows) |

---

## 🎓 Pourquoi ce projet est important pour ton CV ?

### Compétences démontrées
1. **DevOps** : Docker, CI/CD, Jenkins, Ansible, Infrastructure as Code
2. **Sécurité** : SAST, SCA, secret scanning, policy gate, SBOM
3. **Cloud** : AWS (EC2, Security Groups), gestion d'infrastructure
4. **Python** : FastAPI, pytest, bonnes pratiques
5. **Git** : Versioning, commits propres, workflow
6. **Automatisation** : Tout est automatisé, rien de manuel
7. **Observabilité** : Logs, métriques, alertes

### Ce que ça montre aux recruteurs
- ✅ Tu sais **construire une chaîne complète**, pas juste un morceau
- ✅ Tu comprends les **enjeux de sécurité** (pas juste "ça marche")
- ✅ Tu penses **production** (tests, monitoring, rollback)
- ✅ Tu documentes ton travail (README, runbooks, decisions)
- ✅ Tu sais **automatiser** (pas de copier-coller manuel)

### Phrases à utiliser en entretien
- "J'ai construit une plateforme DevSecOps end-to-end avec CI/CD, scans de sécurité automatisés, et déploiement Ansible."
- "J'ai intégré des policy gates qui bloquent automatiquement le pipeline si des vulnérabilités critiques sont détectées."
- "J'ai mis en place un système de rollback automatique basé sur les healthchecks pour garantir la disponibilité."
- "J'ai dockerisé l'application avec des builds reproductibles et multi-stage pour optimiser la taille des images."

---

## 🚀 Prochaines étapes (pour toi)

### Court terme (cette semaine)
1. ✅ Comprendre ce guide (tu es ici !)
2. ⏭️ Installer Docker sur EC2 (Jalon 2)
3. ⏭️ Créer un Jenkinsfile basique (Jalon 3)

### Moyen terme (2-3 semaines)
1. Intégrer les scans de sécurité (Jalon 4)
2. Automatiser le déploiement avec Ansible (Jalon 5)
3. Mettre en place l'observabilité (Jalon 6)

### Long terme (1 mois)
1. Publier le projet sur GitHub avec documentation complète
2. Ajouter des screenshots/preuves dans `docs/evidence/`
3. Créer un README marketing qui vend le projet
4. Préparer une présentation du projet (slides)

---

## 📝 Notes personnelles (à compléter au fur et à mesure)

### Ce que j'ai appris aujourd'hui (2026-02-08)
- Security Groups AWS fonctionnent comme des pare-feu
- pytest a besoin de `pytest.ini` pour trouver les modules
- Docker Compose permet de lancer des conteneurs facilement
- Jenkins est déjà installé sur WSL (port 8080)

### Difficultés rencontrées
- IP publique qui change → faut mettre à jour Security Group
- `.gitignore` trop restrictif → bloquait `.env.example`
- pytest ne trouvait pas le module `app/` → résolu avec `pytest.ini`

### Questions à poser plus tard
- Comment configurer Jenkins pour surveiller le repo Git ?
- Comment créer un playbook Ansible efficace ?
- Quelle est la différence entre SAST et SCA concrètement ?

---

## 🔗 Ressources utiles

### Documentation officielle
- FastAPI : https://fastapi.tiangolo.com/
- Docker : https://docs.docker.com/
- Jenkins : https://www.jenkins.io/doc/
- Ansible : https://docs.ansible.com/
- Pytest : https://docs.pytest.org/

### Tutoriels recommandés
- Docker pour débutants : https://www.youtube.com/watch?v=fqMOX6JJhGo
- CI/CD avec Jenkins : https://www.jenkins.io/doc/tutorials/
- Ansible de zéro : https://www.ansible.com/resources/get-started

### Outils de sécurité
- gitleaks : https://github.com/gitleaks/gitleaks
- semgrep : https://semgrep.dev/
- trivy : https://trivy.dev/
- syft : https://github.com/anchore/syft

---

## ✅ Checklist de compréhension

Coche les cases quand tu as compris :

### Concepts généraux
- [ ] Je comprends ce qu'est DevSecOps
- [ ] Je sais expliquer CI/CD à quelqu'un
- [ ] Je connais les 3 piliers du projet (App, Infra, Pipeline)

### Outils
- [ ] Je sais à quoi sert Docker (et pourquoi c'est important)
- [ ] Je comprends le rôle de Jenkins
- [ ] Je sais ce que fait Ansible
- [ ] Je connais la différence entre SAST et SCA

### Pratique
- [ ] Je sais lancer les tests (`pytest`)
- [ ] Je sais démarrer le conteneur (`docker compose up`)
- [ ] Je sais me connecter à EC2 en SSH
- [ ] Je sais versionner du code dans Git

### Projet
- [ ] Je sais où on en est (Jalon 1 complété)
- [ ] Je connais les prochaines étapes (Jalons 2-6)
- [ ] Je peux expliquer le projet en 2 minutes

---

## 💡 Conseil final

**Ne te sens pas perdu.** C'est normal de ne pas tout comprendre d'un coup. DevSecOps, c'est un domaine **large et complexe**.

**L'important** : Avance étape par étape. Chaque jalon complété est une victoire.

**Question avant chaque commande** : "Pourquoi je fais ça ?" Si tu ne sais pas, reviens à ce guide ou demande.

**Tu n'exécutes pas bêtement** : Tu construis quelque chose de concret, avec une logique claire.

---

**Auteur** : Claude (IA assistante DevSecOps)  
**Date de création** : 2026-02-08  
**Dernière mise à jour** : 2026-02-08
