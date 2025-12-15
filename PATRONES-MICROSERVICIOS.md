# Microservices Patterns and Concepts - JobApp

This document describes all the architectural patterns and microservices concepts implemented in the JobApp project.

---

## 📋 Table of Contents

1. [Communication Patterns](#1-communication-patterns)
2. [Integration Patterns](#2-integration-patterns)
3. [Data Patterns](#3-data-patterns)
4. [Security Patterns](#4-security-patterns)
5. [Observability Patterns](#5-observability-patterns)
6. [Resilience Patterns](#6-resilience-patterns)
7. [Deployment Patterns](#7-deployment-patterns)
8. [Architecture Concepts](#8-architecture-concepts)

---

## 1. Communication Patterns

### 1.1. API Gateway Pattern

**Description**: Single entry point for all client requests.

**Implementation**:
- **Gateway Service** (`services/gateway-service/`): Acts as reverse proxy
- All HTTP requests pass through the gateway before reaching microservices
- Centralizes cross-cutting functionality: authentication, rate limiting, CORS, logging

**Features**:
- Request routing to appropriate microservices
- JWT token validation
- Rate limiting
- CORS management
- Centralized health checks
- Reverse proxy for internal microservices

**Benefits**:
- Separation of concerns between client and services
- Reduced coupling
- Single point of security and authentication
- Client simplification (doesn't know multiple endpoints)

---

### 1.2. Event-Driven Architecture (EDA)

**Description**: Asynchronous communication between microservices through events and message queues.

**Implementation**:
- **RabbitMQ** as message broker
- Exchange patterns: **Direct Exchange** and **Fanout Exchange**
- Producers that publish events
- Consumers that process events

**Exchange Types Used**:

#### Direct Exchange
- Routing based on exact routing keys
- Used in: `auth-service`, `gig-service`, `chat-service`, `order-service`, `users-service`
- Example: `jobber-auth`, `jobber-gig`, `jobber-order`

#### Fanout Exchange
- Broadcast to all linked queues
- Used in: `review-service` to notify multiple services
- Example: `jobber-review` notifies `order-service` when a review is created

**Event Flow**:
```
Service A → Producer → RabbitMQ Exchange → Queue → Consumer → Service B
```

**Event-Driven Services**:
- **Notification Service**: Pure consumer, processes email queues (`auth-email-queue`, `order-email-queue`)
- **Order Service**: Publishes order events and consumes review events
- **Review Service**: Publishes fanout events when reviews are created
- All services publish events for notifications

**Benefits**:
- Temporal decoupling between services
- Independent scalability
- Fault tolerance (persistent messages)
- Improved asynchrony

---

### 1.3. WebSocket / Real-time Communication

**Description**: Bidirectional real-time communication between client and server.

**Implementation**:
- **Socket.io** for WebSocket connections
- **Redis Adapter** for horizontal scaling
- Implemented in Gateway Service for chat and notifications

**Features**:
- Real-time chat between users
- Instant push notifications
- User online/offline status
- Room management for private conversations
- Message broadcasting

**Architecture**:
```
Client ←→ Gateway (Socket.io) ←→ Redis Adapter ←→ Multiple Gateway instances
```

**Benefits**:
- Real-time updates
- Better user experience
- Efficient bidirectional communication

---

## 2. Integration Patterns

### 2.1. Shared Library Pattern

**Description**: Common code shared between microservices through a library.

**Implementation**:
- **Package**: `@kevindeveloper95/jobapp-shared`
- Published on GitHub Packages
- Used by all microservices

**Shared Library Content**:
- **Logging**: Winston logger with Elasticsearch integration
- **Error Handling**: Centralized error handling
- **Interfaces**: Shared TypeScript types (Auth, Order, Review, etc.)
- **Helpers**: Common utilities (Cloudinary upload, validations)
- **Gateway Middleware**: Shared middleware for validation

**Benefits**:
- DRY (Don't Repeat Yourself)
- Consistency between services
- Centralized updates
- Shared type safety

**Trade-offs**:
- Coupling to library versions
- Need for careful semantic versioning

---

### 2.2. Service Discovery

**Description**: Mechanism for services to find and communicate with each other.

**Implementation**:
- **Kubernetes DNS** (native Service Discovery)
- Naming convention: `<service-name>.<namespace>.svc.cluster.local`
- Example: `auth-service.production.svc.cluster.local`

**Configuration**:
- Each service has a Service in Kubernetes
- Gateway Service knows URLs of all services
- Configuration through environment variables

**URL Example**:
```env
AUTH_BASE_URL=http://auth-service.production.svc.cluster.local:4002
USERS_BASE_URL=http://users-service.production.svc.cluster.local:4001
GIG_BASE_URL=http://gig-service.production.svc.cluster.local:4003
```

**Benefits**:
- Decoupling from physical locations
- Easy scaling and relocation
- Native integration with Kubernetes

---

## 3. Data Patterns

### 3.1. Database per Service

**Description**: Each microservice has its own database, without sharing schemas.

**Implementation**:

| Service | Database | Purpose |
|---------|----------|---------|
| **Auth Service** | MySQL | User authentication and credentials |
| **Users Service** | MongoDB | User profiles (buyers/sellers) |
| **Gig Service** | MongoDB | Job postings (gigs) |
| **Chat Service** | MongoDB | Messages and conversations |
| **Order Service** | MongoDB | Orders and payments |
| **Review Service** | MongoDB + PostgreSQL | Reviews (MongoDB) + Analytics (PostgreSQL) |
| **Notification Service** | No own DB | Only processes events |

**Benefits**:
- Data independence
- Independent scalability
- Appropriate database technology choice per service
- Fault isolation

**Challenges**:
- More complex distributed transactions
- Eventual consistency (solved with events)
- Joins between services through APIs

---

### 3.2. Polyglot Persistence

**Description**: Use of different database types according to each service's needs.

**Implementation**:
- **MySQL**: For relational data (Auth Service)
- **MongoDB**: For flexible documents (Users, Gigs, Chat, Orders, Reviews)
- **PostgreSQL**: For analytics and complex queries (Review Service analytics)
- **Redis**: For cache and sessions

**Example**: Review Service uses MongoDB to store review documents and PostgreSQL for analytics and aggregate calculations.

**Benefits**:
- Optimal technology for each use case
- Better specialized performance
- Flexibility in data models

---

### 3.3. CQRS (Command Query Responsibility Segregation) - Partial

**Description**: Separation of read and write models.

**Partial Implementation**:
- **Review Service**: Separates storage (MongoDB) from analytics (PostgreSQL)
- Commands (writes) go to MongoDB
- Analytics queries go to PostgreSQL

**Benefits**:
- Independent optimization of reads and writes
- Differentiated scalability

---

### 3.4. Caching Pattern

**Description**: Temporary storage of frequently accessed data.

**Implementation**:
- **Redis** as distributed cache system
- Implemented in:
  - **Gateway Service**: Session and token cache
  - **Gig Service**: Cache for frequently accessed gigs
  - **Socket.io Adapter**: For horizontal scaling of WebSockets

**Strategies**:
- Cache-aside pattern
- TTL (Time To Live) for automatic invalidation
- Event-based invalidation when data changes

**Benefits**:
- Reduced database load
- Improved response time
- Lower latency

---

## 4. Security Patterns

### 4.1. API Gateway Authentication

**Description**: Centralization of authentication and authorization in the API Gateway.

**Implementation**:
- **JWT (JSON Web Tokens)** for authentication
- Gateway validates tokens before routing
- Tokens stored in cookies (httpOnly, secure)
- Authentication middleware: `authMiddleware.verifyUser`

**Flow**:
```
Client → Gateway (validates JWT) → Microservice
```

**Features**:
- Token validation at single point
- Refresh token mechanism
- Session management with Redis
- Rate limiting per user/IP

---

### 4.2. Service-to-Service Authentication

**Description**: Authentication between internal microservices.

**Implementation**:
- **Gateway Token**: Signed JWT for Gateway → Microservices communication
- Each service validates the `gatewayToken` in headers
- Middleware: `gatewayMiddleware.verifyGatewayRequest`

**Example**:
```typescript
headers: {
  'gatewayToken': sign({ id: serviceName }, GATEWAY_JWT_TOKEN)
}
```

**Benefits**:
- Prevents direct access to microservices
- Only Gateway can communicate with services
- Security in internal communication

---

### 4.3. Security Headers & CORS

**Description**: Protection through HTTP headers and CORS control.

**Implementation**:
- **Helmet.js**: Security headers (XSS, CSRF, etc.)
- **CORS**: Restrictive configuration by origin
- **HPP** (HTTP Parameter Pollution): Protection against parameter pollution
- **Cookie Security**: httpOnly, secure, sameSite

**Benefits**:
- Protection against common attacks
- Cross-origin access control
- Security in cookies and sessions

---

## 5. Observability Patterns

### 5.1. Centralized Logging

**Description**: Aggregation of logs from all microservices in a centralized location.

**Implementation**:
- **Elasticsearch** as log storage
- **Winston** logger with Elasticsearch transport
- **Winston-Elasticsearch** for integration
- Each service sends logs with metadata (service name, timestamp, level)

**Log Structure**:
```typescript
{
  service: 'auth-service',
  level: 'info',
  message: 'User logged in',
  timestamp: '2024-01-01T00:00:00Z',
  // ... more fields
}
```

**Benefits**:
- Complete system visibility
- Log search and analysis
- Simplified troubleshooting

---

### 5.2. Application Performance Monitoring (APM)

**Description**: Monitoring of application performance and behavior.

**Implementation**:
- **Elastic APM**: Integrated in services
- Transaction tracking
- Performance metrics
- Error tracing

**Configuration**:
```env
ENABLE_APM=1
ELASTIC_APM_SERVER_URL=<APM_SERVER_URL>
ELASTIC_APM_SECRET_TOKEN=<APM_TOKEN>
```

**Benefits**:
- Bottleneck identification
- Response time monitoring
- End-to-end request tracing

---

### 5.3. Health Check Pattern

**Description**: Endpoints to verify service health status.

**Implementation**:
- Each service exposes `/` endpoint for health check
- Gateway has `/gateway-health`
- Connectivity checks: DB, RabbitMQ, Elasticsearch
- Used by:
  - **Kubernetes**: Liveness and Readiness probes
  - **Heartbeat**: Uptime monitoring
  - **Load Balancers**: Routing decisions

**Example**:
```typescript
GET / → { status: 'healthy', service: 'auth-service', timestamp: ... }
```

**Benefits**:
- Early problem detection
- Auto-recovery in Kubernetes
- Availability monitoring

---

### 5.4. Distributed Tracing - Implicit

**Description**: Tracking of requests across multiple services.

**Implementation**:
- Correlated logs through request IDs
- Elasticsearch allows tracking requests by common fields
- APM provides automatic traces

**Benefits**:
- Visibility of complete request flow
- Identification of slow services
- Debugging of complex problems

---

## 6. Resilience Patterns

### 6.1. Retry Pattern

**Description**: Automatic retry of failed operations.

**Implementation**:
- **Axios interceptors**: For HTTP requests
- **Elasticsearch client**: `maxRetries: 2`
- **RabbitMQ connection**: Automatic reconnection
- **Winston**: Retry on failed logs

**Configuration**:
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

**Benefits**:
- Tolerance to temporary failures
- Higher perceived availability
- Automatic recovery

---

### 6.2. Circuit Breaker Pattern - Implicit

**Description**: Prevention of cascading failures by stopping calls to downed services.

**Implementation**:
- Timeouts in Axios requests
- Health checks before routing
- Fallbacks in client (frontend) for unavailable services

**Benefits**:
- Protection against cascading failures
- Better user experience
- Quick recovery when service returns

---

### 6.3. Bulkhead Pattern - Partial

**Description**: Resource isolation to prevent one failure from affecting others.

**Implementation**:
- **Database per Service**: Data isolation
- **Connection pool separation**: Per service
- **Kubernetes Resource Limits**: CPU and memory per pod

**Benefits**:
- Fault isolation
- Prevention of resource exhaustion
- Better system stability

---

### 6.4. Graceful Degradation

**Description**: System continues functioning with reduced features in case of failures.

**Implementation**:
- If Notification Service fails, the rest of the system continues working
- If Elasticsearch fails, logs are kept in console
- Cache fallback if Redis is unavailable

**Benefits**:
- High availability
- Better user experience
- Resistance to partial failures

---

## 7. Deployment Patterns

### 7.1. Containerization

**Description**: Packaging of applications in containers.

**Implementation**:
- **Docker** for all services
- **Dockerfile** for production
- **Dockerfile.dev** for development
- Images published on Docker Hub

**Structure**:
```dockerfile
FROM node:18-alpine
WORKDIR /usr/src/app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
RUN npm run build
CMD ["npm", "start"]
```

**Benefits**:
- Consistency between environments
- Portability
- Dependency isolation
- Scalability

---

### 7.2. Orchestration (Kubernetes)

**Description**: Management and orchestration of containers.

**Implementation**:
- **Kubernetes** for orchestration
- **Deployments** for stateless services
- **StatefulSets** for databases
- **Services** for service discovery
- **ConfigMaps** for configuration
- **Secrets** for sensitive data

**Deployment**:
- AWS EKS (Elastic Kubernetes Service) for production
- Minikube for local development

**Features**:
- Auto-scaling (HPA, VPA, KEDA)
- Self-healing (automatic restart)
- Rolling updates
- Resource management

---

### 7.3. Horizontal Pod Autoscaling (HPA)

**Description**: Automatic pod scaling based on metrics.

**Implementation**:
- HPA based on CPU and memory
- Configured for Gateway Service
- Minimum: 2 replicas, Maximum: 10 replicas
- Target: 70% CPU, 80% memory

**Benefits**:
- Automatic scaling according to demand
- Resource optimization
- High availability

---

### 7.4. Event-Driven Autoscaling (KEDA)

**Description**: Scaling based on external events (message queues).

**Implementation**:
- **KEDA** for RabbitMQ-based scaling
- Notification Service scales according to message count in queue
- Can scale to 0 when there's no work

**Example**:
```yaml
triggers:
  - type: rabbitmq
    metadata:
      queueName: auth-email-queue
      queueLength: '5'  # Scales if more than 5 messages
```

**Benefits**:
- Reactive scaling to real load
- Cost optimization (scale to zero)
- Better resource utilization

---

### 7.5. Blue-Green Deployment

**Description**: Deployment with two identical environments, alternating between them.

**Implementation**:
- **Kubernetes Rolling Updates**: Gradual update
- Zero-downtime deployments
- Health checks before traffic routing

**Benefits**:
- Deployments without downtime
- Quick rollback in case of problems
- Production testing before complete switch

---

## 8. Architecture Concepts

### 8.1. Microservice Decomposition

**Description**: Division of the application into independent services by business domain.

**Implemented Services**:

1. **Auth Service**: Authentication and authorization
2. **Users Service**: User profile management
3. **Gig Service**: Job posting management
4. **Order Service**: Order processing and payments
5. **Review Service**: Review and rating system
6. **Chat Service**: Real-time messaging
7. **Notification Service**: Email sending
8. **Gateway Service**: Entry point and routing

**Principle**: Each service handles a specific domain and is independent.

---

### 8.2. Bounded Context

**Description**: Each microservice represents a delimited domain context.

**Examples**:
- **Auth Context**: Credentials, tokens, sessions
- **Order Context**: Orders, payments, deliveries
- **Review Context**: Ratings, comments, analytics

**Benefits**:
- Clear domain models
- Lower coupling
- Ease of maintenance

---

### 8.3. Saga Pattern - Implicit

**Description**: Handling of distributed transactions through sequence of local events.

**Implementation**:
- When an order is created:
  1. Order Service creates the order
  2. Publishes event to RabbitMQ
  3. Notification Service sends confirmation email
  4. If any step fails, compensation events

**Example**:
```
Order Created → Publish Event → Notification Service → Email Sent
```

**Benefits**:
- Eventual consistency between services
- No need for expensive distributed transactions
- Resilience through compensation

---

### 8.4. Strangler Fig Pattern

**Description**: Gradual migration from monolith to microservices.

**Application**: Architecture designed from scratch as microservices, but concepts applicable for future migrations.

---

### 8.5. Backend for Frontend (BFF) - Partial

**Description**: Gateway adapts responses according to client type.

**Implementation**:
- Gateway Service acts as simplified BFF
- Unifies multiple microservice calls
- Adapts response formats

**Benefits**:
- Optimization by client type
- Latency reduction (fewer roundtrips)
- Client-service decoupling

---

## 📊 Technology Summary

| Category | Technology | Usage |
|----------|------------|-------|
| **Language** | TypeScript + Node.js | All services |
| **Framework** | Express.js | HTTP servers |
| **Message Broker** | RabbitMQ | Event-driven communication |
| **Cache** | Redis | Caching and sessions |
| **Databases** | MySQL, MongoDB, PostgreSQL | Database per Service |
| **Search/Logs** | Elasticsearch | Centralized logging and search |
| **Real-time** | Socket.io | WebSocket communication |
| **Containers** | Docker | Containerization |
| **Orchestration** | Kubernetes (EKS) | Deployment and scaling |
| **Autoscaling** | HPA, VPA, KEDA | Automatic scaling |
| **Monitoring** | Elastic APM, Kibana | Observability |
| **CI/CD** | Jenkins | Continuous Integration |

---

## 🎯 Applied Principles

1. **Single Responsibility**: Each service has a clear responsibility
2. **Independence**: Services deployable and scalable independently
3. **Decentralization**: Distributed data and logic
4. **Failure Isolation**: Failures isolated per service
5. **Automated Operations**: CI/CD, auto-scaling, self-healing
6. **Design for Failure**: Retry, circuit breakers, graceful degradation
7. **Evolutionary Design**: Architecture that evolves with the business

---

## 📚 References and Recommended Reading

- [Microservices Patterns - Chris Richardson](https://microservices.io/patterns/)
- [Building Microservices - Sam Newman](https://www.oreilly.com/library/view/building-microservices/9781491950340/)
- [Kubernetes Patterns](https://www.redhat.com/en/topics/containers/what-is-kubernetes-patterns)
- [Event-Driven Architecture](https://www.oreilly.com/library/view/designing-event-driven-systems/9781491978160/)

---

**Note**: This document reflects the patterns implemented in the JobApp project and may evolve as new features or patterns are added.




