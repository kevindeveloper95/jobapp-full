# Review Service

## Description
The **Review Service** is a microservice responsible for managing user reviews and ratings within the JobApp application. This service handles review creation, rating management, and review analytics using both MongoDB and PostgreSQL for different data requirements.

## Technologies Used / Tecnologías Utilizadas

- **Node.js** with **TypeScript**
- **Express.js** - Web framework
- **MongoDB** with **Mongoose** - Document database
- **PostgreSQL** with **pg** - Relational database
- **RabbitMQ** - Message queue system
- **Elasticsearch** - Logging and search
- **Winston** - Logging system
- **Jest** - Testing framework
- **PM2** - Process manager for production

## Main Features / Características Principales

### ⭐ Review Management
The service handles all review-related operations:

- **Review Creation** - Create new reviews and ratings
- **Review Retrieval** - Get reviews for users and gigs
- **Rating Calculation** - Calculate average ratings
- **Review Analytics** - Review statistics and insights
- **Review Validation** - Validate review submissions

### 🔄 Queue System
- Integration with **RabbitMQ** for asynchronous message processing
- Message producers for review events
- Connection management and automatic reconnection

### 📊 Monitoring and Logging
- Integration with **Elasticsearch** for centralized logging
- Structured logging with **Winston**
- Support for **Elastic APM** for performance monitoring

### 🗄️ Dual Database Architecture
- **MongoDB**: For review document storage
- **PostgreSQL**: For relational data and analytics
- **Data Synchronization** between databases

## Project Structure / Estructura del Proyecto

```
review-service/
├── src/
│   ├── app.ts              # Application entry point
│   ├── server.ts           # Express server configuration
│   ├── config.ts           # Service configuration
│   ├── routes.ts           # Route definitions
│   ├── database.ts         # Database connections
│   ├── elasticsearch.ts    # Elasticsearch configuration
│   ├── controllers/        # Request handlers
│   │   ├── create.ts       # Review creation
│   │   ├── get.ts          # Review retrieval
│   │   └── health.ts       # Health check controller
│   ├── services/           # Business logic
│   │   └── review.service.ts # Review business logic
│   ├── routes/             # Route definitions
│   └── queues/             # Queue management
│       ├── connection.ts   # RabbitMQ connection
│       └── review.producer.ts # Review producer
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
POSTGRES_URL=<POSTGRES_CONNECTION_STRING>
RABBITMQ_ENDPOINT=<RABBITMQ_URL>
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

- **MongoDB**: For review document storage
- **PostgreSQL**: For relational data and analytics
- **RabbitMQ**: For sending review events to other services
- **Elasticsearch**: For centralized logging and search
- **Shared Library** (`@kevindeveloper95/jobapp-shared`): Shared utilities

## Workflow / Flujo de Trabajo

1. **Review Submission**: Users submit reviews and ratings
2. **Validation**: Review data is validated and sanitized
3. **Storage**: Reviews are stored in MongoDB, analytics in PostgreSQL
4. **Rating Calculation**: Average ratings are calculated and updated
5. **Event Publishing**: Review events are published to RabbitMQ
6. **Analytics**: Review statistics are generated and stored
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

# Servicio de Reseñas

## Descripción
El **Servicio de Reseñas** es un microservicio encargado de gestionar las reseñas y calificaciones de usuarios dentro de la aplicación JobApp. Este servicio maneja la creación de reseñas, gestión de calificaciones y análisis de reseñas usando tanto MongoDB como PostgreSQL para diferentes requerimientos de datos.

## Características Principales

### ⭐ Gestión de Reseñas
El servicio maneja todas las operaciones relacionadas con reseñas:

- **Creación de Reseñas** - Crear nuevas reseñas y calificaciones
- **Recuperación de Reseñas** - Obtener reseñas para usuarios y gigs
- **Cálculo de Calificaciones** - Calcular calificaciones promedio
- **Análisis de Reseñas** - Estadísticas e insights de reseñas
- **Validación de Reseñas** - Validar envíos de reseñas

### 🔄 Sistema de Colas
- Integración con **RabbitMQ** para procesamiento asíncrono de mensajes
- Productores de mensajes para eventos de reseñas
- Manejo de conexiones y reconexiones automáticas

### 📊 Monitoreo y Logging
- Integración con **Elasticsearch** para centralización de logs
- Logging estructurado con **Winston**
- Soporte para **Elastic APM** para monitoreo de rendimiento

### 🗄️ Arquitectura de Base de Datos Dual
- **MongoDB**: Para almacenamiento de documentos de reseñas
- **PostgreSQL**: Para datos relacionales y análisis
- **Sincronización de Datos** entre bases de datos

## Flujo de Trabajo

1. **Envío de Reseñas**: Los usuarios envían reseñas y calificaciones
2. **Validación**: Los datos de reseñas son validados y sanitizados
3. **Almacenamiento**: Las reseñas se almacenan en MongoDB, análisis en PostgreSQL
4. **Cálculo de Calificaciones**: Las calificaciones promedio se calculan y actualizan
5. **Publicación de Eventos**: Los eventos de reseñas se publican en RabbitMQ
6. **Análisis**: Se generan y almacenan estadísticas de reseñas
7. **Logging**: Registro de actividad en Elasticsearch para monitoreo 