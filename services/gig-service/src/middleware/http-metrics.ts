import { Request, Response, NextFunction } from 'express';
import { httpRequestDuration, httpRequestsTotal } from '@gig/metrics';

/**
 * Normaliza la ruta para evitar alta cardinalidad en Prometheus.
 * Reemplaza IDs (MongoDB, UUID, numéricos) por :id
 */
function normalizeRoute(path: string): string {
  if (!path) return 'unknown';
  return path
    .replace(/\/[0-9a-fA-F]{24}\b/g, '/:id')
    .replace(/\/[0-9a-fA-F-]{36}\b/g, '/:id')
    .replace(/\/\d+\b/g, '/:id')
    .replace(/\?.*$/, '');
}

export function httpMetricsMiddleware(req: Request, res: Response, next: NextFunction): void {
  const start = Date.now();

  res.on('finish', () => {
    const durationSeconds = (Date.now() - start) / 1000;
    const route = normalizeRoute((req.route?.path && req.baseUrl ? req.baseUrl + req.route.path : req.path) || req.path);
    const method = req.method;
    const statusCode = String(res.statusCode);

    httpRequestDuration.observe({ method, route, status_code: statusCode }, durationSeconds);
    httpRequestsTotal.inc({ method, route, status_code: statusCode });
  });

  next();
}
