import http from 'http';

import 'express-async-errors';
import { CustomError, IAuthPayload, winstonLogger } from '@kevindeveloper95/jobapp-shared';
import { StatusCodes } from 'http-status-codes';
import { Logger } from 'winston';
import { config } from '@auth/config';
import { Application, Request, Response, NextFunction, json, urlencoded } from 'express';
import hpp from 'hpp';
import helmet from 'helmet';
import cors from 'cors';
import { verify } from 'jsonwebtoken';
import compression from 'compression';
import { checkConnection, createIndex } from '@auth/elasticsearch';
import { appRoutes } from '@auth/routes';
import { Channel } from 'amqplib';
import { createConnection } from '@auth/queues/connection';
import { serializeErrorForLogging } from '@auth/utils/error-serializer';

const SERVER_PORT = 4003;
const log: Logger = winstonLogger(`${config.ELASTIC_SEARCH_URL}`, 'authenticationServer', 'debug');

export let authChannel: Channel;

export function start(app: Application): void {
  securityMiddleware(app);
  standardMiddleware(app);
  routesMiddleware(app);
  startQueues();
  startElasticSearch(); // Ejecutar en segundo plano sin bloquear
  authErrorHandler(app);
  startServer(app);
}

function securityMiddleware(app: Application): void {
  app.set('trust proxy', 1);
  app.use(hpp());
  app.use(helmet());
  app.use(
    cors({
      origin: config.API_GATEWAY_URL,
      credentials: true,
      methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS']
    })
  );
  app.use((req: Request, _res: Response, next: NextFunction) => {
    if (req.headers.authorization) {
      const token = req.headers.authorization.split(' ')[1];
      const payload: IAuthPayload = verify(token, config.JWT_TOKEN!) as IAuthPayload;
      req.currentUser = payload;
    }
    next();
  });
}

function standardMiddleware(app: Application): void {
  app.use(compression());
  app.use(json({ limit: '200mb' }));
  app.use(urlencoded({ extended: true, limit: '200mb' }));
}

function routesMiddleware(app: Application): void {
  appRoutes(app);
}

async function startQueues(): Promise<void> {
  authChannel = await createConnection() as Channel;
}

async function startElasticSearch(): Promise<void> {
  try {
    await checkConnection();
    await createIndex('gigs');
  } catch (error) {
    const serializedError = serializeErrorForLogging(error);
    log.error('Failed to initialize Elasticsearch:', serializedError);
  }
}

function authErrorHandler(app: Application): void {
  // Error handler para CustomError y errores con statusCode/comingFrom
  app.use((error: unknown, _req: Request, res: Response, next: NextFunction) => {
    // Verificar si es CustomError o tiene propiedades de CustomError
    const hasCustomErrorProperties = error && typeof error === 'object' && 
      'statusCode' in error && 
      'comingFrom' in error &&
      'message' in error;
    
    if (error instanceof CustomError || hasCustomErrorProperties) {
      const customError = error as CustomError & { statusCode: number; comingFrom: string; message: string };
      const serializedError = serializeErrorForLogging(error);
      log.log('error', `AuthService ${customError.comingFrom}:`, serializedError);
      
      // Intentar usar serializeErrors si está disponible, sino construir manualmente
      let errorResponse;
      if (typeof (customError as any).serializeErrors === 'function') {
        errorResponse = (customError as CustomError).serializeErrors();
      } else {
        errorResponse = {
          message: customError.message,
          statusCode: customError.statusCode,
          status: (customError as any).status || 'error',
          comingFrom: customError.comingFrom
        };
      }
      
      return res.status(customError.statusCode).json(errorResponse);
    }
    
    // Si no es un CustomError, pasarlo al siguiente handler
    next(error);
  });

  // Error handler final - siempre devuelve JSON para errores no manejados
  app.use((error: unknown, _req: Request, res: Response, _next: NextFunction) => {
    const serializedError = serializeErrorForLogging(error);
    log.log('error', 'AuthService unhandled error:', serializedError);
    
    const statusCode = (error && typeof error === 'object' && 'statusCode' in error) 
      ? (error as { statusCode: number }).statusCode 
      : StatusCodes.INTERNAL_SERVER_ERROR;
    const message = error instanceof Error ? error.message : 'An unexpected error occurred';
    
    res.status(statusCode).json({
      message,
      statusCode,
      status: 'error',
      comingFrom: 'AuthService error handler'
    });
  });
}

function startServer(app: Application): void {
  try {
    const httpServer: http.Server = new http.Server(app);
    log.info(`Authentication server has started with process id ${process.pid}`);
    httpServer.listen(SERVER_PORT, () => {
      log.info(`Authentication server running on port ${SERVER_PORT}`);
    });
  } catch (error) {
    const serializedError = serializeErrorForLogging(error);
    log.log('error', 'AuthService startServer() method error:', serializedError);
  }
}