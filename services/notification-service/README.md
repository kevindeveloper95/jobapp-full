# Notification Service

> **Note**: For common service documentation (scripts, deployment, development workflow), see [Service README Template](../../docs/SERVICE-README-TEMPLATE.md).

## Description

The **Notification Service** is a microservice responsible for managing all email notifications within the JobApp application. This service processes message queues and sends personalized emails using predefined templates.

## Service-Specific Technologies

- **Nodemailer** - Email sending
- **Email Templates** - Email template management (EJS)

## Main Features

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

## API Endpoints

This service is primarily event-driven and consumes messages from RabbitMQ queues. It does not expose HTTP endpoints for external use (only health check).

### Health
- `GET /` - Health check endpoint

## Queue Consumers

The service consumes messages from the following RabbitMQ queues:

- `auth-email-queue` - Authentication-related emails (verification, password reset)
- `order-email-queue` - Order-related emails (placed, delivered, receipts, extensions)

## Email Templates

Email templates are located in `src/emails/`:

- `verifyEmail/` - Email verification template
- `forgotPassword/` - Password recovery template
- `resetPasswordSuccess/` - Password change confirmation
- `offer/` - Job offer template
- `orderPlaced/` - Order confirmation template
- `orderReceipt/` - Order receipt template
- `orderDelivered/` - Order delivery notification
- `orderExtension/` - Order extension request
- `orderExtensionApproval/` - Extension approval notification

## Service-Specific Environment Variables

```env
SENDER_EMAIL=<SENDER_EMAIL>
SENDER_EMAIL_PASSWORD=<EMAIL_PASSWORD>
```

## Integration with Other Services

This microservice integrates with:

- **RabbitMQ**: To receive notification messages from other services
- **Elasticsearch**: For centralized logging and search
- **Email Provider**: For actual email sending (SMTP)
- **Shared Library** (`@kevindeveloper95/jobapp-shared`): Shared utilities

## Workflow

1. **Reception**: The service receives messages from other microservices through RabbitMQ
2. **Processing**: The email consumer processes messages from the queue
3. **Templating**: The appropriate email template is selected and processed
4. **Sending**: The email is sent using Nodemailer
5. **Logging**: Activity is logged in Elasticsearch for monitoring
