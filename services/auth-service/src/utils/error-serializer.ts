/**
 * Serializa un error de forma segura para logging, evitando referencias circulares
 */
export function serializeErrorForLogging(error: unknown): Record<string, unknown> {
  // Si es un Error estándar
  if (error instanceof Error) {
    return {
      message: error.message,
      name: error.name,
      stack: error.stack,
      isError: true
    };
  }

  // Si es un objeto con propiedades personalizadas
  if (error && typeof error === 'object') {
    try {
      const serialized: Record<string, unknown> = {};
      for (const [key, value] of Object.entries(error)) {
        if (
          value === null ||
          value === undefined ||
          typeof value === 'string' ||
          typeof value === 'number' ||
          typeof value === 'boolean'
        ) {
          serialized[key] = value;
        } else if (value instanceof Error) {
          serialized[key] = {
            message: value.message,
            name: value.name,
            stack: value.stack
          };
        } else {
          try {
            JSON.stringify(value);
            serialized[key] = value;
          } catch {
            serialized[key] = '[Non-serializable]';
          }
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

