#!/bin/sh

DOMAIN="rm-apueblar.duckdns.org"

if [ ! -f /etc/letsencrypt/live/${DOMAIN}/fullchain.pem ]; then
  echo "No SSL certificate found - serving HTTP only"
  cat > /etc/nginx/conf.d/default.conf << 'EOF'
resolver 127.0.0.11 valid=10s;
server {
    listen 80;
    server_name rm-apueblar.duckdns.org;
    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }
    location / {
        proxy_pass http://backend:8080;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header Connection "";
    }
}
server {
    listen 80 default_server;
    server_name _;
    return 444;
}
EOF
else
  echo "SSL certificate found - enabling HTTPS"
  cat > /etc/nginx/conf.d/default.conf << 'EOF'
resolver 127.0.0.11 valid=10s;
server {
    listen 80;
    server_name rm-apueblar.duckdns.org;
    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }
    location / {
        return 301 https://$server_name$request_uri;
    }
}
server {
    listen 443 ssl;
    http2 on;
    server_name rm-apueblar.duckdns.org;
    ssl_certificate /etc/letsencrypt/live/rm-apueblar.duckdns.org/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/rm-apueblar.duckdns.org/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers off;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    location / {
        proxy_pass http://backend:8080;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto https;
        proxy_set_header Connection "";
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
server {
    listen 80 default_server;
    server_name _;
    return 444;
}
EOF
fi

exec nginx -g 'daemon off;'