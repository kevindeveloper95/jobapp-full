# Service README Template

> **Note**: This template contains common documentation shared across all microservices. Each service README should reference this template and only document service-specific information.

## Common Technologies

All microservices use the following technologies:

- **Node.js** with **TypeScript**
- **Express.js** - Web framework
- **RabbitMQ** - Message queue system
- **Elasticsearch** - Logging and search
- **Winston** - Logging system
- **Jest** - Testing framework
- **PM2** - Process manager for production

## Common Project Structure

```
[service-name]/
├── src/
│   ├── app.ts              # Application entry point
│   ├── server.ts           # Express server configuration
│   ├── config.ts           # Service configuration
│   ├── routes.ts           # Route definitions
│   ├── database.ts         # Database connection
│   ├── elasticsearch.ts    # Elasticsearch configuration
│   ├── controllers/        # Request handlers
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

## Common Environment Variables

All services require these environment variables:

```env
NODE_ENV=development|production
RABBITMQ_ENDPOINT=<RABBITMQ_URL>
API_GATEWAY_URL=<GATEWAY_URL>
CLIENT_URL=<CLIENT_URL>
ELASTIC_SEARCH_URL=<ELASTICSEARCH_URL>
ENABLE_APM=0|1
ELASTIC_APM_SERVER_URL=<APM_URL>
ELASTIC_APM_SECRET_TOKEN=<APM_TOKEN>
```

## Common Scripts

### Development
```bash
npm run dev          # Start server in development mode with hot reload
npm run lint:check   # Check code with ESLint
npm run lint:fix     # Automatically fix linting errors
npm run prettier:check # Check code formatting
npm run prettier:fix   # Format code automatically
```

### Production
```bash
npm run build        # Compile TypeScript
npm start           # Start service with PM2 (5 instances)

npm stop            # Stop all PM2 instances
npm run delete      # Delete all PM2 instances
```

### Testing
```bash
npm test            # Run all tests with coverage
```

## Common Deployment

### Docker
All services include Docker configuration:

- **Dockerfile**: For production
- **Dockerfile.dev**: For development

### PM2
In production, all services run with PM2 in cluster mode (5 instances) for high availability.

## Common Development Workflow

To contribute to any service development:

1. Install dependencies: `npm install`
2. Configure environment variables
3. Run in development mode: `npm run dev`
4. Run tests: `npm test`
5. Check linting: `npm run lint:check`

## Common Versioning

All services use semantic versioning for release control.

---

**For service-specific documentation (API endpoints, database models, unique features), see the individual service README files.**
