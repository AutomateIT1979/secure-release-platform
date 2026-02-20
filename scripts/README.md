# Scripts d'automatisation

## update-aws-sg.sh

Script de mise à jour automatique du Security Group AWS pour résoudre le problème d'IP publique dynamique.

### Usage
```bash
./scripts/update-aws-sg.sh
```

### Fonctionnement

1. Détecte l'IP publique actuelle (`curl ifconfig.me`)
2. Vérifie si elle est déjà autorisée dans le Security Group
3. Supprime les anciennes règles (cleanup)
4. Ajoute la nouvelle IP pour les ports 22, 80, 8080

### Prérequis

- AWS CLI configuré (`aws configure`)
- Permissions IAM : `ec2:DescribeSecurityGroups`, `ec2:RevokeSecurityGroupIngress`, `ec2:AuthorizeSecurityGroupIngress`

### Configuration

Modifiable dans le script :
- `SG_ID` : ID du Security Group
- `REGION` : Région AWS
- `PORTS` : Liste des ports à autoriser
