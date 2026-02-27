import { verifyGatewayRequest } from '@kevindeveloper95/jobapp-shared';
import { Application } from 'express';
import { gigRoutes } from '@gig/routes/gig';
import { healthRoutes } from '@gig/routes/health';
import { metricsHandler } from '@gig/metrics';

const BASE_PATH = '/api/v1/gig';

const appRoutes = (app: Application): void => {
  app.use('', healthRoutes());
  app.get('/metrics', metricsHandler);
  app.use(BASE_PATH, verifyGatewayRequest,  gigRoutes());
};

export { appRoutes };