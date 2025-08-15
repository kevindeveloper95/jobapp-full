# Order Service

## Description
The **Order Service** is a microservice responsible for managing order processing and payment operations within the JobApp application. This service handles order creation, payment processing with Stripe, order status management, and notification systems.

## Technologies Used / Tecnologías Utilizadas

- **Node.js** with **TypeScript**
- **Express.js** - Web framework
- **MongoDB** with **Mongoose** - Database ORM
- **Stripe** - Payment processing
- **RabbitMQ** - Message queue system
- **Socket.io** - Real-time communication
- **Redis** - Caching and session management
- **Elasticsearch** - Logging and search
- **Winston** - Logging system
- **Jest** - Testing framework
- **PM2** - Process manager for production

## Main Features / Características Principales

### 🛒 Order Management
The service handles all order-related operations:

- **Order Creation** - Create new orders
- **Payment Processing** - Stripe integration for payments
- **Order Status Management** - Track order lifecycle
- **Order Notifications** - Real-time order updates
- **Order History** - User order tracking

### 💳 Payment Processing
- **Stripe Integration** for secure payment processing
- **Payment Validation** and verification
- **Refund Management** for order cancellations
- **Payment Status Tracking** in real-time

### 🔄 Queue System
- Integration with **RabbitMQ** for asynchronous message processing
- Message producers for order events
- Connection management and automatic reconnection

### 📊 Monitoring and Logging
- Integration with **Elasticsearch** for centralized logging
- Structured logging with **Winston**
- Support for **Elastic APM** for performance monitoring

## Project Structure / Estructura del Proyecto

```
order-service/
├── src/
│   ├── app.ts              # Application entry point
│   ├── server.ts           # Express server configuration
│   ├── config.ts           # Service configuration
│   ├── routes.ts           # Route definitions
│   ├── database.ts         # Database connection
│   ├── elasticsearch.ts    # Elasticsearch configuration
│   ├── controllers/        # Request handlers
│   │   ├── order/          # Order management controllers
│   │   ├── notification/   # Notification controllers
│   │   └── health.ts       # Health check controller
│   ├── models/             # Database models
│   │   ├── order.schema.ts # Order model
│   │   └── notification.schema.ts # Notification model
│   ├── services/           # Business logic
│   │   ├── order.service.ts # Order business logic
│   │   └── notification.service.ts # Notification logic
│   ├── routes/             # Route definitions
│   ├── schemes/            # Validation schemas
│   └── queues/             # Queue management
│       ├── connection.ts   # RabbitMQ connection
│       ├── order.consumer.ts # Order consumer
│       └── order.producer.ts # Order producer
├── coverage/              # Test coverage reports
├── Dockerfile             # Docker image for production
├── Dockerfile.dev         # Docker image for development
└── package.json           # Dependencies and scripts
```

## Environment Variables / Variables de Entorno

The service requires the following environment variables:

```env
NODE_ENV=development|production
MONGODB_URL=<MONGODB_CONNECTION_STRING>
RABBITMQ_ENDPOINT=<RABBITMQ_URL>
REDIS_HOST=<REDIS_URL>
STRIPE_SECRET_KEY=<STRIPE_SECRET_KEY>
STRIPE_WEBHOOK_SECRET=<STRIPE_WEBHOOK_SECRET>
API_GATEWAY_URL=<GATEWAY_URL>
CLIENT_URL=<CLIENT_URL>
ELASTIC_SEARCH_URL=<ELASTICSEARCH_URL>
ENABLE_APM=0|1
ELASTIC_APM_SERVER_URL=<APM_URL>
ELASTIC_APM_SECRET_TOKEN=<APM_TOKEN>
```

## Available Scripts / Scripts Disponibles

### Development / Desarrollo
```bash
npm run dev          # Start server in development mode with hot reload
npm run lint:check   # Check code with ESLint
npm run lint:fix     # Automatically fix linting errors
npm run prettier:check # Check code formatting
npm run prettier:fix   # Format code automatically
```

