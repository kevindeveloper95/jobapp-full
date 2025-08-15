# Users Service

## Description
The **Users Service** is a microservice responsible for managing user profiles and user-related data within the JobApp application. This service handles user profile management, buyer and seller operations, and user data storage using MongoDB.

## Technologies Used / Tecnologías Utilizadas

- **Node.js** with **TypeScript**
- **Express.js** - Web framework
- **MongoDB** with **Mongoose** - Database ORM
- **RabbitMQ** - Message queue system
- **Cloudinary** - File upload and management
- **bcryptjs** - Password hashing
- **Elasticsearch** - Logging and search
- **Winston** - Logging system
- **Jest** - Testing framework
- **PM2** - Process manager for production

## Main Features / Características Principales

### 👥 User Profile Management
The service handles all user profile operations:

- **Buyer Profile Management** - Buyer-specific operations
- **Seller Profile Management** - Seller-specific operations
- **Profile Updates** - User profile modifications
- **Avatar Management** - Profile picture handling
- **User Search** - User discovery functionality

### 🔄 Queue System
- Integration with **RabbitMQ** for asynchronous message processing
- Message producers for user events
- Connection management and automatic reconnection

### 📊 Monitoring and Logging
- Integration with **Elasticsearch** for centralized logging
- Structured logging with **Winston**
- Support for **Elastic APM** for performance monitoring

## Project Structure / Estructura del Proyecto

```
users-service/
├── src/
│   ├── app.ts              # Application entry point
│   ├── server.ts           # Express server configuration
│   ├── config.ts           # Service configuration
│   ├── routes.ts           # Route definitions
│   ├── database.ts         # Database connection
│   ├── elasticsearch.ts    # Elasticsearch configuration
│   ├── controllers/        # Request handlers
│   │   ├── buyer/          # Buyer-specific controllers
│   │   ├── seller/         # Seller-specific controllers
│   │   └── health.ts       # Health check controller
│   ├── models/             # Database models
│   │   ├── buyer.schema.ts # Buyer model
│   │   └── seller.schema.ts # Seller model
│   ├── services/           # Business logic
│   ├── routes/             # Route definitions
│   ├── schemes/            # Validation schemas
│   └── queues/             # Queue management
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

- **MongoDB**: For user data storage
- **RabbitMQ**: For sending user events to other services
- **Elasticsearch**: For centralized logging and search
- **Cloudinary**: For file upload and management
- **Shared Library** (`@kevindeveloper95/jobapp-shared`): Shared utilities

## Workflow / Flujo de Trabajo

1. **Profile Creation**: User profiles are created during registration
2. **Profile Management**: Users can update their profiles and avatars
3. **Role Management**: Different operations for buyers and sellers
4. **Data Validation**: Input validation and sanitization
5. **File Upload**: Avatar and document management
6. **Logging**: Activity logging in Elasticsearch for monitoring

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

# Servicio de Usuarios

## Descripción
El **Servicio de Usuarios** es un microservicio encargado de gestionar los perfiles de usuario y datos relacionados con usuarios dentro de la aplicación JobApp. Este servicio maneja la gestión de perfiles de usuario, operaciones de compradores y vendedores, y almacenamiento de datos de usuario usando MongoDB.

## Características Principales

### 👥 Gestión de Perfiles de Usuario
El servicio maneja todas las operaciones de perfil de usuario:

- **Gestión de Perfil de Comprador** - Operaciones específicas de compradores
- **Gestión de Perfil de Vendedor** - Operaciones específicas de vendedores
- **Actualizaciones de Perfil** - Modificaciones de perfil de usuario
- **Gestión de Avatar** - Manejo de fotos de perfil
- **Búsqueda de Usuarios** - Funcionalidad de descubrimiento de usuarios

### 🔄 Sistema de Colas
- Integración con **RabbitMQ** para procesamiento asíncrono de mensajes
- Productores de mensajes para eventos de usuario
- Manejo de conexiones y reconexiones automáticas

### 📊 Monitoreo y Logging
- Integración con **Elasticsearch** para centralización de logs
- Logging estructurado con **Winston**
- Soporte para **Elastic APM** para monitoreo de rendimiento

## Flujo de Trabajo

1. **Creación de Perfil**: Los perfiles de usuario se crean durante el registro
2. **Gestión de Perfil**: Los usuarios pueden actualizar sus perfiles y avatares
3. **Gestión de Roles**: Diferentes operaciones para compradores y vendedores
4. **Validación de Datos**: Validación y sanitización de entrada
5. **Carga de Archivos**: Gestión de avatares y documentos
6. **Logging**: Registro de actividad en Elasticsearch para monitoreo 