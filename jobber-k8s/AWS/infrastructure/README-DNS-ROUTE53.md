# DNS y Route 53 - Jobber

Esta guía documenta la configuración de DNS, Route 53, CloudFront y certificados SSL/TLS para el proyecto Jobber en AWS.

---

## 📋 Tabla de Contenidos

1. [Route 53 Hosted Zone](#1-route-53-hosted-zone)
2. [Configuración del Dominio Original](#2-configuración-del-dominio-original)
3. [Certificados SSL/TLS con ACM](#3-certificados-ssltls-con-acm)
4. [CloudFront Distribution](#4-cloudfront-distribution)
5. [Configuración de Registros DNS](#5-configuración-de-registros-dns)
6. [Verificación y Testing](#6-verificación-y-testing)
7. [Troubleshooting](#7-troubleshooting)
8. [Costos Estimados](#8-costos-estimados)
9. [Información de Referencia Rápida](#9-información-de-referencia-rápida)

---

## 1. Route 53 Hosted Zone

### 1.1. Información General de la Hosted Zone

- **Hosted Zone Name**: `api.jobberapp.kevmendeveloper.com`
- **Hosted Zone ID**: `Z0220383WELM11X3469T`
- **Description**: Hosted for api.jobberapp.kevmendeveloper.com domain
- **Type**: Public hosted zone
- **Record Count**: 2
- **Query Log**: No configurado (opcional)

### 1.2. Name Servers (NS)

La hosted zone tiene los siguientes name servers asignados por AWS:

| # | Name Server |
|---|-------------|
| 1 | `ns-806.awsdns-36.net` |
| 2 | `ns-1864.awsdns-41.co.uk` |
| 3 | `ns-1278.awsdns-31.org` |
| 4 | `ns-333.awsdns-41.com` |

**⚠️ IMPORTANTE**: Estos name servers deben ser configurados en el dominio original (`kevmendeveloper.com`) para que Route 53 pueda gestionar el DNS del subdominio `api.jobberapp.kevmendeveloper.com`.

### 1.3. Verificar Hosted Zone

```bash
# Ver detalles de la hosted zone
aws route53 get-hosted-zone --id Z0220383WELM11X3469T

# Listar todas las hosted zones
aws route53 list-hosted-zones

# Ver name servers de la hosted zone
aws route53 get-hosted-zone --id Z0220383WELM11X3469T --query 'DelegationSet.NameServers'

# Ver todos los registros DNS de la hosted zone
aws route53 list-resource-record-sets --hosted-zone-id Z0220383WELM11X3469T
```

---

## 2. Configuración del Dominio Original

### 2.1. Dominio Base

**Dominio Original**: `kevmendeveloper.com`

Este es el dominio principal que probablemente está registrado en otro proveedor (GoDaddy, Namecheap, etc.) o en Route 53.

### 2.2. Configuración de Name Servers en el Dominio Original

Para que Route 53 pueda gestionar el subdominio `api.jobberapp.kevmendeveloper.com`, necesitas crear un registro NS (Name Server) en el dominio original `kevmendeveloper.com`.

#### Opción A: Si el dominio está en Route 53

Si `kevmendeveloper.com` también está en Route 53:

1. Ve a la hosted zone de `kevmendeveloper.com` en Route 53
2. Crea un nuevo registro NS con:
   - **Name**: `api.jobberapp` (o `api.jobberapp.kevmendeveloper.com`)
   - **Type**: NS
   - **Value**: Los 4 name servers de la hosted zone `api.jobberapp.kevmendeveloper.com`:
     - `ns-806.awsdns-36.net`
     - `ns-1864.awsdns-41.co.uk`
     - `ns-1278.awsdns-31.org`
     - `ns-333.awsdns-41.com`
   - **TTL**: 300 (o el valor recomendado)

#### Opción B: Si el dominio está en otro proveedor

Si `kevmendeveloper.com` está registrado en otro proveedor (GoDaddy, Namecheap, etc.):

1. Inicia sesión en el panel de control de tu proveedor de dominio
2. Ve a la sección de DNS Management o Zone Records
3. Crea un nuevo registro NS:
   - **Host/Name**: `api.jobberapp` (o `api.jobberapp.kevmendeveloper.com`)
   - **Type**: NS
   - **Value/Points to**: Los 4 name servers (uno por línea o separados por comas):
     ```
     ns-806.awsdns-36.net
     ns-1864.awsdns-41.co.uk
     ns-1278.awsdns-31.org
     ns-333.awsdns-41.com
     ```
   - **TTL**: 3600 (1 hora) o el valor recomendado por tu proveedor

### 2.3. Verificar Configuración

```bash
# Verificar que los name servers están configurados correctamente
dig NS api.jobberapp.kevmendeveloper.com

# O usando nslookup (Windows)
nslookup -type=NS api.jobberapp.kevmendeveloper.com

# Verificar propagación DNS (puede tardar hasta 48 horas)
dig api.jobberapp.kevmendeveloper.com
```

**Nota**: La propagación DNS puede tardar entre 24-48 horas, aunque generalmente es más rápida (1-4 horas).

---

## 3. Certificados SSL/TLS con ACM

### 3.1. Certificado Wildcard

Para cubrir todos los subdominios (como `api.jobberapp.kevmendeveloper.com`, `www.jobberapp.kevmendeveloper.com`, etc.), es recomendable usar un certificado wildcard.

**Certificado Wildcard**: `*.jobberapp.kevmendeveloper.com`

Este certificado cubrirá:
- ✅ `api.jobberapp.kevmendeveloper.com`
- ✅ `www.jobberapp.kevmendeveloper.com`
- ✅ `app.jobberapp.kevmendeveloper.com`
- ✅ Cualquier otro subdominio bajo `jobberapp.kevmendeveloper.com`

**⚠️ IMPORTANTE**: El wildcard `*` NO cubre el dominio raíz `jobberapp.kevmendeveloper.com`. Si necesitas cubrir también el dominio raíz, debes crear un certificado con múltiples dominios o usar SAN (Subject Alternative Names).

### 3.2. Crear Certificado en ACM

#### Paso 1: Solicitar Certificado

```bash
# Solicitar certificado wildcard
aws acm request-certificate \
  --domain-name "*.jobberapp.kevmendeveloper.com" \
  --validation-method DNS \
  --region us-east-1 \
  --subject-alternative-names "jobberapp.kevmendeveloper.com" \
  --tags Key=Name,Value=jobber-wildcard-cert
```

**Nota**: 
- `--validation-method DNS`: Requiere crear registros CNAME en Route 53 para validar el certificado
- `--subject-alternative-names`: Incluye el dominio raíz además del wildcard
- `--region us-east-1`: **IMPORTANTE** - CloudFront solo acepta certificados de la región `us-east-1`

#### Paso 2: Obtener Información de Validación

```bash
# Obtener el ARN del certificado (reemplaza CERTIFICATE_ARN con el ARN real)
CERT_ARN=$(aws acm list-certificates --region us-east-1 --query 'CertificateSummaryList[?DomainName==`*.jobberapp.kevmendeveloper.com`].CertificateArn' --output text)

# Ver detalles del certificado
aws acm describe-certificate --certificate-arn $CERT_ARN --region us-east-1

# Obtener registros CNAME para validación
aws acm describe-certificate --certificate-arn $CERT_ARN --region us-east-1 --query 'Certificate.DomainValidationOptions'
```

#### Paso 3: Crear Registros CNAME de Validación en Route 53

Para cada dominio en el certificado, necesitas crear un registro CNAME en Route 53:

```bash
# Obtener los registros de validación
aws acm describe-certificate --certificate-arn $CERT_ARN --region us-east-1 \
  --query 'Certificate.DomainValidationOptions[*].[DomainName,ResourceRecord.Name,ResourceRecord.Value]' \
  --output table
```

Luego, crea los registros CNAME en Route 53:

```bash
# Crear registro CNAME para validación del wildcard
aws route53 change-resource-record-sets \
  --hosted-zone-id Z0220383WELM11X3469T \
  --change-batch '{
    "Changes": [{
      "Action": "CREATE",
      "ResourceRecordSet": {
        "Name": "_validation-name-from-acm.jobberapp.kevmendeveloper.com",
        "Type": "CNAME",
        "TTL": 300,
        "ResourceRecords": [{
          "Value": "_validation-value-from-acm.acm-validations.aws."
        }]
      }
    }]
  }'
```

**Nota**: Reemplaza `_validation-name-from-acm` y `_validation-value-from-acm` con los valores reales obtenidos del paso anterior.

#### Paso 4: Validación Automática (Recomendado)

Si la hosted zone está en la misma cuenta de AWS, puedes usar validación automática:

```bash
# Esperar a que ACM valide automáticamente (si la hosted zone está en la misma cuenta)
aws acm wait certificate-validated \
  --certificate-arn $CERT_ARN \
  --region us-east-1
```

O verificar el estado manualmente:

```bash
# Verificar estado del certificado
aws acm describe-certificate --certificate-arn $CERT_ARN --region us-east-1 \
  --query 'Certificate.Status'
# Debe devolver: "ISSUED"
```

### 3.3. Verificar Certificado

```bash
# Listar todos los certificados
aws acm list-certificates --region us-east-1

# Ver detalles de un certificado específico
aws acm describe-certificate --certificate-arn $CERT_ARN --region us-east-1

# Verificar que el certificado está validado
aws acm describe-certificate --certificate-arn $CERT_ARN --region us-east-1 \
  --query 'Certificate.Status'
```

---

## 4. CloudFront Distribution

### 4.1. Crear CloudFront Distribution

CloudFront se usa para:
- Distribución global de contenido (CDN)
- Terminación SSL/TLS con certificados ACM
- Caché de contenido estático
- Protección DDoS

#### Paso 1: Preparar Configuración

Antes de crear la distribución, necesitas:
1. ✅ Certificado ACM validado en `us-east-1`
2. ✅ Origin (ALB, S3, o endpoint de API)
3. ✅ Dominio configurado en Route 53

#### Paso 2: Crear Distribution (AWS Console)

1. Ve a **CloudFront** en la consola de AWS
2. Click en **Create Distribution**
3. Configura:
   - **Origin Domain**: Tu ALB o endpoint (ej: `k8s-jobber-gateway-xxxxx.us-east-1.elb.amazonaws.com`)
   - **Origin Path**: `/` (o el path específico)
   - **Origin Protocol Policy**: `HTTPS Only` (recomendado)
   - **Viewer Protocol Policy**: `Redirect HTTP to HTTPS`
   - **Allowed HTTP Methods**: `GET, HEAD, OPTIONS, PUT, POST, PATCH, DELETE`
   - **Cache Policy**: `CachingOptimized` o `CachingDisabled` (según necesidad)
   - **Alternate Domain Names (CNAMEs)**: 
     - `api.jobberapp.kevmendeveloper.com`
     - `*.jobberapp.kevmendeveloper.com` (si aplica)
   - **SSL Certificate**: Selecciona el certificado ACM creado anteriormente
   - **Default Root Object**: (dejar vacío para APIs)

#### Paso 3: Crear Distribution (AWS CLI)

```bash
# Crear CloudFront distribution
aws cloudfront create-distribution \
  --distribution-config '{
    "CallerReference": "jobber-api-'$(date +%s)'",
    "Comment": "Jobber API Distribution",
    "DefaultCacheBehavior": {
      "TargetOriginId": "jobber-alb-origin",
      "ViewerProtocolPolicy": "redirect-to-https",
      "AllowedMethods": {
        "Quantity": 7,
        "Items": ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"],
        "CachedMethods": {
          "Quantity": 2,
          "Items": ["GET", "HEAD"]
        }
      },
      "ForwardedValues": {
        "QueryString": true,
        "Cookies": {
          "Forward": "all"
        },
        "Headers": {
          "Quantity": 1,
          "Items": ["*"]
        }
      },
      "MinTTL": 0,
      "DefaultTTL": 0,
      "MaxTTL": 0,
      "Compress": true
    },
    "Origins": {
      "Quantity": 1,
      "Items": [{
        "Id": "jobber-alb-origin",
        "DomainName": "k8s-jobber-gateway-xxxxx.us-east-1.elb.amazonaws.com",
        "CustomOriginConfig": {
          "HTTPPort": 80,
          "HTTPSPort": 443,
          "OriginProtocolPolicy": "https-only",
          "OriginSslProtocols": {
            "Quantity": 1,
            "Items": ["TLSv1.2"]
          }
        }
      }]
    },
    "Aliases": {
      "Quantity": 1,
      "Items": ["api.jobberapp.kevmendeveloper.com"]
    },
    "ViewerCertificate": {
      "ACMCertificateArn": "arn:aws:acm:us-east-1:ACCOUNT_ID:certificate/CERT_ID",
      "SSLSupportMethod": "sni-only",
      "MinimumProtocolVersion": "TLSv1.2_2021"
    },
    "Enabled": true,
    "PriceClass": "PriceClass_100"
  }'
```

**⚠️ IMPORTANTE**: 
- Reemplaza `ACCOUNT_ID` y `CERT_ID` con los valores reales
- Reemplaza `DomainName` con tu ALB real
- El certificado debe estar en `us-east-1`

### 4.2. Obtener CloudFront Domain Name

Después de crear la distribución, obtendrás un domain name de CloudFront:

```
d1234567890abc.cloudfront.net
```

Este domain name se usará para crear el registro DNS en Route 53.

### 4.3. Verificar CloudFront Distribution

```bash
# Listar todas las distribuciones
aws cloudfront list-distributions

# Ver detalles de una distribución específica
aws cloudfront get-distribution --id E1234567890ABC

# Verificar estado
aws cloudfront get-distribution --id E1234567890ABC \
  --query 'Distribution.Status'
# Debe devolver: "Deployed" cuando esté lista
```

---

## 5. Configuración de Registros DNS

### 5.1. Crear Registro A (Alias) en Route 53

Una vez que CloudFront esté desplegado, crea un registro A (Alias) en Route 53 que apunte a CloudFront:

```bash
# Crear registro A (Alias) apuntando a CloudFront
aws route53 change-resource-record-sets \
  --hosted-zone-id Z0220383WELM11X3469T \
  --change-batch '{
    "Changes": [{
      "Action": "CREATE",
      "ResourceRecordSet": {
        "Name": "api.jobberapp.kevmendeveloper.com",
        "Type": "A",
        "AliasTarget": {
          "HostedZoneId": "Z2FDTNDATAQYW2",
          "DNSName": "d1234567890abc.cloudfront.net",
          "EvaluateTargetHealth": false
        }
      }
    }]
  }'
```

**Nota**: 
- `Z2FDTNDATAQYW2` es el Hosted Zone ID de CloudFront (es el mismo para todas las distribuciones)
- Reemplaza `d1234567890abc.cloudfront.net` con tu CloudFront domain name real
- `EvaluateTargetHealth` debe ser `false` para CloudFront

### 5.2. Crear Registro AAAA (IPv6) - Opcional

Para soporte IPv6:

```bash
aws route53 change-resource-record-sets \
  --hosted-zone-id Z0220383WELM11X3469T \
  --change-batch '{
    "Changes": [{
      "Action": "CREATE",
      "ResourceRecordSet": {
        "Name": "api.jobberapp.kevmendeveloper.com",
        "Type": "AAAA",
        "AliasTarget": {
          "HostedZoneId": "Z2FDTNDATAQYW2",
          "DNSName": "d1234567890abc.cloudfront.net",
          "EvaluateTargetHealth": false
        }
      }
    }]
  }'
```

### 5.3. Verificar Registros DNS

```bash
# Ver todos los registros de la hosted zone
aws route53 list-resource-record-sets --hosted-zone-id Z0220383WELM11X3469T

# Ver registro específico
aws route53 list-resource-record-sets \
  --hosted-zone-id Z0220383WELM11X3469T \
  --query "ResourceRecordSets[?Name=='api.jobberapp.kevmendeveloper.com.']"

# Verificar DNS con dig
dig api.jobberapp.kevmendeveloper.com

# Verificar con nslookup (Windows)
nslookup api.jobberapp.kevmendeveloper.com
```

---

## 6. Verificación y Testing

### 6.1. Verificar Certificado SSL

```bash
# Verificar certificado SSL con openssl
openssl s_client -connect api.jobberapp.kevmendeveloper.com:443 -servername api.jobberapp.kevmendeveloper.com

# Verificar con curl
curl -vI https://api.jobberapp.kevmendeveloper.com

# Verificar certificado con navegador
# Abre https://api.jobberapp.kevmendeveloper.com en un navegador y verifica el certificado
```

### 6.2. Verificar CloudFront

```bash
# Verificar que CloudFront responde
curl -I https://api.jobberapp.kevmendeveloper.com

# Verificar headers de CloudFront
curl -I https://api.jobberapp.kevmendeveloper.com | grep -i cloudfront

# Verificar caché
curl -v https://api.jobberapp.kevmendeveloper.com 2>&1 | grep -i "x-cache"
```

### 6.3. Verificar End-to-End

```bash
# Test completo de la API
curl -X GET https://api.jobberapp.kevmendeveloper.com/health

# Test con headers
curl -X GET https://api.jobberapp.kevmendeveloper.com/api/v1/endpoint \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

---

## 7. Troubleshooting

For common DNS and Route53 issues, see the [DNS Troubleshooting Guide](../../../docs/troubleshooting/DNS.md).
```

---

## 8. Costos Estimados

| Componente | Costo Mensual | Notas |
|------------|---------------|-------|
| Route 53 Hosted Zone | $0.50 | Por hosted zone |
| Route 53 Queries | $0.40 por millón | Primer millón gratis |
| ACM Certificate | Gratis | Certificados SSL/TLS son gratuitos |
| CloudFront | Variable | Depende del tráfico y data transfer |
| CloudFront - Primeros 10TB | $0.085/GB | Precio por región |
| CloudFront - Requests | $0.0075 por 10,000 | Requests HTTP/HTTPS |

**Nota**: Los certificados ACM son completamente gratuitos. CloudFront tiene un free tier limitado.

---

## 9. Información de Referencia Rápida

### 9.1. IDs y Nombres Importantes

| Componente | ID/Nombre | Valor |
|-----------|-----------|-------|
| Hosted Zone Name | `api.jobberapp.kevmendeveloper.com` | - |
| Hosted Zone ID | `Z0220383WELM11X3469T` | - |
| Name Server 1 | `ns-806.awsdns-36.net` | - |
| Name Server 2 | `ns-1864.awsdns-41.co.uk` | - |
| Name Server 3 | `ns-1278.awsdns-31.org` | - |
| Name Server 4 | `ns-333.awsdns-41.com` | - |
| Dominio Original | `kevmendeveloper.com` | - |
| CloudFront Hosted Zone ID | `Z2FDTNDATAQYW2` | (Fijo para todas las distribuciones) |
| Región ACM | `us-east-1` | (Requerido para CloudFront) |

### 9.2. Comandos Rápidos

```bash
# Ver hosted zone
aws route53 get-hosted-zone --id Z0220383WELM11X3469T

# Ver name servers
aws route53 get-hosted-zone --id Z0220383WELM11X3469T --query 'DelegationSet.NameServers'

# Listar certificados ACM
aws acm list-certificates --region us-east-1

# Listar distribuciones CloudFront
aws cloudfront list-distributions

# Ver registros DNS
aws route53 list-resource-record-sets --hosted-zone-id Z0220383WELM11X3469T

# Verificar DNS
dig api.jobberapp.kevmendeveloper.com
```

### 9.3. Flujo Completo de Configuración

```
1. Crear Hosted Zone en Route 53
   └─> Obtener Name Servers

2. Configurar Name Servers en dominio original
   └─> Crear registro NS en kevmendeveloper.com

3. Solicitar certificado ACM (us-east-1)
   └─> *.jobberapp.kevmendeveloper.com + jobberapp.kevmendeveloper.com

4. Validar certificado
   └─> Crear registros CNAME en Route 53

5. Crear CloudFront Distribution
   └─> Configurar origin (ALB)
   └─> Asociar certificado ACM
   └─> Configurar CNAMEs

6. Crear registro A (Alias) en Route 53
   └─> Apuntar a CloudFront domain name

7. Esperar propagación DNS (1-48 horas)
   └─> Verificar con dig/nslookup

8. Test end-to-end
   └─> curl https://api.jobberapp.kevmendeveloper.com
```

---

## 📚 Referencias

- [AWS Route 53 Documentation](https://docs.aws.amazon.com/route53/)
- [AWS Certificate Manager (ACM) Documentation](https://docs.aws.amazon.com/acm/)
- [AWS CloudFront Documentation](https://docs.aws.amazon.com/cloudfront/)
- [CloudFront and ACM Integration](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/cnames-and-https.html)
- [Route 53 DNS Best Practices](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/dns-best-practices.html)

---

## 🔐 Notas de Seguridad

1. **Certificados Wildcard**: Los certificados wildcard (`*.domain.com`) cubren todos los subdominios, pero NO el dominio raíz. Si necesitas el dominio raíz, agrégalo como SAN.

2. **Región ACM**: CloudFront **SOLO** acepta certificados de la región `us-east-1`. Asegúrate de crear el certificado en esta región.

3. **Validación DNS**: La validación DNS es más segura que la validación por email, ya que no requiere acceso a cuentas de email.

4. **HTTPS Only**: Siempre configura CloudFront para redirigir HTTP a HTTPS.

5. **Protocolos TLS**: Usa TLS 1.2 o superior. CloudFront soporta TLS 1.2 y 1.3.

---

## 📝 Checklist de Configuración

- [ ] Hosted Zone creada en Route 53
- [ ] Name servers configurados en dominio original
- [ ] Certificado ACM solicitado en `us-east-1`
- [ ] Certificado validado (estado: ISSUED)
- [ ] CloudFront distribution creada
- [ ] Certificado ACM asociado a CloudFront
- [ ] CNAMEs configurados en CloudFront
- [ ] Registro A (Alias) creado en Route 53
- [ ] DNS propagado (verificado con dig/nslookup)
- [ ] SSL/TLS funcionando (verificado con curl/openssl)
- [ ] API accesible vía HTTPS
- [ ] CloudFront caché funcionando correctamente

