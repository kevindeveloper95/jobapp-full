 # Patrones y Conceptos de Microservicios - JobApp

Este documento describe todos los patrones arquitectónicos y conceptos de microservicios implementados en el proyecto JobApp.

---

## 📋 Tabla de Contenidos

1. [Patrones de Comunicación](#1-patrones-de-comunicación)
2. [Patrones de Integración](#2-patrones-de-integración)
3. [Patrones de Datos](#3-patrones-de-datos)
4. [Patrones de Seguridad](#4-patrones-de-seguridad)
5. [Patrones de Observabilidad](#5-patrones-de-observabilidad)
6. [Patrones de Resiliencia](#6-patrones-de-resiliencia)
7. [Patrones de Despliegue](#7-patrones-de-despliegue)
8. [Conceptos de Arquitectura](#8-conceptos-de-arquitectura)

---

## 1. Patrones de Comunicación

### 1.1. API Gateway Pattern

**Descripción**: Punto de entrada único para todas las peticiones del cliente.

**Implementación**:
- **Gateway Service** (`services/gateway-service/`): Actúa como reverse proxy
- Todas las peticiones HTTP pasan por el gateway antes de llegar a los microservicios
- Centraliza funcionalidades cross-cutting: autenticación, rate limiting, CORS, logging

**Características**:
- Routing de peticiones a microservicios apropiados
- Validación de JWT tokens
- Rate limiting
- Gestión de CORS
- Health checks centralizados
- Proxy inverso para microservicios internos

**Beneficios**:
- Separación de concerns entre cliente y servicios
- Reducción de acoplamiento
- Punto único de seguridad y autenticación
- Simplificación del cliente (no conoce múltiples endpoints)

---

### 1.2. Event-Driven Architecture (EDA)

**Descripción**: Comunicación asíncrona entre microservicios mediante eventos y colas de mensajes.

**Implementación**:
- **RabbitMQ** como message broker
- Patrones de exchange: **Direct Exchange** y **Fanout Exchange**
- Producers que publican eventos
- Consumers que procesan eventos

**Tipos de Exchanges Utilizados**:

#### Direct Exchange
- Routing basado en routing keys exactas
- Utilizado en: `auth-service`, `gig-service`, `chat-service`, `order-service`, `users-service`
- Ejemplo: `jobber-auth`, `jobber-gig`, `jobber-order`

#### Fanout Exchange
- Broadcast a todas las colas vinculadas
- Utilizado en: `review-service` para notificar a múltiples servicios
- Ejemplo: `jobber-review` notifica a `order-service` cuando se crea una review

**Flujo de Eventos**:
```
Service A → Producer → RabbitMQ Exchange → Queue → Consumer → Service B
```

**Servicios Event-Driven**:
- **Notification Service**: Consumidor puro, procesa colas de email (`auth-email-queue`, `order-email-queue`)
- **Order Service**: Publica eventos de orden y consume eventos de reviews
- **Review Service**: Publica eventos fanout cuando se crean reviews
- Todos los servicios publican eventos para notificaciones

**Beneficios**:
- Desacoplamiento temporal entre servicios
- Escalabilidad independiente
- Tolerancia a fallos (mensajes persistentes)
- Asincronía mejorada

---

### 1.3. WebSocket / Real-time Communication

**Descripción**: Comunicación bidireccional en tiempo real entre cliente y servidor.

**Implementación**:
- **Socket.io** para WebSocket connections
- **Redis Adapter** para escalabilidad horizontal
- Implementado en Gateway Service para chat y notificaciones

**Características**:
- Chat en tiempo real entre usuarios
- Notificaciones push instantáneas
- Estado online/offline de usuarios
- Room management para conversaciones privadas
- Broadcasting de mensajes

**Arquitectura**:
```
Cliente ←→ Gateway (Socket.io) ←→ Redis Adapter ←→ Múltiples instancias de Gateway
```

**Beneficios**:
- Actualizaciones en tiempo real
- Mejor experiencia de usuario
- Comunicación bidireccional eficiente

---

## 2. Patrones de Integración

### 2.1. Shared Library Pattern

**Descripción**: Código común compartido entre microservicios mediante una librería.

**Implementación**:
- **Package**: `@kevindeveloper95/jobapp-shared`
- Publicado en GitHub Packages
- Utilizado por todos los microservicios

**Contenido de la Shared Library**:
- **Logging**: Winston logger con integración a Elasticsearch
- **Error Handling**: Manejo centralizado de errores
- **Interfaces**: Tipos TypeScript compartidos (Auth, Order, Review, etc.)
- **Helpers**: Utilidades comunes (Cloudinary upload, validaciones)
- **Gateway Middleware**: Middleware compartido para validación

**Beneficios**:
- DRY (Don't Repeat Yourself)
- Consistencia entre servicios
- Actualización centralizada
- Type safety compartida

**Trade-offs**:
- Acoplamiento a versiones de la librería
- Necesidad de versionado semántico cuidadoso

---

### 2.2. Service Discovery

**Descripción**: Mecanismo para que los servicios encuentren y se comuniquen entre sí.

**Implementación**:
- **Kubernetes DNS** (Service Discovery nativo)
- Naming convention: `<service-name>.<namespace>.svc.cluster.local`
- Ejemplo: `auth-service.production.svc.cluster.local`

**Configuración**:
- Cada servicio tiene un Service en Kubernetes
- Gateway Service conoce URLs de todos los servicios
- Configuración mediante variables de entorno

**Ejemplo de URLs**:
```env
AUTH_BASE_URL=http://auth-service.production.svc.cluster.local:4002
USERS_BASE_URL=http://users-service.production.svc.cluster.local:4001
GIG_BASE_URL=http://gig-service.production.svc.cluster.local:4003
```

**Beneficios**:
- Desacoplamiento de ubicaciones físicas
- Fácil escalado y reubicación
- Integración nativa con Kubernetes

---

## 3. Patrones de Datos

### 3.1. Database per Service

**Descripción**: Cada microservicio tiene su propia base de datos, sin compartir esquemas.

**Implementación**:

| Servicio | Base de Datos | Propósito |
|----------|---------------|-----------|
| **Auth Service** | MySQL | Autenticación y credenciales de usuario |
| **Users Service** | MongoDB | Perfiles de usuarios (buyers/sellers) |
| **Gig Service** | MongoDB | Anuncios de trabajos (gigs) |
| **Chat Service** | MongoDB | Mensajes y conversaciones |
| **Order Service** | MongoDB | Órdenes y pagos |
| **Review Service** | MongoDB + PostgreSQL | Reviews (MongoDB) + Analytics (PostgreSQL) |
| **Notification Service** | Sin BD propia | Solo procesa eventos |

**Beneficios**:
- Independencia de datos
- Escalabilidad independiente
- Elección de tecnología de BD apropiada por servicio
- Aislamiento de fallos

**Desafíos**:
- Transacciones distribuidas más complejas
- Consistencia eventual (resuelto con eventos)
- Joins entre servicios mediante APIs

---

### 3.2. Polyglot Persistence

**Descripción**: Uso de diferentes tipos de bases de datos según las necesidades de cada servicio.

**Implementación**:
- **MySQL**: Para datos relacionales (Auth Service)
- **MongoDB**: Para documentos flexibles (Users, Gigs, Chat, Orders, Reviews)
- **PostgreSQL**: Para analytics y queries complejas (Review Service analytics)
- **Redis**: Para caché y sesiones

**Ejemplo**: Review Service usa MongoDB para almacenar documentos de reviews y PostgreSQL para analytics y cálculos agregados.

**Beneficios**:
- Tecnología óptima para cada caso de uso
- Mejor rendimiento especializado
- Flexibilidad en modelos de datos

---

### 3.3. CQRS (Command Query Responsibility Segregation) - Parcial

**Descripción**: Separación de modelos de lectura y escritura.

**Implementación Parcial**:
- **Review Service**: Separa storage (MongoDB) de analytics (PostgreSQL)
- Los comandos (writes) van a MongoDB
- Las queries de analytics van a PostgreSQL

**Beneficios**:
- Optimización independiente de lecturas y escrituras
- Escalabilidad diferenciada

---

### 3.4. Caching Pattern

**Descripción**: Almacenamiento temporal de datos frecuentemente accedidos.

**Implementación**:
- **Redis** como sistema de caché distribuido
- Implementado en:
  - **Gateway Service**: Caché de sesiones y tokens
  - **Gig Service**: Caché de gigs frecuentemente consultados
  - **Socket.io Adapter**: Para escalado horizontal de WebSockets

**Estrategias**:
- Cache-aside pattern
- TTL (Time To Live) para invalidación automática
- Invalidación por eventos cuando los datos cambian

**Beneficios**:
- Reducción de carga en bases de datos
- Mejora en tiempo de respuesta
- Menor latencia

---

## 4. Patrones de Seguridad

### 4.1. API Gateway Authentication

**Descripción**: Centralización de autenticación y autorización en el API Gateway.

**Implementación**:
- **JWT (JSON Web Tokens)** para autenticación
- Gateway valida tokens antes de routing
- Tokens almacenados en cookies (httpOnly, secure)
- Middleware de autenticación: `authMiddleware.verifyUser`

**Flujo**:
```
Cliente → Gateway (valida JWT) → Microservicio
```

**Características**:
- Token validation en punto único
- Refresh token mechanism
- Session management con Redis
- Rate limiting por usuario/IP

---

### 4.2. Service-to-Service Authentication

**Descripción**: Autenticación entre microservicios internos.

**Implementación**:
- **Gateway Token**: JWT firmado para comunicación Gateway → Microservicios
- Cada servicio valida el `gatewayToken` en headers
- Middleware: `gatewayMiddleware.verifyGatewayRequest`

**Ejemplo**:
```typescript
headers: {
  'gatewayToken': sign({ id: serviceName }, GATEWAY_JWT_TOKEN)
}
```

**Beneficios**:
- Previene acceso directo a microservicios
- Solo Gateway puede comunicarse con servicios
- Seguridad en comunicación interna

---

### 4.3. Security Headers & CORS

**Descripción**: Protección mediante headers HTTP y control de CORS.

**Implementación**:
- **Helmet.js**: Headers de seguridad (XSS, CSRF, etc.)
- **CORS**: Configuración restrictiva por origen
- **HPP** (HTTP Parameter Pollution): Protección contra polución de parámetros
- **Cookie Security**: httpOnly, secure, sameSite

**Beneficios**:
- Protección contra ataques comunes
- Control de acceso cross-origin
- Seguridad en cookies y sesiones

---

## 5. Patrones de Observabilidad

### 5.1. Centralized Logging

**Descripción**: Agregación de logs de todos los microservicios en un lugar centralizado.

**Implementación**:
- **Elasticsearch** como almacén de logs
- **Winston** logger con transport a Elasticsearch
- **Winston-Elasticsearch** para integración
- Cada servicio envía logs con metadatos (service name, timestamp, level)

**Estructura de Logs**:
```typescript
{
  service: 'auth-service',
  level: 'info',
  message: 'User logged in',
  timestamp: '2024-01-01T00:00:00Z',
  // ... más campos
}
```

**Beneficios**:
- Visibilidad completa del sistema
- Búsqueda y análisis de logs
- Troubleshooting simplificado

---

### 5.2. Application Performance Monitoring (APM)

**Descripción**: Monitoreo de rendimiento y comportamiento de aplicaciones.

**Implementación**:
- **Elastic APM**: Integrado en servicios
- Tracking de transacciones
- Métricas de rendimiento
- Trazado de errores

**Configuración**:
```env
ENABLE_APM=1
ELASTIC_APM_SERVER_URL=<APM_SERVER_URL>
ELASTIC_APM_SECRET_TOKEN=<APM_TOKEN>
```

**Beneficios**:
- Identificación de cuellos de botella
- Monitoreo de tiempo de respuesta
- Trazado de requests end-to-end

---

### 5.3. Health Check Pattern

**Descripción**: Endpoints para verificar el estado de salud de los servicios.

**Implementación**:
- Cada servicio expone endpoint `/` para health check
- Gateway tiene `/gateway-health`
- Checks de conectividad: BD, RabbitMQ, Elasticsearch
- Utilizado por:
  - **Kubernetes**: Liveness y Readiness probes
  - **Heartbeat**: Monitoreo de uptime
  - **Load Balancers**: Routing decisions

**Ejemplo**:
```typescript
GET / → { status: 'healthy', service: 'auth-service', timestamp: ... }
```

**Beneficios**:
- Detección temprana de problemas
- Auto-recuperación en Kubernetes
- Monitoreo de disponibilidad

---

### 5.4. Distributed Tracing - Implícito

**Descripción**: Seguimiento de requests a través de múltiples servicios.

**Implementación**:
- Logs correlacionados mediante request IDs
- Elasticsearch permite rastrear requests por campos comunes
- APM proporciona traces automáticos

**Beneficios**:
- Visibilidad del flujo completo de requests
- Identificación de servicios lentos
- Debugging de problemas complejos

---

## 6. Patrones de Resiliencia

### 6.1. Retry Pattern

**Descripción**: Reintento automático de operaciones fallidas.

**Implementación**:
- **Axios interceptors**: Para HTTP requests
- **Elasticsearch client**: `maxRetries: 2`
- **RabbitMQ connection**: Reconnection automática
- **Winston**: Retry en logs fallidos

**Configuración**:
```typescript
axios.interceptors.response.use(
  response => response,
  error => {
    // Retry logic
    if (error.response?.status >= 500) {
      return retryRequest(error.config);
    }
  }
);
```

**Beneficios**:
- Tolerancia a fallos temporales
- Mayor disponibilidad percibida
- Recuperación automática

---

### 6.2. Circuit Breaker Pattern - Implícito

**Descripción**: Prevención de cascading failures deteniendo llamadas a servicios caídos.

**Implementación**:
- Timeouts en Axios requests
- Health checks previos al routing
- Fallbacks en cliente (frontend) para servicios no disponibles

**Beneficios**:
- Protección contra cascading failures
- Mejor experiencia de usuario
- Recuperación rápida cuando el servicio vuelve

---

### 6.3. Bulkhead Pattern - Parcial

**Descripción**: Aislamiento de recursos para prevenir que un fallo afecte a otros.

**Implementación**:
- **Database per Service**: Aislamiento de datos
- **Separación de pools de conexión**: Por servicio
- **Kubernetes Resource Limits**: CPU y memoria por pod

**Beneficios**:
- Aislamiento de fallos
- Prevención de resource exhaustion
- Mejor estabilidad del sistema

---

### 6.4. Graceful Degradation

**Descripción**: El sistema continúa funcionando con funcionalidades reducidas en caso de fallos.

**Implementación**:
- Si Notification Service falla, el resto del sistema sigue funcionando
- Si Elasticsearch falla, logs se mantienen en consola
- Cache fallback si Redis no está disponible

**Beneficios**:
- Alta disponibilidad
- Mejor experiencia de usuario
- Resistencia a fallos parciales

---

## 7. Patrones de Despliegue

### 7.1. Containerization

**Descripción**: Empaquetado de aplicaciones en contenedores.

**Implementación**:
- **Docker** para todos los servicios
- **Dockerfile** para producción
- **Dockerfile.dev** para desarrollo
- Imágenes publicadas en Docker Hub

**Estructura**:
```dockerfile
FROM node:18-alpine
WORKDIR /usr/src/app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
RUN npm run build
CMD ["npm", "start"]
```

**Beneficios**:
- Consistencia entre entornos
- Portabilidad
- Aislamiento de dependencias
- Escalabilidad

---

### 7.2. Orchestration (Kubernetes)

**Descripción**: Gestión y orquestación de contenedores.

**Implementación**:
- **Kubernetes** para orquestación
- **Deployments** para servicios stateless
- **StatefulSets** para bases de datos
- **Services** para service discovery
- **ConfigMaps** para configuración
- **Secrets** para datos sensibles

**Despliegue**:
- AWS EKS (Elastic Kubernetes Service) para producción
- Minikube para desarrollo local

**Características**:
- Auto-scaling (HPA, VPA, KEDA)
- Self-healing (restart automático)
- Rolling updates
- Resource management

---

### 7.3. Horizontal Pod Autoscaling (HPA)

**Descripción**: Escalado automático de pods basado en métricas.

**Implementación**:
- HPA basado en CPU y memoria
- Configurado para Gateway Service
- Mínimo: 2 replicas, Máximo: 10 replicas
- Target: 70% CPU, 80% memoria

**Beneficios**:
- Escalado automático según demanda
- Optimización de recursos
- Alta disponibilidad

---

### 7.4. Event-Driven Autoscaling (KEDA)

**Descripción**: Escalado basado en eventos externos (colas de mensajes).

**Implementación**:
- **KEDA** para escalado basado en RabbitMQ
- Notification Service escala según cantidad de mensajes en cola
- Puede escalar a 0 cuando no hay trabajo

**Ejemplo**:
```yaml
triggers:
  - type: rabbitmq
    metadata:
      queueName: auth-email-queue
      queueLength: '5'  # Escala si hay más de 5 mensajes
```

**Beneficios**:
- Escalado reactivo a carga real
- Optimización de costos (scale to zero)
- Mejor utilización de recursos

---

### 7.5. Blue-Green Deployment

**Descripción**: Despliegue con dos entornos idénticos, alternando entre ellos.

**Implementación**:
- **Kubernetes Rolling Updates**: Actualización gradual
- Zero-downtime deployments
- Health checks antes de routing de tráfico

**Beneficios**:
- Despliegues sin downtime
- Rollback rápido en caso de problemas
- Testing en producción antes de switch completo

---

## 8. Conceptos de Arquitectura

### 8.1. Microservice Decomposition

**Descripción**: División de la aplicación en servicios independientes por dominio de negocio.

**Servicios Implementados**:

1. **Auth Service**: Autenticación y autorización
2. **Users Service**: Gestión de perfiles de usuarios
3. **Gig Service**: Gestión de anuncios de trabajos
4. **Order Service**: Procesamiento de órdenes y pagos
5. **Review Service**: Sistema de reseñas y ratings
6. **Chat Service**: Mensajería en tiempo real
7. **Notification Service**: Envío de emails
8. **Gateway Service**: Punto de entrada y routing

**Principio**: Cada servicio maneja un dominio específico y es independiente.

---

### 8.2. Bounded Context

**Descripción**: Cada microservicio representa un contexto delimitado del dominio.

**Ejemplos**:
- **Auth Context**: Credenciales, tokens, sesiones
- **Order Context**: Órdenes, pagos, entregas
- **Review Context**: Calificaciones, comentarios, analytics

**Beneficios**:
- Modelos de dominio claros
- Menor acoplamiento
- Facilidad de mantenimiento

---

### 8.3. Saga Pattern - Implícito

**Descripción**: Manejo de transacciones distribuidas mediante secuencia de eventos locales.

**Implementación**:
- Cuando se crea una orden:
  1. Order Service crea la orden
  2. Publica evento a RabbitMQ
  3. Notification Service envía email de confirmación
  4. Si falla algún paso, eventos de compensación

**Ejemplo**:
```
Order Created → Publish Event → Notification Service → Email Sent
```

**Beneficios**:
- Consistencia eventual entre servicios
- Sin necesidad de transacciones distribuidas costosas
- Resiliencia mediante compensación

---

### 8.4. Strangler Fig Pattern

**Descripción**: Migración gradual de monolito a microservicios.

**Aplicación**: Arquitectura diseñada desde cero como microservicios, pero conceptos aplicables para futuras migraciones.

---

### 8.5. Backend for Frontend (BFF) - Parcial

**Descripción**: Gateway adapta respuestas según el tipo de cliente.

**Implementación**:
- Gateway Service actúa como BFF simplificado
- Unifica múltiples llamadas de microservicios
- Adapta formatos de respuesta

**Beneficios**:
- Optimización por tipo de cliente
- Reducción de latencia (menos roundtrips)
- Desacoplamiento cliente-servicios

---

## 📊 Resumen de Tecnologías

| Categoría | Tecnología | Uso |
|-----------|------------|-----|
| **Lenguaje** | TypeScript + Node.js | Todos los servicios |
| **Framework** | Express.js | Servidores HTTP |
| **Message Broker** | RabbitMQ | Event-driven communication |
| **Cache** | Redis | Caching y sesiones |
| **Bases de Datos** | MySQL, MongoDB, PostgreSQL | Database per Service |
| **Search/Logs** | Elasticsearch | Centralized logging y búsqueda |
| **Real-time** | Socket.io | WebSocket communication |
| **Containers** | Docker | Containerization |
| **Orchestration** | Kubernetes (EKS) | Despliegue y escalado |
| **Autoscaling** | HPA, VPA, KEDA | Escalado automático |
| **Monitoring** | Elastic APM, Kibana | Observabilidad |
| **CI/CD** | Jenkins | Continuous Integration |

---

## 🎯 Principios Aplicados

1. **Single Responsibility**: Cada servicio tiene una responsabilidad clara
2. **Independence**: Servicios desplegables y escalables independientemente
3. **Decentralization**: Datos y lógica distribuidos
4. **Failure Isolation**: Fallos aislados por servicio
5. **Automated Operations**: CI/CD, auto-scaling, self-healing
6. **Design for Failure**: Retry, circuit breakers, graceful degradation
7. **Evolutionary Design**: Arquitectura que evoluciona con el negocio

---

## 📚 Referencias y Lecturas Recomendadas

- [Microservices Patterns - Chris Richardson](https://microservices.io/patterns/)
- [Building Microservices - Sam Newman](https://www.oreilly.com/library/view/building-microservices/9781491950340/)
- [Kubernetes Patterns](https://www.redhat.com/en/topics/containers/what-is-kubernetes-patterns)
- [Event-Driven Architecture](https://www.oreilly.com/library/view/designing-event-driven-systems/9781491978160/)

---

**Nota**: Este documento refleja los patrones implementados en el proyecto JobApp y puede evolucionar conforme se añadan nuevas funcionalidades o patrones.







