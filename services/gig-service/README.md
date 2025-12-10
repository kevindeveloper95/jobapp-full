# Gig Service

> **Note**: For common service documentation (scripts, deployment, development workflow), see [Service README Template](../../docs/SERVICE-README-TEMPLATE.md).

## Description

The **Gig Service** is a microservice responsible for managing job postings and gig-related operations within the JobApp application. This service handles gig creation, management, search functionality, and caching using Redis for improved performance.

## Service-Specific Technologies

- **MongoDB** with **Mongoose** - Database ORM
- **Redis** - Caching and session management
- **Cloudinary** - File upload and management

## Main Features

### 💼 Gig Management
The service handles all gig-related operations:

- **Gig Creation** - Create new job postings
- **Gig Updates** - Modify existing gigs
- **Gig Deletion** - Remove gigs from the platform
- **Gig Search** - Advanced search functionality
- **Gig Caching** - Redis-based caching for performance

### ⚡ Performance Optimization
- **Redis Caching** for frequently accessed gigs
- **Search Optimization** with Elasticsearch integration
- **Response Time Optimization** through caching strategies

## API Endpoints

Base Path: `/api/v1/gig`

### Gig Routes
- `GET /:gigId` - Get gig by ID
- `GET /seller/:sellerId` - Get seller's gigs
- `GET /seller/pause/:sellerId` - Get seller's paused gigs
- `GET /search/:from/:size/:type` - Search gigs
- `GET /category/:username` - Get gigs by category
- `GET /top/:username` - Get top rated gigs by category
- `GET /similar/:gigId` - Get similar gigs
- `POST /create` - Create new gig
- `PUT /:gigId` - Update gig
- `PUT /active/:gigId` - Activate/deactivate gig
- `PUT /seed/:count` - Seed gig data (development)
- `DELETE /:gigId/:sellerId` - Delete gig

### Health
- `GET /` - Health check endpoint

## Database Models

- **Gig Schema** (MongoDB) - Gig data including title, description, price, category, seller info, images

## Service-Specific Environment Variables

```env
MONGODB_URL=<MONGODB_CONNECTION_STRING>
REDIS_HOST=<REDIS_URL>
CLOUD_NAME=<CLOUDINARY_CLOUD_NAME>
CLOUD_API_KEY=<CLOUDINARY_API_KEY>
CLOUD_API_SECRET=<CLOUDINARY_API_SECRET>
```

## Integration with Other Services

This microservice integrates with:

- **MongoDB**: For gig data storage
- **Redis**: For caching and performance optimization
- **RabbitMQ**: For sending gig events to other services
- **Elasticsearch**: For centralized logging and search
- **Cloudinary**: For file upload and management
- **Shared Library** (`@kevindeveloper95/jobapp-shared`): Shared utilities

## Workflow

1. **Gig Creation**: Users create new job postings
2. **Validation**: Input validation and sanitization
3. **Storage**: Gig data is stored in MongoDB
4. **Caching**: Frequently accessed gigs are cached in Redis
5. **Search**: Advanced search functionality with Elasticsearch
6. **Event Publishing**: Gig events are published to RabbitMQ
7. **Logging**: Activity logging in Elasticsearch for monitoring
