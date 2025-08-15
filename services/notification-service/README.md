# Notification Service

## Description
The **Notification Service** is a microservice responsible for managing all email notifications within the JobApp application. This service processes message queues and sends personalized emails using predefined templates.

## Technologies Used / Tecnologías Utilizadas

- **Node.js** with **TypeScript**
- **Express.js** - Web framework
- **RabbitMQ** - Message queue system
- **Nodemailer** - Email sending
- **Email Templates** - Email template management
- **Elasticsearch** - Logging and search
- **Winston** - Logging system
- **Jest** - Testing framework
- **PM2** - Process manager for production

## Main Features / Características Principales

### 📧 Email Management
The service handles different types of email notifications:

- **Email verification** (`verifyEmail`)
- **Password recovery** (`forgotPassword`)
- **Password change confirmation** (`resetPasswordSuccess`)
- **Job offers** (`offer`)
- **Placed orders** (`orderPlaced`)
- **Order receipts** (`orderReceipt`)
- **Delivered orders** (`orderDelivered`)
- **Order extensions** (`orderExtension`)
- **Extension approvals** (`orderExtensionApproval`)

### 🔄 Queue System
- Integration with **RabbitMQ** for asynchronous message processing
- Email consumer that processes notification queues
- Connection management and automatic reconnection

### 📊 Monitoring and Logging
- Integration with **Elasticsearch** for centralized logging
- Structured logging with **Winston**
- Support for **Elastic APM** for performance monitoring

## Project Structure / Estructura del Proyecto

```
notification-service/
├── src/
│   ├── app.ts              # Application entry point
│   ├── server.ts           # Express server configuration
│   ├── config.ts           # Service configuration
│   ├── routes.ts           # Route definitions
│   ├── helpers.ts          # Helper functions
│   ├── elasticsearch.ts    # Elasticsearch configuration
│   ├── emails/             # Email templates
│   │   ├── verifyEmail/
│   │   ├── forgotPassword/
│   │   ├── orderPlaced/
│   │   └── ...
│   └── queues/             # Queue management
│       ├── connection.ts   # RabbitMQ connection
│       ├── email.consumer.ts # Email consumer
│       └── mail.transport.ts # Email transport configuration
├── tools/                  # Build tools
├── coverage/              # Test coverage reports
├── Dockerfile             # Docker image for production
├── Dockerfile.dev         # Docker image for development
└── package.json           # Dependencies and scripts
```

## Environment Variables / Variables de Entorno

The service requires the following environment variables:

