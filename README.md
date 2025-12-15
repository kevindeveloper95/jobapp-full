# JobApp - Plataforma de Marketplace de Servicios

[![TypeScript](https://img.shields.io/badge/TypeScript-007ACC?style=for-the-badge&logo=typescript&logoColor=white)](https://www.typescriptlang.org/)
[![Node.js](https://img.shields.io/badge/Node.js-339933?style=for-the-badge&logo=nodedotjs&logoColor=white)](https://nodejs.org/)
[![React](https://img.shields.io/badge/React-20232A?style=for-the-badge&logo=react&logoColor=61DAFB)](https://reactjs.org/)
[![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)](https://www.docker.com/)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)](https://kubernetes.io/)

**JobApp** es una plataforma completa de marketplace de servicios (similar a Fiverr) construida con una arquitectura de microservicios moderna. Permite a los usuarios comprar y vender servicios digitales, gestionar órdenes, comunicarse en tiempo real y gestionar reseñas.

## 📋 Tabla de Contenidos

- [Características Principales](#-características-principales)
- [Arquitectura](#-arquitectura)
- [Stack Tecnológico](#-stack-tecnológico)
- [Estructura del Proyecto](#-estructura-del-proyecto)
- [Prerrequisitos](#-prerrequisitos)
- [Instalación](#-instalación)
- [Configuración](#-configuración)
- [Uso](#-uso)
- [Desarrollo](#-desarrollo)
- [Despliegue](#-despliegue)
- [API Endpoints](#-api-endpoints)
- [Documentación Adicional](#-documentación-adicional)
- [Contribución](#-contribución)
- [Licencia](#-licencia)

## ✨ Características Principales

### 🔐 Autenticación y Autorización
- Registro y login de usuarios
- Verificación de email
- Recuperación de contraseña
- Gestión de sesiones con JWT
- Autenticación basada en cookies (httpOnly, secure)

### 👥 Gestión de Usuarios
- Perfiles de compradores (Buyers)
- Perfiles de vendedores (Sellers)
- Gestión de habilidades y experiencia
- Portafolios y certificaciones
- Sistema de calificaciones

### 💼 Gestión de Gigs (Servicios)
- Creación y edición de servicios
- Búsqueda avanzada con Elasticsearch
- Categorización y etiquetas
- Gestión de imágenes y portadas
- Sistema de precios y paquetes

### 📦 Sistema de Órdenes
- Creación de órdenes
- Integración con Stripe para pagos
- Gestión de entregas
- Sistema de extensiones de tiempo
- Tracking de estado de órdenes

### ⭐ Sistema de Reseñas
- Reseñas de compradores y vendedores
- Sistema de calificaciones (1-5 estrellas)
- Analytics de reviews
- Cálculo de promedios y estadísticas

### 💬 Chat en Tiempo Real
- Mensajería instantánea entre usuarios
- Notificaciones en tiempo real
- Envío de ofertas personalizadas
- Historial de conversaciones

### 🔔 Notificaciones
- Notificaciones por email
- Notificaciones push en tiempo real
- Templates personalizados
- Sistema de eventos asíncronos

## 🏗️ Arquitectura

JobApp está construido siguiendo los principios de **Arquitectura de Microservicios**, con los siguientes componentes principales:

### Microservicios

1. **Gateway Service** (Puerto 4000)
   - Punto de entrada único para todas las peticiones
   - Routing y load balancing
   - Autenticación centralizada
   - WebSocket para comunicación en tiempo real
   - Rate limiting y CORS

2. **Auth Service** (Puerto 4003)
   - Autenticación y autorización
   - Gestión de usuarios y sesiones
   - JWT token management
   - Base de datos: **MySQL**

3. **Users Service** (Puerto 4005)
   - Gestión de perfiles de usuarios
   - Perfiles de compradores y vendedores
   - Base de datos: **MongoDB**

4. **Gig Service** (Puerto 4004)
   - Gestión de servicios (gigs)
   - Búsqueda con Elasticsearch
   - Base de datos: **MongoDB**

5. **Order Service** (Puerto 4008)
   - Gestión de órdenes
   - Integración con Stripe
   - Base de datos: **MongoDB**

6. **Review Service** (Puerto 4009)
   - Sistema de reseñas y calificaciones
   - Analytics de reviews
   - Bases de datos: **MongoDB** + **PostgreSQL**

7. **Chat Service** (Puerto 4007)
   - Mensajería en tiempo real
   - Gestión de conversaciones
   - Base de datos: **MongoDB**

8. **Notification Service** (Puerto 4002)
   - Envío de emails
   - Procesamiento de eventos asíncronos
   - Sin base de datos propia (stateless)

### Frontend

- **Jobber Client** (Puerto 3000)
  - Aplicación React con TypeScript
  - Redux para gestión de estado
  - Socket.io para comunicación en tiempo real
  - Integración con Stripe
  - UI moderna con Tailwind CSS

### Infraestructura

- **RabbitMQ**: Message broker para comunicación asíncrona
- **Redis**: Caché y sesiones
- **Elasticsearch**: Búsqueda y logging centralizado
- **Kibana**: Visualización de logs
- **Docker**: Containerización
- **Kubernetes**: Orquestación (AWS EKS / Minikube)
- **Jenkins**: CI/CD

## 🛠️ Stack Tecnológico

### Backend
- **Node.js** + **TypeScript**
- **Express.js** - Framework web
- **Sequelize** - ORM para MySQL
- **Mongoose** - ODM para MongoDB
- **Socket.io** - WebSockets
- **RabbitMQ** - Message broker
- **Redis** - Caché y sesiones
- **Elasticsearch** - Búsqueda y logging
- **JWT** - Autenticación
- **Stripe** - Pagos

### Frontend
- **React 18** + **TypeScript**
- **Vite** - Build tool
- **Redux Toolkit** - Gestión de estado
- **React Router** - Routing
- **Tailwind CSS** - Estilos
- **Socket.io Client** - Comunicación en tiempo real
- **Axios** - HTTP client

### DevOps
- **Docker** - Containerización
- **Kubernetes** - Orquestación
- **Jenkins** - CI/CD
- **AWS EKS** - Kubernetes en la nube
- **PM2** - Process manager

### Bases de Datos
- **MySQL** - Datos relacionales (Auth)
- **MongoDB** - Documentos (Users, Gigs, Orders, Chat, Reviews)
- **PostgreSQL** - Analytics (Reviews)
- **Redis** - Caché y sesiones
- **Elasticsearch** - Búsqueda y logs

## 📁 Estructura del Proyecto

```
jobapp-full/
├── services/                    # Microservicios backend
│   ├── gateway-service/         # API Gateway
│   ├── auth-service/            # Autenticación
│   ├── users-service/          # Gestión de usuarios
│   ├── gig-service/             # Gestión de gigs
│   ├── order-service/           # Gestión de órdenes
│   ├── review-service/          # Sistema de reseñas
│   ├── chat-service/            # Mensajería
│   ├── notification-service/    # Notificaciones
│   └── jobapp-shared/           # Librería compartida
├── jobber-client/               # Frontend React
├── jobber-k8s/                  # Configuración Kubernetes
│   ├── AWS/                     # Configuración para AWS EKS
│   └── minikube/                # Configuración para Minikube
├── docs/                        # Documentación adicional
├── diagrams/                    # Diagramas de arquitectura
├── services/volumes/            # Docker Compose para bases de datos
├── package.json                 # Scripts de desarrollo
└── README.md                    # Este archivo
```

## 📦 Prerrequisitos

Antes de comenzar, asegúrate de tener instalado:

- **Node.js** >= 18.x
- **npm** >= 9.x
- **Docker** y **Docker Compose**
- **Git**
- **PowerShell** (para Windows) o **Bash** (para Linux/Mac)

### Opcional (para desarrollo local con Kubernetes)
- **Minikube** (para desarrollo local con K8s)
- **kubectl** (cliente de Kubernetes)

## 🚀 Instalación

### 1. Clonar el Repositorio

```bash
git clone <repository-url>
cd jobapp-full
```

### 2. Instalar Dependencias

Instala todas las dependencias de todos los servicios y el cliente:

```bash
npm run install:all
```

O instala manualmente:

```bash
# Instalar dependencias de la raíz
npm install

# Instalar dependencias de cada servicio
cd services/gateway-service && npm install && cd ../..
cd services/auth-service && npm install && cd ../..
cd services/users-service && npm install && cd ../..
cd services/gig-service && npm install && cd ../..
cd services/order-service && npm install && cd ../..
cd services/review-service && npm install && cd ../..
cd services/chat-service && npm install && cd ../..
cd services/notification-service && npm install && cd ../..

# Instalar dependencias del cliente
cd jobber-client && npm install && cd ..
```

### 3. Iniciar Bases de Datos

**⚠️ IMPORTANTE:** Debes iniciar las bases de datos antes de ejecutar los servicios.

```bash
# Opción 1: Usando el script
npm run start-databases

# Opción 2: Manualmente
cd services/volumes
docker-compose up -d
```

Esto iniciará:
- Redis (puerto 6379)
- MongoDB (puerto 27017)
- MySQL (puerto 3307)
- PostgreSQL (puerto 5432)
- RabbitMQ (puertos 5672, 15672)
- Elasticsearch (puerto 9200)
- Kibana (puerto 5601)
- APM Server (puerto 8200)

**Espera 30-60 segundos** después de iniciar docker-compose para que Elasticsearch esté completamente listo.

## ⚙️ Configuración

### Variables de Entorno

Cada servicio requiere su propio archivo `.env`. Consulta los READMEs individuales de cada servicio para más detalles:

- `services/gateway-service/README.md`
- `services/auth-service/README.md`
- `services/users-service/README.md`
- etc.

### Configuración Mínima Requerida

Cada servicio necesita configurar:
- URLs de bases de datos
- URLs de servicios externos (RabbitMQ, Redis, Elasticsearch)
- Secrets (JWT, Stripe, Cloudinary, etc.)
- Puertos

## 🎯 Uso

### Desarrollo Local

#### Opción 1: Ejecutar Todos los Servicios (Recomendado)

```bash
# Ejecutar todos los servicios + frontend
npm run dev

# Ejecutar solo los servicios backend (sin frontend)
npm run dev:services
```

Esto iniciará todos los servicios en paralelo usando `concurrently`, mostrando los logs de cada servicio con colores diferentes.

#### Opción 2: Ejecutar Servicios Individuales

```bash
npm run dev:gateway      # Gateway Service (puerto 4000)
npm run dev:auth         # Auth Service (puerto 4003)
npm run dev:users        # Users Service (puerto 4005)
npm run dev:notifications # Notification Service (puerto 4002)
npm run dev:chat         # Chat Service (puerto 4007)
npm run dev:gig          # Gig Service (puerto 4004)
npm run dev:order        # Order Service (puerto 4008)
npm run dev:review       # Review Service (puerto 4009)
npm run dev:client       # Frontend (puerto 3000)
```

#### Opción 3: Script de PowerShell (Windows)

```powershell
.\dev-services.ps1
```

Este script abre cada servicio en una ventana de PowerShell separada.

### Liberar Puertos

Si encuentras errores de puertos en uso:

```bash
npm run kill-ports
```

O manualmente:

```powershell
.\kill-ports.ps1
```

### Acceder a la Aplicación

Una vez que todos los servicios estén ejecutándose:

- **Frontend**: http://localhost:3000
- **Gateway Health Check**: http://localhost:4000/gateway-health
- **RabbitMQ Management**: http://localhost:15672 (guest/guest)
- **Kibana**: http://localhost:5601
- **Elasticsearch**: http://localhost:9200

## 🔧 Desarrollo

### Estructura de un Microservicio

Cada microservicio sigue una estructura similar:

```
service-name/
├── src/
│   ├── app.ts              # Punto de entrada
│   ├── routes/              # Rutas de la API
│   ├── controllers/         # Controladores
│   ├── services/            # Lógica de negocio
│   ├── models/              # Modelos de datos
│   ├── middleware/          # Middleware personalizado
│   └── config/              # Configuración
├── Dockerfile               # Docker para producción
├── Dockerfile.dev           # Docker para desarrollo
├── Jenkinsfile              # Pipeline de CI/CD
├── package.json
└── README.md
```

### Compilar un Servicio

```bash
cd services/<service-name>
npm run build
```

### Ejecutar Tests

```bash
cd services/<service-name>
npm test
```

### Linting y Formateo

```bash
# Verificar linting
npm run lint:check

# Corregir problemas de linting
npm run lint:fix

# Verificar formateo
npm run prettier:check

# Aplicar formateo
npm run prettier:fix
```

## 🚢 Despliegue

### Docker

Cada servicio tiene su propio `Dockerfile`:

```bash
cd services/<service-name>
docker build -t <service-name>:latest .
docker run -p <port>:<port> <service-name>:latest
```

### Kubernetes

El proyecto incluye configuraciones de Kubernetes para:

- **AWS EKS**: `jobber-k8s/AWS/`
- **Minikube**: `jobber-k8s/minikube/`

Para desplegar en Kubernetes:

```bash
# Aplicar configuraciones
kubectl apply -f jobber-k8s/AWS/

# Verificar estado
kubectl get pods
kubectl get services
```

### CI/CD con Jenkins

Cada servicio tiene un `Jenkinsfile` configurado para:
- Build automático
- Tests
- Docker image creation
- Deployment a Kubernetes

## 📡 API Endpoints

### Base URL

**Desarrollo Local**: `http://localhost:4000/api/gateway/v1`

### Documentación Completa

Consulta el archivo [`API-ENDPOINTS-INSOMNIA.md`](./API-ENDPOINTS-INSOMNIA.md) para una lista completa de todos los endpoints disponibles.

### Endpoints Principales

#### Autenticación
- `POST /auth/signup` - Registro de usuario
- `POST /auth/signin` - Login
- `GET /auth/currentuser` - Usuario actual
- `POST /auth/signout` - Cerrar sesión

#### Gigs
- `GET /gig/search/{from}/{size}/{type}` - Buscar gigs
- `GET /gig/{gigId}` - Obtener gig por ID
- `POST /gig/create` - Crear gig
- `PUT /gig/{gigId}` - Actualizar gig

#### Órdenes
- `POST /order` - Crear orden
- `POST /order/create-payment-intent` - Crear payment intent
- `GET /order/buyer/{buyerId}` - Órdenes del comprador
- `GET /order/seller/{sellerId}` - Órdenes del vendedor

#### Reseñas
- `POST /review` - Crear reseña
- `GET /review/gig/{gigId}` - Reseñas de un gig
- `GET /review/seller/{sellerId}` - Reseñas de un vendedor

#### Chat
- `POST /message` - Enviar mensaje
- `GET /message/conversations/{username}` - Lista de conversaciones
- `GET /message/{conversationId}` - Mensajes de una conversación

## 📚 Documentación Adicional

- **[API Endpoints](./API-ENDPOINTS-INSOMNIA.md)**: Documentación completa de la API
- **[Patrones de Microservicios](./PATRONES-MICROSERVICIOS.md)**: Documentación detallada de los patrones arquitectónicos implementados
- **[Scripts de Desarrollo](./DEV-SCRIPTS.md)**: Guía de scripts para desarrollo
- **[Troubleshooting](./docs/troubleshooting/README.md)**: Solución de problemas comunes
- **[Diagramas](./diagrams/)**: Diagramas de arquitectura del sistema

### READMEs de Servicios

Cada servicio tiene su propio README con documentación específica:

- [Gateway Service](./services/gateway-service/README.md)
- [Auth Service](./services/auth-service/README.md)
- [Users Service](./services/users-service/README.md)
- [Gig Service](./services/gig-service/README.md)
- [Order Service](./services/order-service/README.md)
- [Review Service](./services/review-service/README.md)
- [Chat Service](./services/chat-service/README.md)
- [Notification Service](./services/notification-service/README.md)

## 🤝 Contribución

Las contribuciones son bienvenidas. Por favor:

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

### Estándares de Código

- Usa TypeScript para todo el código
- Sigue las convenciones de ESLint y Prettier configuradas
- Escribe tests para nuevas funcionalidades
- Actualiza la documentación según sea necesario

## 📄 Licencia

Este proyecto está bajo la Licencia ISC.

## 👥 Autores

- **Kevin Developer** - Desarrollo inicial

## 🙏 Agradecimientos

- A todos los contribuidores y la comunidad de código abierto
- A las tecnologías y herramientas que hacen posible este proyecto

---

**¿Necesitas ayuda?** Consulta la [documentación de troubleshooting](./docs/troubleshooting/README.md) o abre un issue en el repositorio.

