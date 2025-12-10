# Order Service

> **Note**: For common service documentation (scripts, deployment, development workflow), see [Service README Template](../../docs/SERVICE-README-TEMPLATE.md).

## Description

The **Order Service** is a microservice responsible for managing order processing and payment operations within the JobApp application. This service handles order creation, payment processing with Stripe, order status management, and notification systems.

## Service-Specific Technologies

- **MongoDB** with **Mongoose** - Database ORM
- **Stripe** - Payment processing
- **Socket.io** - Real-time communication
- **Redis** - Caching and session management

## Main Features

### 🛒 Order Management
The service handles all order-related operations:

- **Order Creation** - Create new orders
- **Payment Processing** - Stripe integration for payments
- **Order Status Management** - Track order lifecycle
- **Order Notifications** - Real-time order updates
- **Order History** - User order tracking

### 💳 Payment Processing
- **Stripe Integration** for secure payment processing
- **Payment Validation** and verification
- **Refund Management** for order cancellations
- **Payment Status Tracking** in real-time

## API Endpoints

Base Path: `/api/v1/order`

### Order Routes
- `GET /:orderId` - Get order by ID
- `GET /seller/:sellerId` - Get seller's orders
- `GET /buyer/:buyerId` - Get buyer's orders
- `GET /notification/:userTo` - Get order notifications
- `POST /` - Create new order
- `POST /create-payment-intent` - Create Stripe payment intent
- `PUT /cancel/:orderId` - Cancel order
- `PUT /extension/:orderId` - Request order extension
- `PUT /deliver-order/:orderId` - Deliver order
- `PUT /approve-order/:orderId` - Approve order
- `PUT /gig/:type/:orderId` - Update delivery date
- `PUT /notification/mark-as-read` - Mark notification as read

### Health
- `GET /` - Health check endpoint

## Database Models

- **Order Schema** (MongoDB) - Order data including buyer, seller, gig, price, status, payment info
- **Notification Schema** (MongoDB) - Order notifications and updates

## Service-Specific Environment Variables

```env
MONGODB_URL=<MONGODB_CONNECTION_STRING>
REDIS_HOST=<REDIS_URL>
STRIPE_SECRET_KEY=<STRIPE_SECRET_KEY>
STRIPE_WEBHOOK_SECRET=<STRIPE_WEBHOOK_SECRET>
```

## Integration with Other Services

This microservice integrates with:

- **MongoDB**: For order data storage
- **Stripe**: For payment processing
- **RabbitMQ**: For sending order events to other services
- **Redis**: For caching and session management
- **Socket.io**: For real-time order updates
- **Elasticsearch**: For centralized logging and search
- **Shared Library** (`@kevindeveloper95/jobapp-shared`): Shared utilities

## Workflow

1. **Order Creation**: Users create new orders
2. **Payment Processing**: Stripe handles payment validation
3. **Order Validation**: Order details are validated
4. **Status Management**: Order status is tracked throughout lifecycle
5. **Notification**: Real-time updates are sent to users
6. **Event Publishing**: Order events are published to RabbitMQ
7. **Logging**: Activity logging in Elasticsearch for monitoring
