import { authService } from '@gateway/services/api/auth.service';
import { winstonLogger } from '@kevindeveloper95/jobapp-shared';
import { AxiosResponse } from 'axios';
import { Request, Response } from 'express';
import { StatusCodes } from 'http-status-codes';
import { config } from '@gateway/config';
import { Logger } from 'winston';
import { serializeErrorForLogging } from '@gateway/utils/error-serializer';

const log: Logger = winstonLogger(`${config.ELASTIC_SEARCH_URL}`, 'signupController', 'debug');

export class SignUp {
  public async create(req: Request, res: Response): Promise<void> {
    const startTime = Date.now();
    log.info('SignUp request received', { body: req.body, origin: req.headers.origin });

    try {
      log.info('Calling auth-service signup...');
      const response: AxiosResponse = await authService.signUp(req.body);
      const duration = Date.now() - startTime;
      log.info(`Auth-service responded successfully in ${duration}ms`);

      req.session = { jwt: response.data.token };
      res.status(StatusCodes.CREATED).json({ message: response.data.message, user: response.data.user });
    } catch (error: unknown) {
      const duration = Date.now() - startTime;
      const serializedError = serializeErrorForLogging(error);
      log.log('error', `SignUp error after ${duration}ms:`, serializedError);

      // Si el Auth Service devuelve un error, reenviar la respuesta al cliente
      if (error && typeof error === 'object' && 'response' in error) {
        const axiosError = error as { response: { status: number; data: unknown; headers?: { 'content-type'?: string } } };
        // Serializar data como string para logging si es un objeto
        let logData: unknown = axiosError.response.data;
        if (logData && typeof logData === 'object') {
          try {
            logData = JSON.stringify(logData);
          } catch {
            logData = '[Non-serializable object]';
          }
        }
        log.log('error', 'Auth-service error response:', { status: axiosError.response.status, data: logData });
        
        // Si la respuesta es HTML, intentar extraer el mensaje o devolver un error JSON
        const contentType = axiosError.response.headers?.['content-type'] || '';
        if (typeof axiosError.response.data === 'string' && contentType.includes('text/html')) {
          // Intentar extraer el mensaje del HTML
          const htmlData = axiosError.response.data as string;
          const messageMatch = htmlData.match(/Error:\s*([^<]+)/) || htmlData.match(/<pre>([^<]+)/);
          const errorMessage = messageMatch ? messageMatch[1].trim() : 'An error occurred during signup';
          
          res.status(axiosError.response.status).json({
            message: errorMessage,
            statusCode: axiosError.response.status,
            status: 'error'
          });
        } else {
          // Si es JSON (objeto o string JSON), parsearlo y devolverlo
          let errorData = axiosError.response.data;
          if (typeof errorData === 'string') {
            try {
              errorData = JSON.parse(errorData);
            } catch {
              // Si no se puede parsear, devolver como mensaje
              errorData = { message: errorData, statusCode: axiosError.response.status };
            }
          }
          res.status(axiosError.response.status).json(errorData);
        }
      } else {
        const errorMessage = error instanceof Error ? error.message : 'Unknown error';
        log.log('error', 'Unknown signup error:', { message: errorMessage });
        res.status(StatusCodes.INTERNAL_SERVER_ERROR).json({
          message: 'An error occurred during signup',
          error: errorMessage
        });
      }
    }
  }
}
