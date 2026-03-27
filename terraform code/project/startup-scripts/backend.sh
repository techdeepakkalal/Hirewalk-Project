#!/bin/bash
# Production ready backend startup script
# Note: set -e is intentionally omitted — script continues even if pip has conflicts
exec > /var/log/backend-setup.log 2>&1

echo "=== Backend setup start: $(date) ==="

# ── System update ──────────────────────────────────────────
yum update -y
yum install -y python3 python3-pip git mysql

echo "=== Packages installed ==="

# ── Create app directory ───────────────────────────────────
mkdir -p /home/ec2-user/app
cd /home/ec2-user/app

# ── Clone code from GitHub ─────────────────────────────────
git clone https://github.com/techdeepakkalal/hackathon-projecct.git .
echo "=== Code cloned ==="

# ── Install Python packages ────────────────────────────────
# --ignore-installed: avoids conflicts with system rpm packages
pip3 install \
  flask==2.2.5 \
  flask-cors==3.0.10 \
  pymysql==1.1.0 \
  python-dotenv==0.21.1 \
  PyJWT==2.6.0 \
  bcrypt==4.0.1 \
  gunicorn==20.1.0 \
  Werkzeug==2.2.3 \
  --ignore-installed 2>&1 || true

echo "=== Python packages installed ==="

# ── Create .env file ───────────────────────────────────────
cat > /home/ec2-user/app/backend/.env << ENV_EOF
DB_HOST=${db_host}
DB_PORT=3306
DB_NAME=${db_name}
DB_USER=${db_user}
DB_PASSWORD=${db_password}
JWT_SECRET=${jwt_secret}
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=${smtp_user}
SMTP_PASSWORD=${smtp_pass}
GROQ_API_KEY=${groq_key}
GROQ_MODEL=llama3-8b-8192
DEBUG=False
PORT=5000
FRONTEND_URL=*
ENV_EOF

echo "=== .env file created ==="

# ── Initialize database schema on RDS ──────────────────────
# First verify connection to RDS, then run schema
echo "=== Initializing database schema ==="
mysql -h ${db_host} -P 3306 -u ${db_user} -p${db_password} < /home/ec2-user/app/database/schema.sql 2>&1 || echo "Schema already exists or error — continuing"

echo "=== Database initialized ==="

# ── Set folder ownership to ec2-user ──────────────────────
chown -R ec2-user:ec2-user /home/ec2-user/app

# ── Create systemd service ─────────────────────────────────
cat > /etc/systemd/system/hirewalk-backend.service << 'SVCEOF'
[Unit]
Description=HireWalk Backend API (Flask)
After=network.target
Wants=network.target

[Service]
Type=simple
User=ec2-user
WorkingDirectory=/home/ec2-user/app/backend
EnvironmentFile=/home/ec2-user/app/backend/.env
ExecStart=/usr/bin/python3 app.py
Restart=always
RestartSec=5
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
SVCEOF

# ── Enable and start service ───────────────────────────────
systemctl daemon-reload
systemctl enable hirewalk-backend
systemctl start hirewalk-backend

echo "=== Backend setup complete: $(date) ==="
systemctl status hirewalk-backend --no-pager
