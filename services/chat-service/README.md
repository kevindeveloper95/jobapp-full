# Chat Service

## Description
The **Chat Service** is a microservice responsible for managing real-time messaging and communication between users within the JobApp application. This service handles message exchange, conversation management, and real-time chat functionality using Socket.io and MongoDB.

## Technologies Used / Tecnologías Utilizadas

- **Node.js** with **TypeScript**
- **Express.js** - Web framework
- **Socket.io** - Real-time WebSocket communication
- **MongoDB** with **Mongoose** - Database ORM
- **Redis** - Caching and session management
- **RabbitMQ** - Message queue system
- **Elasticsearch** - Logging and search
- **Winston** - Logging system
- **Jest** - Testing framework
- **PM2** - Process manager for production

## Main Features / Características Principales

### 💬 Real-time Messaging
The service handles all chat-related operations:

- **Message Exchange** - Real-time message sending and receiving
- **Conversation Management** - Create and manage chat conversations
- **Message History** - Store and retrieve message history
- **Online Status** - Track user online/offline status
- **Message Notifications** - Real-time message notifications

### 🔌 WebSocket Communication
- **Socket.io Integration** for real-time bidirectional communication
- **Room Management** for private and group conversations
- **Connection Management** and automatic reconnection
- **Message Broadcasting** to multiple users

### 🔄 Queue System
- Integration with **RabbitMQ** for asynchronous message processing
- Message producers for chat events
- Connection management and automatic reconnection

### 📊 Monitoring and Logging
- Integration with **Elasticsearch** for centralized logging
- Structured logging with **Winston**
- Support for **Elastic APM** for performance monitoring

## Project Structure / Estructura del Proyecto

```
chat-service/
├── src/
│   ├── app.ts              # Application entry point
│   ├── server.ts           # Express server configuration
│   ├── config.ts           # Service configuration
│   ├── routes.ts           # Route definitions
│   ├── database.ts         # Database connection
│   ├── elasticsearch.ts    # Elasticsearch configuration
│   ├── controllers/        # Request handlers
│   │   ├── create.ts       # Message creation
│   │   ├── get.ts          # Message retrieval
│   │   └── health.ts       # Health check controller
│   ├── models/             # Database models
│   │   ├── conversation.schema.ts # Conversation model
│   │   └── message.schema.ts # Message model
│   ├── services/           # Business logic
│   │   └── message.service.ts # Message business logic
│   ├── routes/             # Route definitions
│   ├── schemes/            # Validation schemas
│   └── queues/             # Queue management
│       ├── connection.ts   # RabbitMQ connection
│       └── message.producer.ts # Message producer
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

- **MongoDB**: For message and conversation storage
- **Socket.io**: For real-time communication
- **Redis**: For caching and session management
- **RabbitMQ**: For sending chat events to other services
- **Elasticsearch**: For centralized logging and search
- **Shared Library** (`@kevindeveloper95/jobapp-shared`): Shared utilities

## Workflow / Flujo de Trabajo

1. **Connection**: Users connect via WebSocket
2. **Authentication**: User authentication and session management
3. **Message Sending**: Real-time message exchange
4. **Message Storage**: Messages are stored in MongoDB
5. **Event Publishing**: Chat events are published to RabbitMQ
6. **Notification**: Real-time notifications to connected users
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

# Servicio de Chat

## Descripción
El **Servicio de Chat** es un microservicio encargado de gestionar la mensajería en tiempo real y la comunicación entre usuarios dentro de la aplicación JobApp. Este servicio maneja el intercambio de mensajes, gestión de conversaciones y funcionalidad de chat en tiempo real usando Socket.io y MongoDB.

## Características Principales

### 💬 Mensajería en Tiempo Real
El servicio maneja todas las operaciones relacionadas con chat:

- **Intercambio de Mensajes** - Envío y recepción de mensajes en tiempo real
- **Gestión de Conversaciones** - Crear y gestionar conversaciones de chat
- **Historial de Mensajes** - Almacenar y recuperar historial de mensajes
- **Estado en Línea** - Rastrear estado online/offline de usuarios
- **Notificaciones de Mensajes** - Notificaciones de mensajes en tiempo real

### 🔌 Comunicación WebSocket
- **Integración Socket.io** para comunicación bidireccional en tiempo real
- **Gestión de Salas** para conversaciones privadas y grupales
- **Gestión de Conexiones** y reconexión automática
- **Difusión de Mensajes** a múltiples usuarios

### 🔄 Sistema de Colas
- Integración con **RabbitMQ** para procesamiento asíncrono de mensajes
- Productores de mensajes para eventos de chat
- Manejo de conexiones y reconexiones automáticas

### 📊 Monitoreo y Logging
- Integración con **Elasticsearch** para centralización de logs
- Logging estructurado con **Winston**
- Soporte para **Elastic APM** para monitoreo de rendimiento

## Flujo de Trabajo

1. **Conexión**: Los usuarios se conectan vía WebSocket
2. **Autenticación**: Autenticación de usuario y gestión de sesiones
3. **Envío de Mensajes**: Intercambio de mensajes en tiempo real
4. **Almacenamiento de Mensajes**: Los mensajes se almacenan en MongoDB
5. **Publicación de Eventos**: Los eventos de chat se publican en RabbitMQ
6. **Notificación**: Notificaciones en tiempo real a usuarios conectados
7. **Logging**: Registro de actividad en Elasticsearch para monitoreo 