/**
 * Authentication middleware
 * Implements OAuth 2.1 and API key authentication as part of the 5-layer security model
 */

import { WorkerContext, SessionContext, TenantConfig } from '../types/mcp-types';
import { isValidApiKey, isValidSessionId } from '../utils/crypto-utils';

export interface AuthResult {
  isAuthenticated: boolean;
  session?: SessionContext | undefined;
  tenant?: TenantConfig | undefined;
  error?: string;
}

/**
 * Authenticate incoming request
 */
export async function authenticateRequest(context: WorkerContext): Promise<AuthResult> {
  const { request } = context;

  try {
    // Check for API key authentication
    const apiKey = extractApiKey(request);
    if (apiKey) {
      return await authenticateApiKey(context, apiKey);
    }

    // Check for session-based authentication
    const sessionId = extractSessionId(request);
    if (sessionId) {
      return await authenticateSession(context, sessionId);
    }

    // Check for OAuth bearer token
    const bearerToken = extractBearerToken(request);
    if (bearerToken) {
      return await authenticateBearerToken(context, bearerToken);
    }

    // No authentication provided
    return {
      isAuthenticated: false,
      error: 'Authentication required',
    };
  } catch (error) {
    return {
      isAuthenticated: false,
      error: 'Authentication failed',
    };
  }
}

/**
 * Extract API key from request headers
 */
function extractApiKey(request: Request): string | null {
  const authHeader = request.headers.get('Authorization');
  if (authHeader && authHeader.startsWith('ApiKey ')) {
    return authHeader.substring(7);
  }
  return null;
}

/**
 * Extract session ID from request headers
 */
function extractSessionId(request: Request): string | null {
  return request.headers.get('Mcp-Session-Id');
}

/**
 * Extract bearer token from request headers
 */
function extractBearerToken(request: Request): string | null {
  const authHeader = request.headers.get('Authorization');
  if (authHeader && authHeader.startsWith('Bearer ')) {
    return authHeader.substring(7);
  }
  return null;
}

/**
 * Authenticate using API key
 */
async function authenticateApiKey(_context: WorkerContext, apiKey: string): Promise<AuthResult> {
  // Validate API key format
  if (!isValidApiKey(apiKey)) {
    return {
      isAuthenticated: false,
      error: 'Invalid API key format',
    };
  }

  // TODO: Implement API key validation against KV storage
  // This will be implemented in subsequent tasks

  return {
    isAuthenticated: false,
    error: 'API key authentication not yet implemented',
  };
}

/**
 * Authenticate using session ID
 */
async function authenticateSession(_context: WorkerContext, sessionId: string): Promise<AuthResult> {
  // Validate session ID format
  if (!isValidSessionId(sessionId)) {
    return {
      isAuthenticated: false,
      error: 'Invalid session ID format',
    };
  }

  // TODO: Implement session validation against KV storage
  // This will be implemented in subsequent tasks

  return {
    isAuthenticated: false,
    error: 'Session authentication not yet implemented',
  };
}

/**
 * Authenticate using OAuth bearer token
 */
async function authenticateBearerToken(_context: WorkerContext, _token: string): Promise<AuthResult> {
  // TODO: Implement JWT token validation
  // This will be implemented in subsequent tasks

  return {
    isAuthenticated: false,
    error: 'Bearer token authentication not yet implemented',
  };
}
