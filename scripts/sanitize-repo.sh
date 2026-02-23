#!/bin/bash
# Script de nettoyage des informations sensibles avant publication GitHub

echo "=== Nettoyage des informations sensibles ==="

# IPs publiques EC2
sed -i 's/YOUR_ACTUAL_EC2_IP_1/YOUR_EC2_PUBLIC_IP_1/g' docs/LAB_REFERENCE.md
sed -i 's/YOUR_ACTUAL_EC2_IP_1/YOUR_EC2_PUBLIC_IP_1/g' docs/LAB_STATE.md
sed -i 's/YOUR_ACTUAL_EC2_IP_1/YOUR_EC2_PUBLIC_IP_1/g' observability/OBSERVABILITY.md
sed -i 's/YOUR_ACTUAL_EC2_IP_1/YOUR_EC2_PUBLIC_IP_1/g' Jenkinsfile
sed -i 's/YOUR_ACTUAL_EC2_IP_1/YOUR_EC2_PUBLIC_IP_1/g' ansible/inventories/staging/hosts.yml

sed -i 's/YOUR_ACTUAL_EC2_IP_2/YOUR_EC2_PUBLIC_IP_2/g' docs/LAB_REFERENCE.md
sed -i 's/YOUR_ACTUAL_EC2_IP_2/YOUR_EC2_PUBLIC_IP_2/g' docs/LAB_STATE.md
sed -i 's/YOUR_ACTUAL_EC2_IP_2/YOUR_EC2_PUBLIC_IP_2/g' observability/OBSERVABILITY.md
sed -i 's/YOUR_ACTUAL_EC2_IP_2/YOUR_EC2_PUBLIC_IP_2/g' Jenkinsfile

# IPs privées EC2
sed -i 's/YOUR_ACTUAL_PRIVATE_IP_1/172.31.X.X/g' docs/LAB_REFERENCE.md
sed -i 's/YOUR_ACTUAL_PRIVATE_IP_1/172.31.X.X/g' docs/LAB_STATE.md

sed -i 's/YOUR_ACTUAL_PRIVATE_IP_2/172.31.Y.Y/g' docs/LAB_REFERENCE.md
sed -i 's/YOUR_ACTUAL_PRIVATE_IP_2/172.31.Y.Y/g' docs/LAB_STATE.md

# Instance IDs
sed -i 's/YOUR_ACTUAL_INSTANCE_ID_1/i-XXXXXXXXXXXXX1/g' docs/LAB_REFERENCE.md
sed -i 's/YOUR_ACTUAL_INSTANCE_ID_1/i-XXXXXXXXXXXXX1/g' docs/LAB_STATE.md
sed -i 's/YOUR_ACTUAL_INSTANCE_ID_1/i-XXXXXXXXXXXXX1/g' ansible/inventories/staging/hosts.yml

sed -i 's/YOUR_ACTUAL_INSTANCE_ID_2/i-XXXXXXXXXXXXX2/g' docs/LAB_REFERENCE.md
sed -i 's/YOUR_ACTUAL_INSTANCE_ID_2/i-XXXXXXXXXXXXX2/g' docs/LAB_STATE.md

# Security Group IDs
sed -i 's/YOUR_ACTUAL_SG_ID_1/sg-XXXXXXXXXXXXXXXXX1/g' docs/LAB_REFERENCE.md
sed -i 's/YOUR_ACTUAL_SG_ID_1/sg-XXXXXXXXXXXXXXXXX1/g' docs/LAB_STATE.md
sed -i 's/YOUR_ACTUAL_SG_ID_1/sg-XXXXXXXXXXXXXXXXX1/g' scripts/update-aws-sg.sh

sed -i 's/YOUR_ACTUAL_SG_ID_2/sg-XXXXXXXXXXXXXXXXX2/g' docs/LAB_REFERENCE.md
sed -i 's/YOUR_ACTUAL_SG_ID_2/sg-XXXXXXXXXXXXXXXXX2/g' docs/LAB_STATE.md

# Credentials Grafana
sed -i 's/YOUR_ACTUAL_GRAFANA_PASSWORD/YOUR_GRAFANA_PASSWORD/g' docs/LAB_REFERENCE.md
sed -i 's/YOUR_ACTUAL_GRAFANA_PASSWORD/YOUR_GRAFANA_PASSWORD/g' docs/LAB_STATE.md
sed -i 's/YOUR_ACTUAL_GRAFANA_PASSWORD/YOUR_GRAFANA_PASSWORD/g' observability/OBSERVABILITY.md

# Chemins absolus
sed -i 's|/home/YOUR_ACTUAL_USERNAME|/home/YOUR_USERNAME|g' docs/LAB_REFERENCE.md
sed -i 's|/home/YOUR_ACTUAL_USERNAME|/home/YOUR_USERNAME|g' docs/LAB_STATE.md

echo "✅ Nettoyage terminé"
echo ""
echo "IMPORTANT: Replace YOUR_ACTUAL_* values with your real values before running"
echo ""
echo "Fichiers modifiés:"
echo "- docs/LAB_REFERENCE.md"
echo "- docs/LAB_STATE.md"
echo "- observability/OBSERVABILITY.md"
echo "- Jenkinsfile"
echo "- ansible/inventories/staging/hosts.yml"
echo "- scripts/update-aws-sg.sh"
