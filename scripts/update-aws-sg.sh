#!/bin/bash
# Script de mise à jour automatique du Security Group AWS
# Usage: ./update-aws-sg.sh

set -e

# Configuration
SG_ID="sg-0db21b6219faa2fca"
REGION="eu-west-3"
PORTS=(22 80 8080)

# Couleurs
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "=== AWS Security Group Auto-Update ==="
echo ""

# Vérifier AWS CLI
if ! command -v aws &> /dev/null; then
    echo -e "${RED}❌ AWS CLI non installé${NC}"
    exit 1
fi

# Obtenir IP actuelle
echo -n "🔍 Détection IP publique... "
CURRENT_IP=$(curl -s ifconfig.me)
if [ -z "$CURRENT_IP" ]; then
    echo -e "${RED}ÉCHEC${NC}"
    exit 1
fi
echo -e "${GREEN}${CURRENT_IP}${NC}"

# Vérifier IP dans Security Group
echo -n "🔍 Vérification Security Group... "
EXISTING_IPS=$(aws ec2 describe-security-groups \
    --group-ids "$SG_ID" \
    --region "$REGION" \
    --query 'SecurityGroups[0].IpPermissions[*].IpRanges[*].CidrIp' \
    --output text 2>/dev/null)

if echo "$EXISTING_IPS" | grep -q "${CURRENT_IP}/32"; then
    echo -e "${GREEN}OK${NC}"
    echo ""
    echo -e "${GREEN}✅ IP déjà autorisée dans le Security Group${NC}"
    exit 0
fi

echo -e "${YELLOW}DIFFÉRENTE${NC}"
echo ""
echo "📋 IPs actuellement autorisées :"
echo "$EXISTING_IPS" | tr '\t' '\n' | sed 's/^/  - /'
echo ""

# Supprimer anciennes règles (cleanup)
echo "🧹 Nettoyage des anciennes règles..."
for PORT in "${PORTS[@]}"; do
    for OLD_IP in $EXISTING_IPS; do
        echo -n "  - Port $PORT depuis $OLD_IP... "
        aws ec2 revoke-security-group-ingress \
            --group-id "$SG_ID" \
            --region "$REGION" \
            --protocol tcp \
            --port "$PORT" \
            --cidr "$OLD_IP" 2>/dev/null && echo -e "${GREEN}✓${NC}" || echo -e "${YELLOW}skip${NC}"
    done
done

# Ajouter nouvelle IP
echo ""
echo "➕ Ajout de la nouvelle IP: ${CURRENT_IP}/32"
for PORT in "${PORTS[@]}"; do
    echo -n "  - Port $PORT... "
    aws ec2 authorize-security-group-ingress \
        --group-id "$SG_ID" \
        --region "$REGION" \
        --protocol tcp \
        --port "$PORT" \
        --cidr "${CURRENT_IP}/32" 2>/dev/null && echo -e "${GREEN}✓${NC}" || echo -e "${RED}✗${NC}"
done

echo ""
echo -e "${GREEN}✅ Security Group mis à jour avec succès${NC}"
echo ""
echo "🔐 Vous pouvez maintenant vous connecter :"
echo "  ssh -i ~/.ssh/lab-devops-key.pem ubuntu@35.180.54.218"
