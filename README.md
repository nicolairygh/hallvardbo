# Hallvardbo Speiderhytte — hallvardbo.no

Static website for Hallvardbo speiderhytte ved Langen, Siggerud. Driftet av 1. Haugerud Speidergruppe.

## Structure

```
index.html          — Hjem
historien.html      — Historien
leie.html           — Priser og vilkår
praktisk-info.html  — Praktisk informasjon
galleri.html        — Bildegalleri
kontakt.html        — Kontaktinformasjon
css/style.css       — Styles
js/main.js          — Mobile menu, lightbox, scroll animations
images/             — All site images
```

## Deploy to EC2

```bash
./deploy.sh ubuntu@your-ec2-host
```

This syncs files via rsync, installs the nginx config, and reloads nginx.

### First-time EC2 setup

```bash
sudo apt update && sudo apt install -y nginx
sudo mkdir -p /var/www/hallvardbo
```

### HTTPS with Let's Encrypt

```bash
sudo apt install -y certbot python3-certbot-nginx
sudo certbot --nginx -d hallvardbo.no -d www.hallvardbo.no
```

## Image optimization

```bash
brew install imagemagick
./optimize-images.sh
```

## Editing content

All content is in plain HTML files. To update text, pricing, or contacts, edit the relevant `.html` file directly.
