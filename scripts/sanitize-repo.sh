#!/bin/bash
# Script de nettoyage des informations sensibles avant publication GitHub

echo "=== Nettoyage des informations sensibles ==="

# IPs publiques EC2
sed -i 's/35\.180\.38\.208/YOUR_EC2_PUBLIC_IP_1/g' docs/LAB_REFERENCE.md
sed -i 's/35\.180\.38\.208/YOUR_EC2_PUBLIC_IP_1/g' docs/LAB_STATE.md
sed -i 's/35\.180\.38\.208/YOUR_EC2_PUBLIC_IP_1/g' observability/OBSERVABILITY.md
sed -i 's/35\.180\.38\.208/YOUR_EC2_PUBLIC_IP_1/g' Jenkinsfile
sed -i 's/35\.180\.38\.208/YOUR_EC2_PUBLIC_IP_1/g' ansible/inventories/staging/hosts.yml

sed -i 's/15\.188\.127\.106/YOUR_EC2_PUBLIC_IP_2/g' docs/LAB_REFERENCE.md
sed -i 's/15\.188\.127\.106/YOUR_EC2_PUBLIC_IP_2/g' docs/LAB_STATE.md
sed -i 's/15\.188\.127\.106/YOUR_EC2_PUBLIC_IP_2/g' observability/OBSERVABILITY.md
sed -i 's/15\.188\.127\.106/YOUR_EC2_PUBLIC_IP_2/g' Jenkinsfile

# IPs privées EC2
sed -i 's/172\.31\.7\.253/172.31.X.X/g' docs/LAB_REFERENCE.md
sed -i 's/172\.31\.7\.253/172.31.X.X/g' docs/LAB_STATE.md

sed -i 's/172\.31\.12\.54/172.31.Y.Y/g' docs/LAB_REFERENCE.md
sed -i 's/172\.31\.12\.54/172.31.Y.Y/g' docs/LAB_STATE.md

# Instance IDs
sed -i 's/i-01c77636889cc7f4a/i-XXXXXXXXXXXXX1/g' docs/LAB_REFERENCE.md
sed -i 's/i-01c77636889cc7f4a/i-XXXXXXXXXXXXX1/g' docs/LAB_STATE.md
sed -i 's/i-01c77636889cc7f4a/i-XXXXXXXXXXXXX1/g' ansible/inventories/staging/hosts.yml

sed -i 's/i-0895fb26e33d874d8/i-XXXXXXXXXXXXX2/g' docs/LAB_REFERENCE.md
sed -i 's/i-0895fb26e33d874d8/i-XXXXXXXXXXXXX2/g' docs/LAB_STATE.md

# Security Group IDs
sed -i 's/sg-0db21b6219faa2fca/sg-XXXXXXXXXXXXXXXXX1/g' docs/LAB_REFERENCE.md
sed -i 's/sg-0db21b6219faa2fca/sg-XXXXXXXXXXXXXXXXX1/g' docs/LAB_STATE.md
sed -i 's/sg-0db21b6219faa2fca/sg-XXXXXXXXXXXXXXXXX1/g' scripts/update-aws-sg.sh

sed -i 's/sg-05350268f9cd57c3b/sg-XXXXXXXXXXXXXXXXX2/g' docs/LAB_REFERENCE.md
sed -i 's/sg-05350268f9cd57c3b/sg-XXXXXXXXXXXXXXXXX2/g' docs/LAB_STATE.md

# Credentials Grafana
sed -i 's/SecurePass2026!/YOUR_GRAFANA_PASSWORD/g' docs/LAB_REFERENCE.md
sed -i 's/SecurePass2026!/YOUR_GRAFANA_PASSWORD/g' docs/LAB_STATE.md
sed -i 's/SecurePass2026!/YOUR_GRAFANA_PASSWORD/g' observability/OBSERVABILITY.md

# Chemins absolus
sed -i 's|/home/administrator|/home/YOUR_USERNAME|g' docs/LAB_REFERENCE.md
sed -i 's|/home/administrator|/home/YOUR_USERNAME|g' docs/LAB_STATE.md

echo "✅ Nettoyage terminé"
echo ""
echo "Fichiers modifiés:"
echo "- docs/LAB_REFERENCE.md"
echo "- docs/LAB_STATE.md"
echo "- observability/OBSERVABILITY.md"
echo "- Jenkinsfile"
echo "- ansible/inventories/staging/hosts.yml"
echo "- scripts/update-aws-sg.sh"
