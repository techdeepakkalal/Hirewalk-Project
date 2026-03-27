#!/bin/bash
# Production ready frontend startup script
exec > /var/log/frontend-setup.log 2>&1

echo "=== Frontend setup start: $(date) ==="

# ── System update ──────────────────────────────────────────
yum update -y
yum install -y git nginx

echo "=== Packages installed ==="

# ── Create web directory ───────────────────────────────────
mkdir -p /var/www/hirewalk
cd /var/www/hirewalk

# ── Clone code from GitHub ─────────────────────────────────
git clone https://github.com/techdeepakkalal/hackathon-projecct.git .
echo "=== Code cloned ==="

# ── Create Nginx config ────────────────────────────────────
# /api/* → Proxy to Backend ALB (Frontend EC2 → Backend ALB → Backend EC2)
cat > /etc/nginx/conf.d/hirewalk.conf << NGINXEOF
server {
    listen 80;
    server_name _;

    root /var/www/hirewalk/frontend;
    index hirewalk-landing.html;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;

    # Forward /api/* to Backend ALB
    location /api/ {
        proxy_pass http://${backend_alb_dns}/api/;
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_read_timeout 60s;
        proxy_connect_timeout 10s;
    }

    # Static HTML pages
    location / {
        try_files \$uri \$uri/ /hirewalk-landing.html;
    }

    # ALB health check
    location /health {
        return 200 'ok';
        add_header Content-Type text/plain;
    }
}
NGINXEOF

# ── Remove default nginx server block ─────────────────────
sed -i '/^    server {/,/^    }/d' /etc/nginx/nginx.conf

# ── Test Nginx config ──────────────────────────────────────
nginx -t && echo "Nginx config OK"

# ── Enable and start Nginx ─────────────────────────────────
systemctl enable nginx
systemctl start nginx

echo "=== Frontend setup complete: $(date) ==="
systemctl status nginx --no-pager
