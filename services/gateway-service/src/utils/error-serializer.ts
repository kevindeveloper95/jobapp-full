import { isAxiosError, AxiosError } from 'axios';

/**
 * Serializa un error de forma segura para logging, evitando referencias circulares
 * especialmente en errores de Axios que contienen objetos con referencias circulares
 */
export function serializeErrorForLogging(error: unknown): Record<string, unknown> {
  // Si es un error de Axios, extraer solo la información necesaria
  if (isAxiosError(error)) {
    const axiosError = error as AxiosError;
    // Serializar responseData como string JSON si es un objeto
    let responseDataSerialized: unknown = axiosError.response?.data;
    if (responseDataSerialized && typeof responseDataSerialized === 'object') {
      try {
        responseDataSerialized = JSON.stringify(responseDataSerialized);
      } catch {
        responseDataSerialized = '[Non-serializable object]';
      }
    }
    
    return {
      message: axiosError.message,
      code: axiosError.code,
      status: axiosError.response?.status,
      statusText: axiosError.response?.statusText,
      responseData: responseDataSerialized,
      config: {
        url: axiosError.config?.url,
        method: axiosError.config?.method,
        baseURL: axiosError.config?.baseURL,
        timeout: axiosError.config?.timeout
      },
      isAxiosError: true
    };
  }

  // Si es un Error estándar
  if (error instanceof Error) {
    return {
      message: error.message,
      name: error.name,
      stack: error.stack,
      isError: true
    };
  }

  // Si es un objeto con una propiedad response (similar a Axios pero no reconocido como tal)
  if (error && typeof error === 'object' && 'response' in error) {
    const errorWithResponse = error as { response?: { status?: number; data?: unknown }; message?: string };
    // Serializar data como string JSON si es un objeto
    let responseDataSerialized: unknown = errorWithResponse.response?.data;
    if (responseDataSerialized && typeof responseDataSerialized === 'object') {
      try {
        responseDataSerialized = JSON.stringify(responseDataSerialized);
      } catch {
        responseDataSerialized = '[Non-serializable object]';
      }
    }
    
    return {
      message: errorWithResponse.message || 'Unknown error with response',
      response: {
        status: errorWithResponse.response?.status,
        data: responseDataSerialized
      },
      hasResponse: true
    };
  }

  // Si es un objeto genérico, intentar serializarlo
  if (error && typeof error === 'object') {
    try {
      // Intentar serializar solo las propiedades primitivas
      const serialized: Record<string, unknown> = {};
      for (const [key, value] of Object.entries(error)) {
        if (
          value === null ||
          value === undefined ||
          typeof value === 'string' ||
          typeof value === 'number' ||
          typeof value === 'boolean' ||
          (typeof value === 'object' && !(value instanceof Error))
        ) {
          try {
            JSON.stringify(value);
            serialized[key] = value;
          } catch {
            // Saltar propiedades no serializables
            serialized[key] = '[Non-serializable]';
          }
        } else {
          serialized[key] = String(value);
        }
      }
      return serialized;
    } catch {
      return { error: String(error) };
    }
  }

  // Valor primitivo o desconocido
  return { error: String(error) };
}
