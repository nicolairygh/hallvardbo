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

## Infrastructure (S3 + CloudFront)

The site is hosted on AWS using S3 for storage and CloudFront for CDN/HTTPS.

### One-time setup

**1. Request an ACM certificate (must be in us-east-1 for CloudFront):**

```bash
aws acm request-certificate \
  --region us-east-1 \
  --domain-name hallvardbo.no \
  --subject-alternative-names '*.hallvardbo.no' \
  --validation-method DNS
```

Complete DNS validation as instructed, then note the certificate ARN.

**2. Deploy the CloudFormation stack:**

```bash
aws cloudformation deploy \
  --template-file cloudformation.yaml \
  --stack-name hallvardbo-site \
  --parameter-overrides \
    DomainName=hallvardbo.no \
    AcmCertificateArn=arn:aws:acm:us-east-1:ACCOUNT:certificate/ID \
    HostedZoneId=YOUR_ZONE_ID
```

- `AcmCertificateArn` — from step 1. Omit to use the default `*.cloudfront.net` domain.
- `HostedZoneId` — your Route53 hosted zone. Omit to skip DNS records (manage DNS manually).

**3. Point your domain to CloudFront** (if not using Route53):

Create CNAME records for `hallvardbo.no` and `www.hallvardbo.no` pointing to the CloudFront domain shown in the stack outputs.

### Deploy site content

```bash
./deploy.sh              # uses default stack name 'hallvardbo-site'
./deploy.sh my-stack      # or specify a custom stack name
```

This syncs files to S3, sets cache headers, and invalidates the CloudFront cache.

## Image optimization

```bash
brew install imagemagick
./optimize-images.sh
```

## Editing content

All content is in plain HTML files. To update text, pricing, or contacts, edit the relevant `.html` file directly, then run `./deploy.sh`.
