# Auth Service

> **Note**: For common service documentation (scripts, deployment, development workflow), see [Service README Template](../../docs/SERVICE-README-TEMPLATE.md).

## Description

The **Auth Service** is a microservice responsible for managing user authentication and authorization within the JobApp application. This service handles user registration, login, password management, email verification, and JWT token management.

## Service-Specific Technologies

- **MySQL** with **Sequelize** - Database ORM
- **JWT** - JSON Web Tokens for authentication
- **bcryptjs** - Password hashing
- **Cloudinary** - File upload and management

## Main Features

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

## API Endpoints

Base Path: `/api/v1/auth`

### Authentication Routes
- `POST /signup` - User registration
- `POST /signin` - User login
- `PUT /verify-email` - Email verification
- `PUT /verify-otp/:otp` - OTP verification
- `PUT /forgot-password` - Request password reset
- `PUT /reset-password/:token` - Reset password
- `PUT /change-password` - Change password

### Current User Routes
- `GET /current-user` - Get current user information

### Search Routes
- `GET /search` - Search users

### Health
- `GET /` - Health check endpoint

## Database Models

- **User Model** (MySQL) - Stores user authentication data, email, password hash, verification status

## Service-Specific Environment Variables

```env
JWT_TOKEN=<JWT_SECRET_TOKEN>
GATEWAY_JWT_TOKEN=<GATEWAY_JWT_TOKEN>
MYSQL_DB=<MYSQL_CONNECTION_STRING>
CLOUD_NAME=<CLOUDINARY_CLOUD_NAME>
CLOUD_API_KEY=<CLOUDINARY_API_KEY>
CLOUD_API_SECRET=<CLOUDINARY_API_SECRET>
```

## Integration with Other Services

This microservice integrates with:

- **MySQL**: For user data storage
- **RabbitMQ**: For sending user events to other services
- **Elasticsearch**: For centralized logging and search
- **Cloudinary**: For file upload and management
- **Shared Library** (`@kevindeveloper95/jobapp-shared`): Shared utilities

## Workflow

1. **Registration**: Users register with email and password
2. **Verification**: Email verification process
3. **Authentication**: JWT token generation and validation
4. **Authorization**: Role-based access control
5. **Password Management**: Secure password reset and change
6. **Logging**: Activity logging in Elasticsearch for monitoring
