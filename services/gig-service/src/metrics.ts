import promClient from 'prom-client';
import { Request, Response } from 'express';

const register = new promClient.Registry();

promClient.collectDefaultMetrics({ register, prefix: 'gig_service_' });

export const gigsCreatedTotal = new promClient.Counter({
  name: 'gig_service_gigs_created_total',
  help: 'Total number of gigs created',
  labelNames: ['categories'],
  registers: [register]
});

export const gigsUpdatedTotal = new promClient.Counter({
  name: 'gig_service_gigs_updated_total',
  help: 'Total number of gig updates',
  labelNames: ['type'],
  registers: [register]
});

export const gigsDeletedTotal = new promClient.Counter({
  name: 'gig_service_gigs_deleted_total',
  help: 'Total number of gigs deleted',
  registers: [register]
});

export const gigViewsTotal = new promClient.Counter({
  name: 'gig_service_gig_views_total',
  help: 'Total number of gig detail views (by id)',
  registers: [register]
});

export const gigSearchRequestsTotal = new promClient.Counter({
  name: 'gig_service_search_requests_total',
  help: 'Total number of search requests',
  labelNames: ['type'],
  registers: [register]
});

export const httpRequestDuration = new promClient.Histogram({
  name: 'gig_service_http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'status_code'],
  buckets: [0.01, 0.05, 0.1, 0.25, 0.5, 1, 2.5, 5],
  registers: [register]
});

export const httpRequestsTotal = new promClient.Counter({
  name: 'gig_service_http_requests_total',
  help: 'Total HTTP requests by method, route and status code',
  labelNames: ['method', 'route', 'status_code'],
  registers: [register]
});

export async function metricsHandler(_req: Request, res: Response): Promise<void> {
  res.setHeader('Content-Type', register.contentType);
  res.end(await register.metrics());
}
