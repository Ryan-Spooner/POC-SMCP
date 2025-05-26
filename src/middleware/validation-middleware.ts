/**
 * Request validation middleware
 * Implements input validation as part of the 5-layer security model
 */

import { WorkerContext } from '../types/mcp-types';
import { sanitizeInput } from '../utils/crypto-utils';

export interface ValidationResult {
  isValid: boolean;
  error?: string;
}

/**
 * Validate incoming request
 */
export async function validateRequest(context: WorkerContext): Promise<ValidationResult> {
  const { request } = context;

  try {
    // Validate HTTP method
    const allowedMethods = ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'];
    if (!allowedMethods.includes(request.method)) {
      return {
        isValid: false,
        error: `Method ${request.method} not allowed`,
      };
    }

    // Validate Content-Type for POST/PUT requests
    if (['POST', 'PUT'].includes(request.method)) {
      const contentType = request.headers.get('Content-Type');
      if (!contentType || !contentType.includes('application/json')) {
        return {
          isValid: false,
          error: 'Content-Type must be application/json',
        };
      }
    }

    // Validate request size
    const contentLength = request.headers.get('Content-Length');
    if (contentLength && parseInt(contentLength) > 1024 * 1024) {
      return {
        isValid: false,
        error: 'Request too large (max 1MB)',
      };
    }

    // Validate URL path
    const url = new URL(request.url);
    const sanitizedPath = sanitizeInput(url.pathname);
    if (sanitizedPath !== url.pathname) {
      return {
        isValid: false,
        error: 'Invalid characters in URL path',
      };
    }

    return { isValid: true };
  } catch (error) {
    return {
      isValid: false,
      error: 'Request validation failed',
    };
  }
}

/**
 * Validate JSON body
 */
export async function validateJsonBody(request: Request): Promise<ValidationResult & { data?: unknown }> {
  try {
    if (!request.body) {
      return { isValid: true };
    }

    const text = await request.text();
    if (!text.trim()) {
      return { isValid: true };
    }

    const data = JSON.parse(text);
    return { isValid: true, data };
  } catch (error) {
    return {
      isValid: false,
      error: 'Invalid JSON in request body',
    };
  }
}
