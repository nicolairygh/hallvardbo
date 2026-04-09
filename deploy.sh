#!/bin/bash
# Deploy Hallvardbo to EC2
# Usage: ./deploy.sh <ec2-user@ec2-host>
#
# Prerequisites on EC2:
#   sudo apt update && sudo apt install -y nginx
#   sudo mkdir -p /var/www/hallvardbo
#
# For HTTPS (recommended), install certbot after first deploy:
#   sudo apt install -y certbot python3-certbot-nginx
#   sudo certbot --nginx -d hallvardbo.no -d www.hallvardbo.no

set -e

HOST="${1:?Usage: ./deploy.sh user@host}"
REMOTE_DIR="/var/www/hallvardbo"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "==> Optimizing images (if not already done)..."
if [ -f "$SCRIPT_DIR/optimize-images.sh" ]; then
  bash "$SCRIPT_DIR/optimize-images.sh"
fi

echo "==> Syncing files to $HOST:$REMOTE_DIR..."
rsync -avz --delete \
  --exclude='deploy.sh' \
  --exclude='optimize-images.sh' \
  --exclude='nginx.conf' \
  --exclude='.DS_Store' \
  "$SCRIPT_DIR/" "$HOST:$REMOTE_DIR/"

echo "==> Installing nginx config..."
scp "$SCRIPT_DIR/nginx.conf" "$HOST:/tmp/hallvardbo.conf"
ssh "$HOST" "sudo mv /tmp/hallvardbo.conf /etc/nginx/sites-available/hallvardbo && \
  sudo ln -sf /etc/nginx/sites-available/hallvardbo /etc/nginx/sites-enabled/hallvardbo && \
  sudo rm -f /etc/nginx/sites-enabled/default && \
  sudo nginx -t && \
  sudo systemctl reload nginx"

echo "==> Done! Site deployed to $HOST"
echo "    Don't forget to set up HTTPS with certbot if not already done."
