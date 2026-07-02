#!/bin/bash
set -e
exec > /var/log/user_data.log 2>&1

# -- Variables ------------------------------------------------------------------
GITHUB_USER="pwr-cloudprogramming"
GITHUB_PAT="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"
REPO_NAME="clprog2026-a04-thu1304"
REPO_URL="https://${GITHUB_PAT}@github.com/${GITHUB_USER}/${REPO_NAME}.git"

# -- Get public IP from IMDS ----------------------------------------------------
TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
PUBLIC_IP=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/public-ipv4)

echo "Public IP: $PUBLIC_IP"

# -- System update --------------------------------------------------------------
dnf update -y

# ================================================================================
# BACKEND (Gradle)
# ================================================================================
dnf install -y java-21-amazon-corretto java-17-amazon-corretto-devel git

git clone "$REPO_URL" /opt/app

cd /opt/app/backend
chmod +x gradlew
./gradlew build -x test

JAR_FILE=$(find /opt/app/backend/build/libs -name "*.jar" | grep -v plain | head -1)
echo "JAR: $JAR_FILE"

cat > /etc/systemd/system/backend.service <<EOF
[Unit]
Description=Chat App Backend
After=network.target

[Service]
Type=simple
User=ec2-user
WorkingDirectory=/opt/app/backend
ExecStart=/usr/bin/java -Dserver.port=5000 -Dcors.allowed.origins=http://${PUBLIC_IP}:3000 -jar ${JAR_FILE}
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable backend
systemctl start backend
echo "Backend started."

# ================================================================================
# FRONTEND (SvelteKit/Vite)
# ================================================================================
dnf install -y nodejs npm

cd /opt/app/frontend

npm install

# adapter-auto can't detect EC2 — swap to adapter-node which produces a real Node server
npm install @sveltejs/adapter-node --save-dev
sed -i 's/adapter-auto/adapter-node/g' svelte.config.js

npm run build

cat > /etc/systemd/system/frontend.service <<EOF
[Unit]
Description=Chat App Frontend
After=network.target backend.service

[Service]
Type=simple
User=ec2-user
WorkingDirectory=/opt/app/frontend
Environment=PORT=3000
Environment=HOST=0.0.0.0
Environment=ORIGIN=http://${PUBLIC_IP}:3000
Environment=PUBLIC_API_BASE_URL=http://${PUBLIC_IP}:5000
ExecStart=/usr/bin/node build
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable frontend
systemctl start frontend
echo "Frontend started."
echo "Setup complete. Backend: http://${PUBLIC_IP}:5000/chat/all?username=test  Frontend: http://${PUBLIC_IP}:3000"