### Production / Producción
```bash
npm run build        # Compile TypeScript
npm start           # Start service with PM2 (5 instances)

npm stop            # Stop all PM2 instances
npm run delete      # Delete all PM2 instances
```

### Testing / Testing
```bash
npm test            # Run all tests with coverage
```

## Deployment / Despliegue

### Docker
The service includes Docker configuration:

- **Dockerfile**: For production
- **Dockerfile.dev**: For development

### PM2
In production, the service runs with PM2 in cluster mode (5 instances) for high availability.

## Integration with Other Services / Integración con Otros Servicios

This microservice integrates with:

- **MongoDB**: For order data storage
- **Stripe**: For payment processing
- **RabbitMQ**: For sending order events to other services
- **Redis**: For caching and session management
- **Socket.io**: For real-time order updates
- **Elasticsearch**: For centralized logging and search
- **Shared Library** (`@kevindeveloper95/jobapp-shared`): Shared utilities

## Workflow / Flujo de Trabajo

1. **Order Creation**: Users create new orders
2. **Payment Processing**: Stripe handles payment validation
3. **Order Validation**: Order details are validated
4. **Status Management**: Order status is tracked throughout lifecycle
5. **Notification**: Real-time updates are sent to users
6. **Event Publishing**: Order events are published to RabbitMQ
7. **Logging**: Activity logging in Elasticsearch for monitoring

## Development / Desarrollo

To contribute to service development:

1. Install dependencies: `npm install`
2. Configure environment variables
3. Run in development mode: `npm run dev`
4. Run tests: `npm test`
5. Check linting: `npm run lint:check`

## Versioning / Versionado

Current version: **1.0.0**

The service uses semantic versioning for release control.

---

# Servicio de Órdenes

## Descripción
El **Servicio de Órdenes** es un microservicio encargado de gestionar el procesamiento de órdenes y operaciones de pago dentro de la aplicación JobApp. Este servicio maneja la creación de órdenes, procesamiento de pagos con Stripe, gestión del estado de las órdenes y sistemas de notificación.

## Características Principales

### 🛒 Gestión de Órdenes
El servicio maneja todas las operaciones relacionadas con órdenes:

- **Creación de Órdenes** - Crear nuevas órdenes
- **Procesamiento de Pagos** - Integración con Stripe para pagos
- **Gestión del Estado de Órdenes** - Seguimiento del ciclo de vida de la orden
- **Notificaciones de Órdenes** - Actualizaciones de órdenes en tiempo real
- **Historial de Órdenes** - Seguimiento de órdenes de usuario

### 💳 Procesamiento de Pagos
- **Integración con Stripe** para procesamiento seguro de pagos
- **Validación de Pagos** y verificación
- **Gestión de Reembolsos** para cancelaciones de órdenes
- **Seguimiento del Estado de Pago** en tiempo real

### 🔄 Sistema de Colas
- Integración con **RabbitMQ** para procesamiento asíncrono de mensajes
- Productores de mensajes para eventos de órdenes
- Manejo de conexiones y reconexiones automáticas

### 📊 Monitoreo y Logging
- Integración con **Elasticsearch** para centralización de logs
- Logging estructurado con **Winston**
- Soporte para **Elastic APM** para monitoreo de rendimiento

## Flujo de Trabajo

1. **Creación de Órdenes**: Los usuarios crean nuevas órdenes
2. **Procesamiento de Pagos**: Stripe maneja la validación de pagos
3. **Validación de Órdenes**: Los detalles de la orden son validados
4. **Gestión de Estado**: El estado de la orden se rastrea durante todo el ciclo de vida
5. **Notificación**: Las actualizaciones en tiempo real se envían a los usuarios
6. **Publicación de Eventos**: Los eventos de órdenes se publican en RabbitMQ
7. **Logging**: Registro de actividad en Elasticsearch para monitoreo 