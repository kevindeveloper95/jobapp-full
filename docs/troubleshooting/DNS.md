# DNS & Route53 Troubleshooting

## Common Issues

| Problem | Solution |
|---------|----------|
| Certificado no se valida | Verificar registros CNAME de validación en Route 53: `aws acm describe-certificate --certificate-arn <cert-arn> --region us-east-1` |
| CloudFront no acepta certificado | Verificar que el certificado esté en `us-east-1` (CloudFront solo acepta certificados de esta región) |
| DNS no resuelve | Verificar name servers configurados en el dominio. Esperar propagación DNS (24-48 horas) |
| CloudFront muestra error 502 | Verificar que el origin (ALB) esté accesible y responda correctamente |
| Certificado wildcard no cubre dominio raíz | Agregar dominio raíz como Subject Alternative Name (SAN) al solicitar el certificado |
| CloudFront no actualiza contenido | Invalidar caché: `aws cloudfront create-invalidation --distribution-id <dist-id> --paths "/*"` |
| Error "Certificate not found" en CloudFront | Verificar que el certificado esté en estado "ISSUED" y en `us-east-1` |
| Name servers no se propagan | Verificar registros NS: `dig NS <domain>` |

## Diagnostic Commands

```bash
# Verificar propagación DNS global
dig @8.8.8.8 <domain>
dig @1.1.1.1 <domain>

# Verificar certificado SSL
echo | openssl s_client -connect <domain>:443 -servername <domain> 2>/dev/null | openssl x509 -noout -dates

# Verificar certificado ACM
aws acm describe-certificate --certificate-arn <cert-arn> --region us-east-1

# Verificar CloudFront distribution
aws cloudfront get-distribution --id <dist-id> --query 'Distribution.Status'

# Verificar registros DNS en Route 53
aws route53 list-resource-record-sets --hosted-zone-id <zone-id>

# Verificar name servers
dig NS <domain>
nslookup <domain>
```

