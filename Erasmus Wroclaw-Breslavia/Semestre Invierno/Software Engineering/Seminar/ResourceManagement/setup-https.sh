#!/bin/bash

DOMAIN="rm-apueblar.duckdns.org"
EMAIL="alvaropueblaruisanchez@gmail.com"

echo "=== SSL Certificate Setup for $DOMAIN ==="
echo ""

# Create directories
mkdir -p certbot/conf certbot/www

# Check if certificate already exists
if [ -f "certbot/conf/live/$DOMAIN/fullchain.pem" ]; then
    echo "⚠ Certificate already exists!"
    read -p "Do you want to delete and recreate it? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Removing existing certificate..."
        sudo rm -rf certbot/conf/live/$DOMAIN
        sudo rm -rf certbot/conf/archive/$DOMAIN
        sudo rm -rf certbot/conf/renewal/$DOMAIN.conf
    else
        echo "Keeping existing certificate. Exiting."
        exit 0
    fi
fi

# Stop any existing containers
echo "Stopping existing containers..."
docker compose down

# Start only the services needed for certificate acquisition
echo "Starting nginx and backend..."
docker compose up -d nginx backend mysql
sleep 10

# Verify nginx is serving HTTP
echo "Verifying nginx is accessible..."
if ! curl -I http://localhost 2>/dev/null | grep -q "200\|301\|302"; then
    echo "⚠ Warning: nginx might not be responding correctly"
fi

# Obtain certificate using webroot method
echo ""
echo "Requesting SSL certificate from Let's Encrypt..."
echo "This may take a minute..."
docker compose run --rm certbot certonly \
  --webroot \
  --webroot-path=/var/www/certbot \
  --email $EMAIL \
  --agree-tos \
  --no-eff-email \
  --force-renewal \
  -d $DOMAIN

if [ $? -eq 0 ]; then
    echo ""
    echo "✓ Certificate obtained successfully!"
    echo "✓ Restarting nginx to enable HTTPS..."
    docker compose restart nginx
    sleep 5
    
    echo ""
    echo "=== Setup Complete! ==="
    echo "Your site should now be available at:"
    echo "  https://$DOMAIN"
    echo ""
    echo "Testing HTTPS..."
    if curl -k -I https://localhost 2>/dev/null | grep -q "200\|301\|302"; then
        echo "✓ HTTPS is working!"
    else
        echo "⚠ HTTPS test failed - check nginx logs:"
        echo "  docker compose logs nginx"
    fi
    echo ""
    echo "Certificate will auto-renew. To update your app:"
    echo "  git pull && docker compose up -d --build"
else
    echo ""
    echo "✗ Certificate acquisition failed!"
    echo ""
    echo "Troubleshooting steps:"
    echo "1. Verify DNS: dig $DOMAIN (should point to your public IP)"
    echo "2. Check port forwarding: ports 80 and 443 to this machine"
    echo "3. Verify domain is accessible: curl http://$DOMAIN"
    echo "4. Check logs: docker compose logs nginx"
    echo "5. Check certbot logs: docker compose logs certbot"
    echo ""
    echo "Common issues:"
    echo "- DuckDNS not updated with current IP"
    echo "- Router not forwarding ports 80/443"
    echo "- Firewall blocking ports"
    exit 1
fi