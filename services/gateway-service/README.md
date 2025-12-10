# Gateway Service

> **Note**: For common service documentation (scripts, deployment, development workflow), see [Service README Template](../../docs/SERVICE-README-TEMPLATE.md).

## Description

The **Gateway Service** is the main API gateway and entry point for the JobApp application. This service acts as a reverse proxy, routing requests to appropriate microservices, handling authentication, rate limiting, and providing real-time communication through WebSockets.

## Service-Specific Technologies

- **Socket.io** - Real-time WebSocket communication
- **Redis** - Caching and session management
- **JWT** - JSON Web Tokens for authentication
- **Axios** - HTTP client for service communication

## Main Features

### 🌐 API Gateway
The service routes requests to appropriate microservices:

- **Authentication Routes** - User auth operations
- **User Management** - User profile operations
- **Gig Management** - Job posting operations
- **Order Management** - Order processing
- **Review System** - User reviews and ratings
- **Chat System** - Real-time messaging
- **Health Checks** - Service health monitoring

### 🔌 Real-time Communication
- **WebSocket Support** with Socket.io
- **Redis Adapter** for horizontal scaling
- **Real-time Chat** functionality
- **Live Notifications** system

### 🔐 Authentication & Authorization
- **JWT Token Validation**
- **Request Authentication**
- **Rate Limiting**
- **CORS Management**

## API Endpoints

Base Path: `/api/gateway/v1`

### Authentication
- `POST /auth/signup` - User registration
- `POST /auth/signin` - User login
- `POST /auth/signout` - User logout
- `PUT /auth/verify-email` - Email verification
- `PUT /auth/verify-otp/:otp` - OTP verification
- `PUT /auth/forgot-password` - Request password reset
- `PUT /auth/reset-password/:token` - Reset password
- `PUT /auth/change-password` - Change password
- `GET /auth/refresh-token/:username` - Refresh JWT token
- `GET /auth/currentuser` - Get current user info
- `GET /auth/logged-in-user` - Get logged in users
- `DELETE /auth/logged-in-user/:username` - Remove logged in user

### Buyer
- `GET /buyer/email` - Get buyer by email
- `GET /buyer/username` - Get current buyer username
- `GET /buyer/:username` - Get buyer by username

### Seller
- `GET /seller/id/:sellerId` - Get seller by ID
- `GET /seller/username/:username` - Get seller by username
- `GET /seller/random/:size` - Get random sellers
- `POST /seller/create` - Create seller profile
- `PUT /seller/:sellerId` - Update seller profile

### Gig
- `GET /gig/:gigId` - Get gig by ID
- `GET /gig/seller/:sellerId` - Get seller's gigs
- `GET /gig/seller/pause/:sellerId` - Get seller's paused gigs
- `GET /gig/search/:from/:size/:type` - Search gigs
- `GET /gig/category/:username` - Get gigs by category
- `GET /gig/top/:username` - Get top rated gigs by category
- `GET /gig/similar/:gigId` - Get similar gigs
- `POST /gig/create` - Create new gig
- `PUT /gig/:gigId` - Update gig
- `PUT /gig/active/:gigId` - Activate/deactivate gig
- `DELETE /gig/:gigId/:sellerId` - Delete gig

### Order
- `GET /order/:orderId` - Get order by ID
- `GET /order/seller/:sellerId` - Get seller's orders
- `GET /order/buyer/:buyerId` - Get buyer's orders
- `GET /order/notification/:userTo` - Get order notifications
- `POST /order` - Create new order
- `POST /order/create-payment-intent` - Create Stripe payment intent
- `PUT /order/cancel/:orderId` - Cancel order
- `PUT /order/extension/:orderId` - Request order extension
- `PUT /order/deliver-order/:orderId` - Deliver order
- `PUT /order/approve-order/:orderId` - Approve order
- `PUT /order/gig/:type/:orderId` - Update delivery date
- `PUT /order/notification/mark-as-read` - Mark notification as read

### Review
- `GET /review/gig/:gigId` - Get reviews by gig ID
- `GET /review/seller/:sellerId` - Get reviews by seller ID
- `POST /review` - Create new review

### Message (Chat)
- `GET /message/conversation/:senderUsername/:receiverUsername` - Get conversation
- `GET /message/conversations/:username` - Get conversation list
- `GET /message/:senderUsername/:receiverUsername` - Get messages
- `GET /message/:conversationId` - Get user messages
- `POST /message` - Send message
- `PUT /message/offer` - Send job offer
- `PUT /message/mark-as-read` - Mark message as read
- `PUT /message/mark-multiple-as-read` - Mark multiple messages as read

### Search
- `GET /auth/search/gig/:from/:size/:type` - Search gigs
- `GET /auth/search/gig/:gigId` - Get gig by ID

### Health
- `GET /gateway-health` - Health check endpoint
- `GET /` - Root health check

## Service-Specific Environment Variables

```env
JWT_TOKEN=<JWT_SECRET_TOKEN>
GATEWAY_JWT_TOKEN=<GATEWAY_JWT_TOKEN>
SECRET_KEY_ONE=<SECRET_KEY_1>
SECRET_KEY_TWO=<SECRET_KEY_2>
AUTH_BASE_URL=<AUTH_SERVICE_URL>
USERS_BASE_URL=<USERS_SERVICE_URL>
GIG_BASE_URL=<GIG_SERVICE_URL>
MESSAGE_BASE_URL=<MESSAGE_SERVICE_URL>
ORDER_BASE_URL=<ORDER_SERVICE_URL>
REVIEW_BASE_URL=<REVIEW_SERVICE_URL>
REDIS_HOST=<REDIS_URL>
```

## Integration with Other Services

This microservice integrates with:

- **Auth Service**: For authentication and user management
- **Users Service**: For user profile operations
- **Gig Service**: For job posting management
- **Order Service**: For order processing
- **Review Service**: For user reviews
- **Chat Service**: For real-time messaging
- **Redis**: For caching and session management
- **Elasticsearch**: For centralized logging and search
- **Shared Library** (`@kevindeveloper95/jobapp-shared`): Shared utilities

## Workflow

1. **Request Reception**: Incoming HTTP requests are received
2. **Authentication**: JWT tokens are validated
3. **Routing**: Requests are routed to appropriate microservices
4. **Response Aggregation**: Responses from microservices are aggregated
5. **Real-time Communication**: WebSocket connections are managed
6. **Logging**: All activities are logged in Elasticsearch
