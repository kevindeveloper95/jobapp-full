# Review Service

> **Note**: For common service documentation (scripts, deployment, development workflow), see [Service README Template](../../docs/SERVICE-README-TEMPLATE.md).

## Description

The **Review Service** is a microservice responsible for managing user reviews and ratings within the JobApp application. This service handles review creation, rating management, and review analytics using both MongoDB and PostgreSQL for different data requirements.

## Service-Specific Technologies

- **MongoDB** with **Mongoose** - Document database
- **PostgreSQL** with **pg** - Relational database

## Main Features

### ⭐ Review Management
The service handles all review-related operations:

- **Review Creation** - Create new reviews and ratings
- **Review Retrieval** - Get reviews for users and gigs
- **Rating Calculation** - Calculate average ratings
- **Review Analytics** - Review statistics and insights
- **Review Validation** - Validate review submissions

### 🗄️ Dual Database Architecture
- **MongoDB**: For review document storage
- **PostgreSQL**: For relational data and analytics
- **Data Synchronization** between databases

## API Endpoints

Base Path: `/api/v1/review`

### Review Routes
- `GET /gig/:gigId` - Get reviews by gig ID
- `GET /seller/:sellerId` - Get reviews by seller ID
- `POST /` - Create new review

### Health
- `GET /` - Health check endpoint

## Database Models

- **Review Schema** (MongoDB) - Review documents with rating, comment, reviewer info
- **Review Analytics** (PostgreSQL) - Relational data for analytics, aggregated ratings, statistics

## Service-Specific Environment Variables

```env
MONGODB_URL=<MONGODB_CONNECTION_STRING>
POSTGRES_URL=<POSTGRES_CONNECTION_STRING>
```

## Integration with Other Services

This microservice integrates with:

- **MongoDB**: For review document storage
- **PostgreSQL**: For relational data and analytics
- **RabbitMQ**: For sending review events to other services
- **Elasticsearch**: For centralized logging and search
- **Shared Library** (`@kevindeveloper95/jobapp-shared`): Shared utilities

## Workflow

1. **Review Submission**: Users submit reviews and ratings
2. **Validation**: Review data is validated and sanitized
3. **Storage**: Reviews are stored in MongoDB, analytics in PostgreSQL
4. **Rating Calculation**: Average ratings are calculated and updated
5. **Event Publishing**: Review events are published to RabbitMQ
6. **Analytics**: Review statistics are generated and stored
7. **Logging**: Activity logging in Elasticsearch for monitoring
