# Networking Troubleshooting

## Common Issues

| Problem | Solution |
|---------|----------|
| Nodos no pueden acceder a Internet | Verificar Internet Gateway: `aws ec2 describe-internet-gateways --internet-gateway-ids <igw-id> --query 'InternetGateways[0].Attachments[0].State'` (debe ser "available") |
| Internet Gateway no está attached | `aws ec2 describe-internet-gateways --filters "Name=attachment.vpc-id,Values=<vpc-id>"` |
| NAT Gateway no disponible | Verificar estado: `aws ec2 describe-nat-gateways --nat-gateway-ids <nat-gateway-id> --query 'NatGateways[0].State'` (debe ser "available") |
| Subnets privadas no pueden acceder a Internet | Verificar ruta: `aws ec2 describe-route-tables --route-table-ids <rtb-private-id> --query 'RouteTables[0].Routes[?NatGatewayId==`<nat-gateway-id>`].State'` |
| Pods no pueden comunicarse entre sí | Verificar Security Groups permiten tráfico interno |
| No se pueden crear Load Balancers | Verificar que hay al menos 2 subnets en diferentes AZs |
| DNS no funciona en pods | Verificar DNS resolution: `aws ec2 describe-vpc-attribute --vpc-id <vpc-id> --attribute enableDnsSupport` |
| No se pueden resolver nombres de servicios | Verificar DNS hostnames: `aws ec2 describe-vpc-attribute --vpc-id <vpc-id> --attribute enableDnsHostnames` |

## Diagnostic Commands

```bash
# Verificar VPC
aws ec2 describe-vpcs --vpc-ids <vpc-id> --region <region>

# Verificar subnets
aws ec2 describe-subnets --filters "Name=vpc-id,Values=<vpc-id>" --region <region>

# Verificar route tables
aws ec2 describe-route-tables --filters "Name=vpc-id,Values=<vpc-id>" --region <region>

# Verificar NAT Gateway
aws ec2 describe-nat-gateways --filter "Name=vpc-id,Values=<vpc-id>" --region <region>

# Verificar Internet Gateway
aws ec2 describe-internet-gateways --filters "Name=attachment.vpc-id,Values=<vpc-id>" --region <region>
```

