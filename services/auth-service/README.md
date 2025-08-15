# Auth Service

## Description
The **Auth Service** is a microservice responsible for managing user authentication and authorization within the JobApp application. This service handles user registration, login, password management, email verification, and JWT token management.

## Tecnologías Utilizadas / Technologies Used

- **Node.js** with **TypeScript**
- **Express.js** - Web framework
- **MySQL** with **Sequelize** - Database ORM
- **JWT** - JSON Web Tokens for authentication
- **bcryptjs** - Password hashing
- **RabbitMQ** - Message queue system
- **Cloudinary** - File upload and management
- **Elasticsearch** - Logging and search
- **Winston** - Logging system
- **Jest** - Testing framework
- **PM2** - Process manager for production

## Main Features / Características Principales

### 🔐 Authentication & Authorization
The service handles all authentication-related operations:

- **User Registration** (`signup`)
- **User Login** (`signin`)
- **Email Verification** (`verify-email`)
- **Password Reset** (`password`)
- **OTP Verification** (`verify-otp`)
- **Token Refresh** (`refresh-token`)
- **Current User Info** (`current-user`)
- **User Search** (`search`)

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
auth-service/
├── src/
│   ├── app.ts              # Application entry point
│   ├── server.ts           # Express server configuration
│   ├── config.ts           # Service configuration
│   ├── routes.ts           # Route definitions
│   ├── database.ts         # Database connection
│   ├── elasticsearch.ts    # Elasticsearch configuration
│   ├── controllers/        # Request handlers
│   │   ├── signup.ts       # User registration
│   │   ├── signin.ts       # User login
│   │   ├── password.ts     # Password management
│   │   ├── verify-email.ts # Email verification
│   │   └── ...
│   ├── models/             # Database models
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
JWT_TOKEN=<JWT_SECRET_TOKEN>
GATEWAY_JWT_TOKEN=<GATEWAY_JWT_TOKEN>
RABBITMQ_ENDPOINT=<RABBITMQ_URL>
MYSQL_DB=<MYSQL_CONNECTION_STRING>
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

- **MySQL**: For user data storage
- **RabbitMQ**: For sending user events to other services
- **Elasticsearch**: For centralized logging and search
- **Cloudinary**: For file upload and management
- **Shared Library** (`@kevindeveloper95/jobapp-shared`): Shared utilities

## Workflow / Flujo de Trabajo

1. **Registration**: Users register with email and password
2. **Verification**: Email verification process
3. **Authentication**: JWT token generation and validation
4. **Authorization**: Role-based access control
5. **Password Management**: Secure password reset and change
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

# Servicio de Autenticación

## Descripción
El **Servicio de Autenticación** es un microservicio encargado de gestionar la autenticación y autorización de usuarios dentro de la aplicación JobApp. Este servicio maneja el registro de usuarios, inicio de sesión, gestión de contraseñas, verificación de email y gestión de tokens JWT.

## Características Principales

### 🔐 Autenticación y Autorización
El servicio maneja todas las operaciones relacionadas con la autenticación:

- **Registro de Usuarios** (`signup`)
- **Inicio de Sesión** (`signin`)
- **Verificación de Email** (`verify-email`)
- **Restablecimiento de Contraseña** (`password`)
- **Verificación OTP** (`verify-otp`)
- **Renovación de Token** (`refresh-token`)
- **Información del Usuario Actual** (`current-user`)
- **Búsqueda de Usuarios** (`search`)

### 🔄 Sistema de Colas
- Integración con **RabbitMQ** para procesamiento asíncrono de mensajes
- Productores de mensajes para eventos de usuario
- Manejo de conexiones y reconexiones automáticas

### 📊 Monitoreo y Logging
- Integración con **Elasticsearch** para centralización de logs
- Logging estructurado con **Winston**
- Soporte para **Elastic APM** para monitoreo de rendimiento

## Flujo de Trabajo

1. **Registro**: Los usuarios se registran con email y contraseña
2. **Verificación**: Proceso de verificación de email
3. **Autenticación**: Generación y validación de tokens JWT
4. **Autorización**: Control de acceso basado en roles
5. **Gestión de Contraseñas**: Restablecimiento y cambio seguro de contraseñas
6. **Logging**: Registro de actividad en Elasticsearch para monitoreo 