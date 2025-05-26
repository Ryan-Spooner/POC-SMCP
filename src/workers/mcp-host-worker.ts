/**
 * POC-SMCP Main Worker
 * Secure MCP Server Hosting on Cloudflare Workers
 *
 * This worker implements the 5-layer security model:
 * 1. Network Layer: Cloudflare's DDoS, SSL/TLS, WAF
 * 2. Application Layer: OAuth 2.1, API keys, input validation
 * 3. Runtime Layer: V8 isolate separation per tenant
 * 4. Data Layer: Encryption, namespace isolation, audit logging
 * 5. AI-Generated Code Security: Validation, monitoring, secure prompting
 */

import { CloudflareEnv, WorkerContext } from '../types/mcp-types';
import { generateCorrelationId } from '../utils/crypto-utils';
import { createApiResponse, createErrorResponse } from '../utils/response-utils';
import { validateRequest } from '../middleware/validation-middleware';
import { authenticateRequest } from '../middleware/auth-middleware';
import { auditLogger } from '../utils/audit-logger';
import { McpServerInstance } from './mcp-server-instance';

/**
 * Main Worker export - entry point for all requests
 */
export default {
  async fetch(request: Request, env: CloudflareEnv, ctx: ExecutionContext): Promise<Response> {
    const correlationId = generateCorrelationId();
    const startTime = Date.now();

    // Create worker context
    const workerContext: WorkerContext = {
      env,
      ctx,
      request,
      correlationId,
    };

    try {
      // Log incoming request
      console.log(`[${correlationId}] Incoming request: ${request.method} ${request.url}`);

      // Handle CORS preflight requests
      if (request.method === 'OPTIONS') {
        return handleCorsPreflightRequest();
      }

      // Route the request
      const response = await routeRequest(workerContext);

      // Add CORS headers to response
      const corsResponse = addCorsHeaders(response);

      // Log response
      const duration = Date.now() - startTime;
      console.log(`[${correlationId}] Response: ${corsResponse.status} (${duration}ms)`);

      return corsResponse;
    } catch (error) {
      // Log error
      console.error(`[${correlationId}] Unhandled error:`, error);

      // Audit log the error
      await auditLogger.logError(workerContext, error as Error);

      // Return generic error response
      return createErrorResponse(
        'Internal server error',
        500,
        correlationId
      );
    }
  },
} satisfies ExportedHandler<CloudflareEnv>;

/**
 * Route incoming requests to appropriate handlers
 */
async function routeRequest(context: WorkerContext): Promise<Response> {
  const url = new URL(context.request.url);
  const path = url.pathname;

  // Health check endpoint
  if (path === '/health') {
    return handleHealthCheck(context);
  }

  // API endpoints
  if (path.startsWith('/api/')) {
    return handleApiRequest(context);
  }

  // MCP protocol endpoints
  if (path.startsWith('/mcp/')) {
    return handleMcpRequest(context);
  }

  // Default 404 response
  return createErrorResponse('Not Found', 404, context.correlationId);
}

/**
 * Handle health check requests
 */
async function handleHealthCheck(context: WorkerContext): Promise<Response> {
  const healthData = {
    status: 'healthy',
    timestamp: new Date().toISOString(),
    environment: context.env.ENVIRONMENT,
    version: '1.0.0',
    correlationId: context.correlationId,
  };

  return createApiResponse(healthData, 200, context.correlationId);
}

/**
 * Handle API requests (authentication, tenant management, etc.)
 */
async function handleApiRequest(context: WorkerContext): Promise<Response> {
  const url = new URL(context.request.url);
  const path = url.pathname;

  // Validate request format
  const validationResult = await validateRequest(context);
  if (!validationResult.isValid) {
    return createErrorResponse(
      validationResult.error || 'Invalid request',
      400,
      context.correlationId
    );
  }

  // Authenticate request
  const authResult = await authenticateRequest(context);
  if (!authResult.isAuthenticated) {
    return createErrorResponse(
      authResult.error || 'Authentication required',
      401,
      context.correlationId
    );
  }

  // Update context with authentication info
  context.session = authResult.session;
  context.tenant = authResult.tenant;

  // Route to specific API handlers
  if (path === '/api/auth/token') {
    return handleTokenRequest(context);
  }

  if (path === '/api/tenants') {
    return handleTenantRequest(context);
  }

  if (path === '/api/servers') {
    return handleServerRequest(context);
  }

  return createErrorResponse('API endpoint not found', 404, context.correlationId);
}

/**
 * Handle MCP protocol requests
 */
async function handleMcpRequest(context: WorkerContext): Promise<Response> {
  // MCP protocol implementation will be added in subsequent tasks
  // This is a placeholder for the MCP server hosting functionality

  return createApiResponse(
    {
      message: 'MCP protocol handler - implementation pending',
      protocol: 'MCP 2025-03-26',
      transport: 'HTTP with SSE',
    },
    200,
    context.correlationId
  );
}

/**
 * Handle authentication token requests
 */
async function handleTokenRequest(context: WorkerContext): Promise<Response> {
  // OAuth 2.1 token handling will be implemented in subsequent tasks
  return createApiResponse(
    { message: 'Token endpoint - implementation pending' },
    200,
    context.correlationId
  );
}

/**
 * Handle tenant management requests
 */
async function handleTenantRequest(context: WorkerContext): Promise<Response> {
  // Tenant management will be implemented in subsequent tasks
  return createApiResponse(
    { message: 'Tenant management - implementation pending' },
    200,
    context.correlationId
  );
}

/**
 * Handle MCP server management requests
 */
async function handleServerRequest(context: WorkerContext): Promise<Response> {
  // MCP server management will be implemented in subsequent tasks
  return createApiResponse(
    { message: 'Server management - implementation pending' },
    200,
    context.correlationId
  );
}

/**
 * Handle CORS preflight requests
 */
function handleCorsPreflightRequest(): Response {
  return new Response(null, {
    status: 204,
    headers: {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type, Authorization, Mcp-Session-Id',
      'Access-Control-Max-Age': '86400',
    },
  });
}

/**
 * Add CORS headers to response
 */
function addCorsHeaders(response: Response): Response {
  const newResponse = new Response(response.body, response);
  newResponse.headers.set('Access-Control-Allow-Origin', '*');
  newResponse.headers.set('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  newResponse.headers.set('Access-Control-Allow-Headers', 'Content-Type, Authorization, Mcp-Session-Id');
  return newResponse;
}

// Export Durable Object for Wrangler
export { McpServerInstance };
