# Gig Service

## Description
The **Gig Service** is a microservice responsible for managing job postings and gig-related operations within the JobApp application. This service handles gig creation, management, search functionality, and caching using Redis for improved performance.

## Technologies Used / Tecnologías Utilizadas

- **Node.js** with **TypeScript**
- **Express.js** - Web framework
- **MongoDB** with **Mongoose** - Database ORM
- **Redis** - Caching and session management
- **RabbitMQ** - Message queue system
- **Cloudinary** - File upload and management
- **Elasticsearch** - Logging and search
- **Winston** - Logging system
- **Jest** - Testing framework
- **PM2** - Process manager for production

## Main Features / Características Principales

### 💼 Gig Management
The service handles all gig-related operations:

- **Gig Creation** - Create new job postings
- **Gig Updates** - Modify existing gigs
- **Gig Deletion** - Remove gigs from the platform
- **Gig Search** - Advanced search functionality
- **Gig Caching** - Redis-based caching for performance

### 🔄 Queue System
- Integration with **RabbitMQ** for asynchronous message processing
- Message producers for gig events
- Connection management and automatic reconnection

### 📊 Monitoring and Logging
- Integration with **Elasticsearch** for centralized logging
- Structured logging with **Winston**
- Support for **Elastic APM** for performance monitoring

### ⚡ Performance Optimization
- **Redis Caching** for frequently accessed gigs
- **Search Optimization** with Elasticsearch integration
- **Response Time Optimization** through caching strategies

## Project Structure / Estructura del Proyecto

```
gig-service/
├── src/
│   ├── app.ts              # Application entry point
│   ├── server.ts           # Express server configuration
│   ├── config.ts           # Service configuration
│   ├── routes.ts           # Route definitions
│   ├── database.ts         # Database connection
│   ├── elasticsearch.ts    # Elasticsearch configuration
│   ├── controllers/        # Request handlers
│   │   ├── create.ts       # Gig creation
│   │   ├── get.ts          # Gig retrieval
│   │   ├── delete.ts       # Gig deletion
│   │   └── ...
│   ├── models/             # Database models
│   │   └── gig.schema.ts   # Gig model
│   ├── services/           # Business logic
│   │   ├── gig.service.ts  # Gig business logic
│   │   └── search.service.ts # Search functionality
│   ├── routes/             # Route definitions
│   ├── schemes/            # Validation schemas
│   ├── queues/             # Queue management
│   └── redis/              # Redis configuration
│       ├── gig.cache.ts    # Gig caching logic
│       └── redis.connection.ts # Redis connection
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
CLOUD_NAME=<CLOUDINARY_CLOUD_NAME>
CLOUD_API_KEY=<CLOUDINARY_API_KEY>
CLOUD_API_SECRET=<CLOUDINARY_API_SECRET>
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

- **MongoDB**: For gig data storage
- **Redis**: For caching and performance optimization
- **RabbitMQ**: For sending gig events to other services
- **Elasticsearch**: For centralized logging and search
- **Cloudinary**: For file upload and management
- **Shared Library** (`@kevindeveloper95/jobapp-shared`): Shared utilities

## Workflow / Flujo de Trabajo

1. **Gig Creation**: Users create new job postings
2. **Validation**: Input validation and sanitization
3. **Storage**: Gig data is stored in MongoDB
4. **Caching**: Frequently accessed gigs are cached in Redis
5. **Search**: Advanced search functionality with Elasticsearch
6. **Event Publishing**: Gig events are published to RabbitMQ
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

# Servicio de Gigs

## Descripción
El **Servicio de Gigs** es un microservicio encargado de gestionar las publicaciones de trabajos y operaciones relacionadas con gigs dentro de la aplicación JobApp. Este servicio maneja la creación de gigs, gestión, funcionalidad de búsqueda y caché usando Redis para mejorar el rendimiento.

## Características Principales

### 💼 Gestión de Gigs
El servicio maneja todas las operaciones relacionadas con gigs:

- **Creación de Gigs** - Crear nuevas publicaciones de trabajo
- **Actualizaciones de Gigs** - Modificar gigs existentes
- **Eliminación de Gigs** - Remover gigs de la plataforma
- **Búsqueda de Gigs** - Funcionalidad de búsqueda avanzada
- **Caché de Gigs** - Caché basado en Redis para rendimiento

### 🔄 Sistema de Colas
- Integración con **RabbitMQ** para procesamiento asíncrono de mensajes
- Productores de mensajes para eventos de gigs
- Manejo de conexiones y reconexiones automáticas

### 📊 Monitoreo y Logging
- Integración con **Elasticsearch** para centralización de logs
- Logging estructurado con **Winston**
- Soporte para **Elastic APM** para monitoreo de rendimiento

### ⚡ Optimización de Rendimiento
- **Caché Redis** para gigs accedidos frecuentemente
- **Optimización de Búsqueda** con integración de Elasticsearch
- **Optimización de Tiempo de Respuesta** a través de estrategias de caché

## Flujo de Trabajo

1. **Creación de Gigs**: Los usuarios crean nuevas publicaciones de trabajo
2. **Validación**: Validación y sanitización de entrada
3. **Almacenamiento**: Los datos del gig se almacenan en MongoDB
4. **Caché**: Los gigs accedidos frecuentemente se almacenan en caché en Redis
5. **Búsqueda**: Funcionalidad de búsqueda avanzada con Elasticsearch
6. **Publicación de Eventos**: Los eventos de gigs se publican en RabbitMQ
7. **Logging**: Registro de actividad en Elasticsearch para monitoreo 