```env
NODE_ENV=development|production
CLIENT_URL=<CLIENT_URL>
SENDER_EMAIL=<SENDER_EMAIL>
SENDER_EMAIL_PASSWORD=<EMAIL_PASSWORD>
RABBITMQ_ENDPOINT=<RABBITMQ_URL>
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
npm run build        # Compile TypeScript and prepare assets
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

- **RabbitMQ**: To receive notification messages from other services
- **Elasticsearch**: For centralized logging and search
- **Email Provider**: For actual email sending
- **Shared Library** (`@kevindeveloper95/jobapp-shared`): Shared utilities

## Workflow / Flujo de Trabajo

1. **Reception**: The service receives messages from other microservices through RabbitMQ
2. **Processing**: The email consumer processes messages from the queue
3. **Templating**: The appropriate email template is selected and processed
4. **Sending**: The email is sent using Nodemailer
5. **Logging**: Activity is logged in Elasticsearch for monitoring

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

# Notification Service

## Descripción
El **Notification Service** es un microservicio encargado de gestionar todas las notificaciones por correo electrónico dentro de la aplicación JobApp. Este servicio procesa colas de mensajes y envía correos electrónicos personalizados utilizando plantillas predefinidas.

## Tecnologías Utilizadas

- **Node.js** con **TypeScript**
- **Express.js** - Framework web
- **RabbitMQ** - Sistema de colas de mensajes
- **Nodemailer** - Envío de correos electrónicos
- **Email Templates** - Gestión de plantillas de correo
- **Elasticsearch** - Logging y búsqueda
- **Winston** - Sistema de logging
- **Jest** - Testing framework
- **PM2** - Process manager para producción

## Características Principales

### 📧 Gestión de Correos Electrónicos
El servicio maneja diferentes tipos de notificaciones por correo:

- **Verificación de email** (`verifyEmail`)
- **Recuperación de contraseña** (`forgotPassword`)
- **Confirmación de cambio de contraseña** (`resetPasswordSuccess`)
- **Ofertas de trabajo** (`offer`)
- **Órdenes realizadas** (`orderPlaced`)
- **Recibos de órdenes** (`orderReceipt`)
- **Órdenes entregadas** (`orderDelivered`)
- **Extensiones de órdenes** (`orderExtension`)
- **Aprobación de extensiones** (`orderExtensionApproval`)

### 🔄 Sistema de Colas
- Integración con **RabbitMQ** para procesamiento asíncrono de mensajes
- Consumer de emails que procesa las colas de notificaciones
- Manejo de conexiones y reconexiones automáticas

### 📊 Monitoreo y Logging
- Integración con **Elasticsearch** para centralización de logs
- Logging estructurado con **Winston**
- Soporte para **Elastic APM** para monitoreo de rendimiento

## Estructura del Proyecto

```
notification-service/
├── src/
│   ├── app.ts              # Punto de entrada de la aplicación
│   ├── server.ts           # Configuración del servidor Express
│   ├── config.ts           # Configuración del servicio
│   ├── routes.ts           # Definición de rutas
│   ├── helpers.ts          # Funciones auxiliares
│   ├── elasticsearch.ts    # Configuración de Elasticsearch
│   ├── emails/             # Plantillas de correo electrónico
│   │   ├── verifyEmail/
│   │   ├── forgotPassword/
│   │   ├── orderPlaced/
│   │   └── ...
│   └── queues/             # Gestión de colas
│       ├── connection.ts   # Conexión a RabbitMQ
│       ├── email.consumer.ts # Consumer de emails
│       └── mail.transport.ts # Configuración de transporte de correo
├── tools/                  # Herramientas de build
├── coverage/              # Reportes de cobertura de tests
├── Dockerfile             # Imagen Docker para producción
├── Dockerfile.dev         # Imagen Docker para desarrollo
└── package.json           # Dependencias y scripts
```

## Variables de Entorno

El servicio requiere las siguientes variables de entorno:

```env
NODE_ENV=development|production
CLIENT_URL=<URL_DEL_CLIENTE>
SENDER_EMAIL=<EMAIL_REMITENTE>
SENDER_EMAIL_PASSWORD=<PASSWORD_EMAIL>
RABBITMQ_ENDPOINT=<URL_RABBITMQ>
ELASTIC_SEARCH_URL=<URL_ELASTICSEARCH>
ENABLE_APM=0|1
ELASTIC_APM_SERVER_URL=<URL_APM>
ELASTIC_APM_SECRET_TOKEN=<TOKEN_APM>
```

## Scripts Disponibles

### Desarrollo
```bash
npm run dev          # Inicia el servidor en modo desarrollo con hot reload
npm run lint:check   # Verifica el código con ESLint
npm run lint:fix     # Corrige automáticamente errores de linting
npm run prettier:check # Verifica formato del código
npm run prettier:fix   # Formatea el código automáticamente
```

### Producción
```bash
npm run build        # Compila TypeScript y prepara assets
npm start           # Inicia el servicio con PM2 (5 instancias)

npm stop            # Detiene todas las instancias PM2
npm run delete      # Elimina todas las instancias PM2
```

### Testing
```bash
npm test            # Ejecuta todos los tests con cobertura
```

## Despliegue

### Docker
El servicio incluye configuración para Docker:

- **Dockerfile**: Para producción
- **Dockerfile.dev**: Para desarrollo

### PM2
En producción, el servicio se ejecuta con PM2 en modo cluster (5 instancias) para alta disponibilidad.

## Integración con Otros Servicios

Este microservicio se integra con:

- **RabbitMQ**: Para recibir mensajes de notificación de otros servicios
- **Elasticsearch**: Para logging centralizado y búsqueda
- **Email Provider**: Para envío efectivo de correos electrónicos
- **Shared Library** (`@kevindeveloper95/jobapp-shared`): Utilidades compartidas

## Flujo de Trabajo

1. **Recepción**: El servicio recibe mensajes de otros microservicios a través de RabbitMQ
2. **Procesamiento**: El consumer de emails procesa los mensajes de la cola
3. **Templating**: Se selecciona y procesa la plantilla de correo apropiada
4. **Envío**: Se envía el correo electrónico utilizando Nodemailer
5. **Logging**: Se registra la actividad en Elasticsearch para monitoreo

## Desarrollo

Para contribuir al desarrollo del servicio:

1. Instalar dependencias: `npm install`
2. Configurar variables de entorno
3. Ejecutar en modo desarrollo: `npm run dev`
4. Ejecutar tests: `npm test`
5. Verificar linting: `npm run lint:check`

## Versionado

Versión actual: **1.0.0**

El servicio utiliza versionado semántico para control de releases.
