#!/usr/bin/env bash
set -euo pipefail

# Non-destructive static deployment for 12-beijing.
# Use this when the ECS cannot reliably clone GitHub:
# 1. Download the branch zip on your Windows machine.
# 2. scp the zip to /tmp on the server.
# 3. unzip it.
# 4. run this script from the extracted repo root.
#
# It does NOT stop existing frontend/backend processes.
# It creates a new Nginx site listening on PUBLIC_PORT, default 18081.

SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
APP_DIR="${APP_DIR:-/opt/12_beijing_aliyun}"
PUBLIC_PORT="${PUBLIC_PORT:-18081}"
SITE_NAME="${SITE_NAME:-12-beijing-aliyun}"
NGINX_AVAILABLE="/etc/nginx/sites-available/${SITE_NAME}"
NGINX_ENABLED="/etc/nginx/sites-enabled/${SITE_NAME}"

log() {
  printf '\n[12-beijing-deploy] %s\n' "$*"
}

fail() {
  printf '\n[12-beijing-deploy][ERROR] %s\n' "$*" >&2
  exit 1
}

if [ "$(id -u)" != "0" ]; then
  fail "Please run as root."
fi

case "$PUBLIC_PORT" in
  80|443|5000|5173|3000|8080|18080)
    fail "PUBLIC_PORT=$PUBLIC_PORT may conflict with existing projects. Use a high unused port, e.g. PUBLIC_PORT=18081."
    ;;
esac

if ss -ltnp 2>/dev/null | awk '{print $4}' | grep -Eq "(^|:)${PUBLIC_PORT}$"; then
  ss -ltnp | grep -E "(^|:)${PUBLIC_PORT}[[:space:]]" || true
  fail "Port $PUBLIC_PORT is already in use. Pick another one, e.g. PUBLIC_PORT=18082."
fi

log "Installing nginx/rsync/unzip if missing"
apt-get update
apt-get install -y nginx rsync unzip

log "Copying static files from $SRC_DIR to $APP_DIR"
mkdir -p "$APP_DIR"
rsync -a --delete \
  --exclude '.git' \
  --exclude 'node_modules' \
  --exclude 'dist' \
  --exclude 'build' \
  --exclude 'deploy' \
  "$SRC_DIR/" "$APP_DIR/"

if [ ! -f "$APP_DIR/index.html" ]; then
  fail "$APP_DIR/index.html not found after copy."
fi
if [ ! -f "$APP_DIR/gis-platform.html" ]; then
  fail "$APP_DIR/gis-platform.html not found after copy."
fi
if [ ! -d "$APP_DIR/data" ]; then
  log "WARNING: $APP_DIR/data not found. Local GeoJSON requests may fail."
fi

log "Writing Nginx site $NGINX_AVAILABLE"
cat > "$NGINX_AVAILABLE" <<EOF
server {
    listen ${PUBLIC_PORT};
    server_name _;

    root ${APP_DIR};
    index index.html gis-platform.html;

    charset utf-8;
    client_max_body_size 20m;

    location / {
        try_files \$uri \$uri/ /index.html;
    }

    location /data/ {
        try_files \$uri =404;
        add_header Access-Control-Allow-Origin "*" always;
        add_header Cache-Control "public, max-age=86400" always;
        types {
            application/json json geojson;
        }
    }

    location ~* \\.(?:js|mjs|css|png|jpg|jpeg|gif|svg|webp|ico|json|geojson|glb|gltf)$ {
        try_files \$uri =404;
        expires 7d;
        add_header Cache-Control "public, max-age=604800" always;
        add_header Access-Control-Allow-Origin "*" always;
    }
}
EOF

ln -sf "$NGINX_AVAILABLE" "$NGINX_ENABLED"
nginx -t
systemctl enable nginx
systemctl reload nginx || systemctl restart nginx

log "Smoke testing"
curl -fsS "http://127.0.0.1:${PUBLIC_PORT}/" >/dev/null
curl -fsS "http://127.0.0.1:${PUBLIC_PORT}/gis-platform.html" >/dev/null

log "Done. Open: http://120.55.70.218:${PUBLIC_PORT}/"
log "If browser cannot open it, add inbound TCP ${PUBLIC_PORT} in Aliyun security group."
