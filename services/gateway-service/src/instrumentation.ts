/**
 * OpenTelemetry SDK: trazas del gateway y propagación a otros servicios (p. ej. gig).
 * Para HTTP la propagación es automática: el SDK inyecta traceparent en las peticiones
 * (axios usa http bajo el capó) y el servicio destino (gig) extrae el contexto.
 * Envía trazas a Alloy (OTLP) → Tempo → Grafana.
 */
import { NodeSDK } from '@opentelemetry/sdk-node';
import { OTLPTraceExporter } from '@opentelemetry/exporter-trace-otlp-grpc';
import { Resource } from '@opentelemetry/resources';
import { HttpInstrumentation } from '@opentelemetry/instrumentation-http';
import { ExpressInstrumentation } from '@opentelemetry/instrumentation-express';

const otlpEndpoint =
  process.env.OTEL_EXPORTER_OTLP_ENDPOINT || 'http://localhost:4319';

const traceExporter = new OTLPTraceExporter({
  url: otlpEndpoint,
});

const sdk = new NodeSDK({
  resource: new Resource({
    'service.name': 'gateway-service',
  }),
  traceExporter,
  instrumentations: [
    new HttpInstrumentation(),
    new ExpressInstrumentation(),
  ],
});

sdk.start();
