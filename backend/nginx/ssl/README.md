# SSL Certificates Directory

Place your SSL certificates in this directory for HTTPS support.

## For Development (Self-Signed)

Generate self-signed certificates for testing:

```bash
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout key.pem \
  -out cert.pem \
  -subj "/CN=mwalpha.eskienterprises.com"
```

## For Production (Let's Encrypt)

Obtain free SSL certificates from Let's Encrypt:

```bash
# Install certbot
sudo apt-get update
sudo apt-get install certbot

# Generate certificates
sudo certbot certonly --standalone -d mwalpha.eskienterprises.com

# Copy certificates
sudo cp /etc/letsencrypt/live/mwalpha.eskienterprises.com/fullchain.pem cert.pem
sudo cp /etc/letsencrypt/live/mwalpha.eskienterprises.com/privkey.pem key.pem

# Set proper permissions
chmod 644 cert.pem
chmod 600 key.pem
```

## Files

- `cert.pem` - SSL certificate (public)
- `key.pem` - Private key (keep secure!)

## Important

⚠️ Never commit SSL private keys to version control!

The `.gitignore` file is configured to exclude:
- `*.pem`
- `*.key`
- `*.crt`

## Auto-Renewal

Set up automatic certificate renewal:

```bash
# Add to crontab
sudo crontab -e

# Add this line:
0 0 1 * * certbot renew --quiet && docker compose -f /path/to/docker-compose.yml restart nginx
```
