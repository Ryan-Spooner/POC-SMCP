/**
 * Response utility functions for consistent API responses
 */

import { ApiResponse } from '../types/mcp-types';

/**
 * Create a successful API response
 */
export function createApiResponse<T>(
  data: T,
  status: number = 200,
  correlationId?: string
): Response {
  const response: ApiResponse<T> = {
    success: true,
    data,
    timestamp: new Date().toISOString(),
    requestId: correlationId,
  };

  return new Response(JSON.stringify(response), {
    status,
    headers: {
      'Content-Type': 'application/json',
      'X-Correlation-ID': correlationId || '',
    },
  });
}

/**
 * Create an error response
 */
export function createErrorResponse(
  error: string,
  status: number = 400,
  correlationId?: string
): Response {
  const response: ApiResponse = {
    success: false,
    error,
    timestamp: new Date().toISOString(),
    requestId: correlationId,
  };

  return new Response(JSON.stringify(response), {
    status,
    headers: {
      'Content-Type': 'application/json',
      'X-Correlation-ID': correlationId || '',
    },
  });
}

/**
 * Create a JSON-RPC 2.0 response
 */
export function createJsonRpcResponse(
  id: string | number | null,
  result?: unknown,
  error?: { code: number; message: string; data?: unknown }
): Response {
  const response = {
    jsonrpc: '2.0' as const,
    id,
    ...(result !== undefined ? { result } : {}),
    ...(error ? { error } : {}),
  };

  return new Response(JSON.stringify(response), {
    status: error ? 400 : 200,
    headers: {
      'Content-Type': 'application/json',
    },
  });
}

/**
 * Create a Server-Sent Events response for streaming
 */
export function createSseResponse(): Response {
  const { readable } = new TransformStream();

  return new Response(readable, {
    headers: {
      'Content-Type': 'text/event-stream',
      'Cache-Control': 'no-cache',
      'Connection': 'keep-alive',
      'Access-Control-Allow-Origin': '*',
    },
  });
}

/**
 * Send SSE data through a writable stream
 */
export async function sendSseData(
  writer: WritableStreamDefaultWriter<Uint8Array>,
  data: unknown,
  event?: string
): Promise<void> {
  const encoder = new TextEncoder();
  let message = '';

  if (event) {
    message += `event: ${event}\n`;
  }

  message += `data: ${JSON.stringify(data)}\n\n`;

  await writer.write(encoder.encode(message));
}
