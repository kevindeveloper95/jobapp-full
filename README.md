# JobApp - Service Marketplace Platform

[![TypeScript](https://img.shields.io/badge/TypeScript-007ACC?style=for-the-badge&logo=typescript&logoColor=white)](https://www.typescriptlang.org/)
[![Node.js](https://img.shields.io/badge/Node.js-339933?style=for-the-badge&logo=nodedotjs&logoColor=white)](https://nodejs.org/)
[![React](https://img.shields.io/badge/React-20232A?style=for-the-badge&logo=react&logoColor=61DAFB)](https://reactjs.org/)
[![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)](https://www.docker.com/)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)](https://kubernetes.io/)

**JobApp** is a complete service marketplace platform (similar to Fiverr) built with a modern microservices architecture. It allows users to buy and sell digital services, manage orders, communicate in real-time, and handle reviews.

## 📋 Table of Contents

- [Main Features](#-main-features)
- [Architecture](#-architecture)
- [Technology Stack](#-technology-stack)
- [Project Structure](#-project-structure)
- [Prerequisites](#-prerequisites)
- [Installation](#-installation)
- [Configuration](#-configuration)
- [Usage](#-usage)
- [Development](#-development)
- [Deployment](#-deployment)
- [API Endpoints](#-api-endpoints)
- [Additional Documentation](#-additional-documentation)
- [Contributing](#-contributing)
- [License](#-license)

## ✨ Main Features

### 🔐 Authentication & Authorization
- User registration and login
- Email verification
- Password recovery
- JWT session management
- Cookie-based authentication (httpOnly, secure)

### 👥 User Management
- Buyer profiles
- Seller profiles
- Skills and experience management
- Portfolios and certifications
- Rating system

### 💼 Gig (Service) Management
- Service creation and editing
- Advanced search with Elasticsearch
- Categorization and tags
- Image and cover management
- Pricing and package system

### 📦 Order System
- Order creation
- Stripe payment integration
- Delivery management
- Time extension system
- Order status tracking

### ⭐ Review System
- Buyer and seller reviews
- Rating system (1-5 stars)
- Review analytics
- Average and statistics calculation

### 💬 Real-Time Chat
- Instant messaging between users
- Real-time notifications
- Custom offer sending
- Conversation history

### 🔔 Notifications
- Email notifications
- Real-time push notifications
- Custom templates
- Asynchronous event system

## 🏗️ Architecture

JobApp is built following **Microservices Architecture** principles, with the following main components:

### Microservices

1. **Gateway Service** (Port 4000)
   - Single entry point for all requests
   - Routing and load balancing
   - Centralized authentication
   - WebSocket for real-time communication
   - Rate limiting and CORS

2. **Auth Service** (Port 4003)
   - Authentication and authorization
   - User and session management
   - JWT token management
   - Database: **MySQL**

3. **Users Service** (Port 4005)
   - User profile management
   - Buyer and seller profiles
   - Database: **MongoDB**

4. **Gig Service** (Port 4004)
   - Service (gig) management
   - Elasticsearch search
   - Database: **MongoDB**

5. **Order Service** (Port 4008)
   - Order management
   - Stripe integration
   - Database: **MongoDB**

6. **Review Service** (Port 4009)
   - Review and rating system
   - Review analytics
   - Databases: **MongoDB** + **PostgreSQL**

7. **Chat Service** (Port 4007)
   - Real-time messaging
   - Conversation management
   - Database: **MongoDB**

8. **Notification Service** (Port 4002)
   - Email sending
   - Asynchronous event processing
   - No own database (stateless)

### Frontend

- **Jobber Client** (Port 3000)
  - React application with TypeScript
  - Redux for state management
  - Socket.io for real-time communication
  - Stripe integration
  - Modern UI with Tailwind CSS

### Infrastructure

- **RabbitMQ**: Message broker for asynchronous communication
- **Redis**: Cache and sessions
- **Elasticsearch**: Search and centralized logging
- **Kibana**: Log visualization
- **Docker**: Containerization
- **Kubernetes**: Orchestration (AWS EKS / Minikube)
- **Jenkins**: CI/CD

## 🛠️ Technology Stack

### Backend
- **Node.js** + **TypeScript**
- **Express.js** - Web framework
- **Sequelize** - ORM for MySQL
- **Mongoose** - ODM for MongoDB
- **Socket.io** - WebSockets
- **RabbitMQ** - Message broker
- **Redis** - Cache and sessions
- **Elasticsearch** - Search and logging
- **JWT** - Authentication
- **Stripe** - Payments

### Frontend
- **React 18** + **TypeScript**
- **Vite** - Build tool
- **Redux Toolkit** - State management
- **React Router** - Routing
- **Tailwind CSS** - Styling
- **Socket.io Client** - Real-time communication
- **Axios** - HTTP client

### DevOps
- **Docker** - Containerization
- **Kubernetes** - Orchestration
- **Jenkins** - CI/CD
- **AWS EKS** - Kubernetes in the cloud
- **PM2** - Process manager

### Databases
- **MySQL** - Relational data (Auth)
- **MongoDB** - Documents (Users, Gigs, Orders, Chat, Reviews)
- **PostgreSQL** - Analytics (Reviews)
- **Redis** - Cache and sessions
- **Elasticsearch** - Search and logs

## 📁 Project Structure

```
jobapp-full/
├── services/                    # Backend microservices
│   ├── gateway-service/         # API Gateway
│   ├── auth-service/            # Authentication
│   ├── users-service/          # User management
│   ├── gig-service/             # Gig management
│   ├── order-service/           # Order management
│   ├── review-service/          # Review system
│   ├── chat-service/            # Messaging
│   ├── notification-service/    # Notifications
│   └── jobapp-shared/           # Shared library
├── jobber-client/               # React frontend
├── jobber-k8s/                  # Kubernetes configuration
│   ├── AWS/                     # AWS EKS configuration
│   └── minikube/                # Minikube configuration
├── docs/                        # Additional documentation
├── diagrams/                    # Architecture diagrams
├── services/volumes/            # Docker Compose for databases
├── package.json                 # Development scripts
└── README.md                    # This file
```

## 📦 Prerequisites

Before starting, make sure you have installed:

- **Node.js** >= 18.x
- **npm** >= 9.x
- **Docker** and **Docker Compose**
- **Git**
- **PowerShell** (for Windows) or **Bash** (for Linux/Mac)

### Optional (for local Kubernetes development)
- **Minikube** (for local K8s development)
- **kubectl** (Kubernetes client)

## 🚀 Installation

### 1. Clone the Repository

```bash
git clone <repository-url>
cd jobapp-full
```

### 2. Install Dependencies

Install all dependencies for all services and the client:

```bash
npm run install:all
```

Or install manually:

```bash
# Install root dependencies
npm install

# Install dependencies for each service
cd services/gateway-service && npm install && cd ../..
cd services/auth-service && npm install && cd ../..
cd services/users-service && npm install && cd ../..
cd services/gig-service && npm install && cd ../..
cd services/order-service && npm install && cd ../..
cd services/review-service && npm install && cd ../..
cd services/chat-service && npm install && cd ../..
cd services/notification-service && npm install && cd ../..

# Install client dependencies
cd jobber-client && npm install && cd ..
```

### 3. Start Databases

**⚠️ IMPORTANT:** You must start the databases before running the services.

```bash
# Option 1: Using the script
npm run start-databases

# Option 2: Manually
cd services/volumes
docker-compose up -d
```

This will start:
- Redis (port 6379)
- MongoDB (port 27017)
- MySQL (port 3307)
- PostgreSQL (port 5432)
- RabbitMQ (ports 5672, 15672)
- Elasticsearch (port 9200)
- Kibana (port 5601)
- APM Server (port 8200)

**Wait 30-60 seconds** after starting docker-compose for Elasticsearch to be completely ready.

## ⚙️ Configuration

### Environment Variables

Each service requires its own `.env` file. Check the individual READMEs for each service for more details:

- `services/gateway-service/README.md`
- `services/auth-service/README.md`
- `services/users-service/README.md`
- etc.

### Minimum Required Configuration

Each service needs to configure:
- Database URLs
- External service URLs (RabbitMQ, Redis, Elasticsearch)
- Secrets (JWT, Stripe, Cloudinary, etc.)
- Ports

## 🎯 Usage

### Local Development

#### Option 1: Run All Services (Recommended)

```bash
# Run all services + frontend
npm run dev

# Run only backend services (without frontend)
npm run dev:services
```

This will start all services in parallel using `concurrently`, showing logs from each service with different colors.

#### Option 2: Run Individual Services

```bash
npm run dev:gateway      # Gateway Service (port 4000)
npm run dev:auth         # Auth Service (port 4003)
npm run dev:users        # Users Service (port 4005)
npm run dev:notifications # Notification Service (port 4002)
npm run dev:chat         # Chat Service (port 4007)
npm run dev:gig          # Gig Service (port 4004)
npm run dev:order        # Order Service (port 4008)
npm run dev:review       # Review Service (port 4009)
npm run dev:client       # Frontend (port 3000)
```

#### Option 3: PowerShell Script (Windows)

```powershell
.\dev-services.ps1
```

This script opens each service in a separate PowerShell window.

### Free Ports

If you encounter port in use errors:

```bash
npm run kill-ports
```

Or manually:

```powershell
.\kill-ports.ps1
```

### Access the Application

Once all services are running:

- **Frontend**: http://localhost:3000
- **Gateway Health Check**: http://localhost:4000/gateway-health
- **RabbitMQ Management**: http://localhost:15672 (guest/guest)
- **Kibana**: http://localhost:5601
- **Elasticsearch**: http://localhost:9200

## 🔧 Development

### Microservice Structure

Each microservice follows a similar structure:

```
service-name/
├── src/
│   ├── app.ts              # Entry point
│   ├── routes/              # API routes
│   ├── controllers/         # Controllers
│   ├── services/            # Business logic
│   ├── models/              # Data models
│   ├── middleware/          # Custom middleware
│   └── config/              # Configuration
├── Dockerfile               # Docker for production
├── Dockerfile.dev           # Docker for development
├── Jenkinsfile              # CI/CD pipeline
├── package.json
└── README.md
```

### Build a Service

```bash
cd services/<service-name>
npm run build
```

### Run Tests

```bash
cd services/<service-name>
npm test
```

### Linting and Formatting

```bash
# Check linting
npm run lint:check

# Fix linting issues
npm run lint:fix

# Check formatting
npm run prettier:check

# Apply formatting
npm run prettier:fix
```

## 🚢 Deployment

### Docker

Each service has its own `Dockerfile`:

```bash
cd services/<service-name>
docker build -t <service-name>:latest .
docker run -p <port>:<port> <service-name>:latest
```

### Kubernetes

The project includes Kubernetes configurations for:

- **AWS EKS**: `jobber-k8s/AWS/`
- **Minikube**: `jobber-k8s/minikube/`

To deploy to Kubernetes:

```bash
# Apply configurations
kubectl apply -f jobber-k8s/AWS/

# Check status
kubectl get pods
kubectl get services
```

### CI/CD with Jenkins

Each service has a `Jenkinsfile` configured for:
- Automatic build
- Tests
- Docker image creation
- Kubernetes deployment

## 📡 API Endpoints

### Base URL

**Local Development**: `http://localhost:4000/api/gateway/v1`

### Complete Documentation

See the [`API-ENDPOINTS-INSOMNIA.md`](./API-ENDPOINTS-INSOMNIA.md) file for a complete list of all available endpoints.

### Main Endpoints

#### Authentication
- `POST /auth/signup` - User registration
- `POST /auth/signin` - Login
- `GET /auth/currentuser` - Current user
- `POST /auth/signout` - Logout

#### Gigs
- `GET /gig/search/{from}/{size}/{type}` - Search gigs
- `GET /gig/{gigId}` - Get gig by ID
- `POST /gig/create` - Create gig
- `PUT /gig/{gigId}` - Update gig

#### Orders
- `POST /order` - Create order
- `POST /order/create-payment-intent` - Create payment intent
- `GET /order/buyer/{buyerId}` - Buyer orders
- `GET /order/seller/{sellerId}` - Seller orders

#### Reviews
- `POST /review` - Create review
- `GET /review/gig/{gigId}` - Gig reviews
- `GET /review/seller/{sellerId}` - Seller reviews

#### Chat
- `POST /message` - Send message
- `GET /message/conversations/{username}` - Conversation list
- `GET /message/{conversationId}` - Conversation messages

## 📚 Additional Documentation

- **[API Endpoints](./API-ENDPOINTS-INSOMNIA.md)**: Complete API documentation
- **[Microservices Patterns](./PATRONES-MICROSERVICIOS.md)**: Detailed documentation of implemented architectural patterns
- **[Development Scripts](./DEV-SCRIPTS.md)**: Guide to development scripts
- **[Troubleshooting](./docs/troubleshooting/README.md)**: Common problem solutions
- **[Diagrams](./diagrams/)**: System architecture diagrams

### Service READMEs

Each service has its own README with specific documentation:

- [Gateway Service](./services/gateway-service/README.md)
- [Auth Service](./services/auth-service/README.md)
- [Users Service](./services/users-service/README.md)
- [Gig Service](./services/gig-service/README.md)
- [Order Service](./services/order-service/README.md)
- [Review Service](./services/review-service/README.md)
- [Chat Service](./services/chat-service/README.md)
- [Notification Service](./services/notification-service/README.md)

## 🤝 Contributing

Contributions are welcome. Please:

1. Fork the project
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Code Standards

- Use TypeScript for all code
- Follow configured ESLint and Prettier conventions
- Write tests for new features
- Update documentation as needed

## 📄 License

This project is licensed under the ISC License.

## 👥 Authors

- **Kevin Developer** - Initial development

## 🙏 Acknowledgments

- To all contributors and the open source community
- To the technologies and tools that make this project possible

---

**Need help?** Check the [troubleshooting documentation](./docs/troubleshooting/README.md) or open an issue in the repository.
