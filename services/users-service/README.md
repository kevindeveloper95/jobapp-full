# Users Service

> **Note**: For common service documentation (scripts, deployment, development workflow), see [Service README Template](../../docs/SERVICE-README-TEMPLATE.md).

## Description

The **Users Service** is a microservice responsible for managing user profiles and user-related data within the JobApp application. This service handles user profile management, buyer and seller operations, and user data storage using MongoDB.

## Service-Specific Technologies

- **MongoDB** with **Mongoose** - Database ORM
- **Cloudinary** - File upload and management
- **bcryptjs** - Password hashing

## Main Features

### 👥 User Profile Management
The service handles all user profile operations:

- **Buyer Profile Management** - Buyer-specific operations
- **Seller Profile Management** - Seller-specific operations
- **Profile Updates** - User profile modifications
- **Avatar Management** - Profile picture handling
- **User Search** - User discovery functionality

## API Endpoints

Base Path: `/api/v1/buyer` and `/api/v1/seller`

### Buyer Routes
- `GET /email` - Get buyer by email
- `GET /username` - Get current buyer username
- `GET /:username` - Get buyer by username

### Seller Routes
- `GET /id/:sellerId` - Get seller by ID
- `GET /username/:username` - Get seller by username
- `GET /random/:size` - Get random sellers
- `POST /create` - Create seller profile
- `PUT /:sellerId` - Update seller profile
- `PUT /seed/:count` - Seed seller data (development)

### Health
- `GET /` - Health check endpoint

## Database Models

- **Buyer Schema** (MongoDB) - Buyer profile data, preferences, purchase history
- **Seller Schema** (MongoDB) - Seller profile data, skills, ratings, gigs

## Service-Specific Environment Variables

```env
MONGODB_URL=<MONGODB_CONNECTION_STRING>
CLOUD_NAME=<CLOUDINARY_CLOUD_NAME>
CLOUD_API_KEY=<CLOUDINARY_API_KEY>
CLOUD_API_SECRET=<CLOUDINARY_API_SECRET>
```

## Integration with Other Services

This microservice integrates with:

- **MongoDB**: For user data storage
- **RabbitMQ**: For sending user events to other services
- **Elasticsearch**: For centralized logging and search
- **Cloudinary**: For file upload and management
- **Shared Library** (`@kevindeveloper95/jobapp-shared`): Shared utilities

## Workflow

1. **Profile Creation**: User profiles are created during registration
2. **Profile Management**: Users can update their profiles and avatars
3. **Role Management**: Different operations for buyers and sellers
4. **Data Validation**: Input validation and sanitization
5. **File Upload**: Avatar and document management
6. **Logging**: Activity logging in Elasticsearch for monitoring
