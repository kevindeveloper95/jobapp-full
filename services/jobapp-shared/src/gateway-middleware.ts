// Importa las dependencias necesarias
import JWT from 'jsonwebtoken'; // Librería para trabajar con JWT
import { Request, Response, NextFunction } from 'express'; // Tipos de Express
import { NotAuthorizedError } from './error-handler'; // Clase de error personalizado

// Lista de tokens válidos que pueden venir en el payload del JWT
const tokens: string[] = ['auth', 'seller', 'gig', 'search', 'buyer', 'message', 'order', 'review'];

// Middleware para verificar solicitudes provenientes del API Gateway
export function verifyGatewayRequest(req: Request, _res: Response, next: NextFunction): void {
  // Verifica si el encabezado 'gatewaytoken' existe en la solicitud
  if (!req.headers?.gatewaytoken) {
    throw new NotAuthorizedError(
      'Invalid request', 
      'verifyGatewayRequest() method: Request not coming from api gateway'
    );
  }

  // Obtiene el token del encabezado
  const token: string = req.headers?.gatewaytoken as string;
  
  // Verifica si el token existe
  if (!token) {
    throw new NotAuthorizedError(
      'Invalid request', 
      'verifyGatewayRequest() method: Request not coming from api gateway'
    );
  }

  try {
    // Verifica y decodifica el token JWT usando la clave secreta
    const payload: { id: string; iat: number } = JWT.verify(
      token, 
      '1282722b942e08c8a6cb033aa6ce850e' // Clave secreta para verificar el token
    ) as { id: string; iat: number };

    // Verifica si el ID del payload está en la lista de tokens permitidos
    if (!tokens.includes(payload.id)) {
      throw new NotAuthorizedError(
        'Invalid request', 
        'verifyGatewayRequest() method: Request payload is invalid'
      );
    }
  } catch (error) {
    // Captura cualquier error durante la verificación del token
    throw new NotAuthorizedError(
      'Invalid request', 
      'verifyGatewayRequest() method: Request not coming from api gateway'
    );
  }

  // Si todo está correcto, pasa al siguiente middleware
  next();
}