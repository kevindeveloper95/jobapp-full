import winston, { Logger } from 'winston';
import { ElasticsearchTransformer, ElasticsearchTransport, LogData, TransformedData } from 'winston-elasticsearch';

// Transforma logs a formato compatible con Elasticsearch
const esTransformer = (logData: LogData): TransformedData => ElasticsearchTransformer(logData);

// Crea logger configurado para consola y Elasticsearch
export const winstonLogger = (elasticsearchNode: string, name: string, level: string): Logger => {
  const options = {
    console: {
      level,                  // Nivel mínimo de logs para consola
      handleExceptions: true,  // Captura excepciones no manejadas
      json: false,            // Formato legible (no JSON)
      colorize: true          // Salida con colores
    },
    elasticsearch: {
      level,                  // Nivel mínimo para Elasticsearch
      transformer: esTransformer, // Transformador de formatos
      clientOpts: {
        node: elasticsearchNode, // URL del nodo de Elasticsearch
        log: level,            // Nivel de log del cliente
        maxRetries: 2,         // Reintentos en fallos de conexión
        requestTimeout: 10000, 
        sniffOnStart: false    // Desactiva autodetección de nodos
      }
    }
  };

  const esTransport = new ElasticsearchTransport(options.elasticsearch);
  
  return winston.createLogger({
    exitOnError: false,         // No cerrar aplicación en errores de log
    defaultMeta: { service: name }, // Metadatos para todos los logs
    transports: [
      new winston.transports.Console(options.console), // Salida a consola
      esTransport                                      // Salida a Elasticsearch
    ]
  });
};