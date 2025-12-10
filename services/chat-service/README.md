# Chat Service

> **Note**: For common service documentation (scripts, deployment, development workflow), see [Service README Template](../../docs/SERVICE-README-TEMPLATE.md).

## Description

The **Chat Service** is a microservice responsible for managing real-time messaging and communication between users within the JobApp application. This service handles message exchange, conversation management, and real-time chat functionality using Socket.io and MongoDB.

## Service-Specific Technologies

- **MongoDB** with **Mongoose** - Database ORM
- **Socket.io** - Real-time WebSocket communication
- **Redis** - Caching and session management

## Main Features

### 💬 Real-time Messaging
The service handles all chat-related operations:

- **Message Exchange** - Real-time message sending and receiving
- **Conversation Management** - Create and manage chat conversations
- **Message History** - Store and retrieve message history
- **Online Status** - Track user online/offline status
- **Message Notifications** - Real-time message notifications

### 🔌 WebSocket Communication
- **Socket.io Integration** for real-time bidirectional communication
- **Room Management** for private and group conversations
- **Connection Management** and automatic reconnection
- **Message Broadcasting** to multiple users

## API Endpoints

Base Path: `/api/v1/message`

### Message Routes
- `GET /conversation/:senderUsername/:receiverUsername` - Get conversation between users
- `GET /conversations/:username` - Get conversation list for user
- `GET /:senderUsername/:receiverUsername` - Get messages between users
- `GET /:conversationId` - Get messages by conversation ID
- `POST /` - Send message
- `PUT /offer` - Send job offer
- `PUT /mark-as-read` - Mark single message as read
- `PUT /mark-multiple-as-read` - Mark multiple messages as read

### Health
- `GET /` - Health check endpoint

## Database Models

- **Conversation Schema** (MongoDB) - Conversation metadata, participants, last message
- **Message Schema** (MongoDB) - Message content, sender, receiver, timestamp, read status

## Service-Specific Environment Variables

```env
MONGODB_URL=<MONGODB_CONNECTION_STRING>
REDIS_HOST=<REDIS_URL>
```

## Integration with Other Services

This microservice integrates with:

- **MongoDB**: For message and conversation storage
- **Socket.io**: For real-time communication
- **Redis**: For caching and session management
- **RabbitMQ**: For sending chat events to other services
- **Elasticsearch**: For centralized logging and search
- **Shared Library** (`@kevindeveloper95/jobapp-shared`): Shared utilities

## Workflow

1. **Connection**: Users connect via WebSocket
2. **Authentication**: User authentication and session management
3. **Message Sending**: Real-time message exchange
4. **Message Storage**: Messages are stored in MongoDB
5. **Event Publishing**: Chat events are published to RabbitMQ
6. **Notification**: Real-time notifications to connected users
7. **Logging**: Activity logging in Elasticsearch for monitoring
