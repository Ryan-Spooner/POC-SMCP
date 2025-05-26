/**
 * MCP Protocol Types and Interfaces
 * Based on MCP 2025-03-26 specification
 */

import { z } from 'zod';

// JSON-RPC 2.0 Base Types
export const JsonRpcRequestSchema = z.object({
  jsonrpc: z.literal('2.0'),
  id: z.union([z.string(), z.number(), z.null()]),
  method: z.string(),
  params: z.record(z.unknown()).optional(),
});

export const JsonRpcResponseSchema = z.object({
  jsonrpc: z.literal('2.0'),
  id: z.union([z.string(), z.number(), z.null()]),
  result: z.unknown().optional(),
  error: z
    .object({
      code: z.number(),
      message: z.string(),
      data: z.unknown().optional(),
    })
    .optional(),
});

export type JsonRpcRequest = z.infer<typeof JsonRpcRequestSchema>;
export type JsonRpcResponse = z.infer<typeof JsonRpcResponseSchema>;

// MCP Session Management
export const SessionContextSchema = z.object({
  tenantId: z.string(),
  sessionId: z.string(),
  permissions: z.array(z.string()),
  expiresAt: z.string(),
  createdAt: z.string(),
  lastActivity: z.string(),
});

export type SessionContext = z.infer<typeof SessionContextSchema>;

// MCP Server Configuration
export const McpServerConfigSchema = z.object({
  id: z.string(),
  name: z.string(),
  version: z.string(),
  description: z.string().optional(),
  endpoints: z.array(z.string()),
  capabilities: z.array(z.string()),
  tenantId: z.string(),
  status: z.enum(['active', 'inactive', 'suspended']),
  createdAt: z.string(),
  updatedAt: z.string(),
});

export type McpServerConfig = z.infer<typeof McpServerConfigSchema>;

// Tenant Configuration
export const TenantConfigSchema = z.object({
  id: z.string(),
  name: z.string(),
  endpoints: z.array(z.string()),
  quotas: z.object({
    maxServers: z.number(),
    maxRequestsPerMinute: z.number(),
    maxStorageMB: z.number(),
  }),
  roles: z.array(
    z.object({
      name: z.string(),
      permissions: z.array(z.string()),
    })
  ),
  status: z.enum(['active', 'suspended', 'deleted']),
  createdAt: z.string(),
  updatedAt: z.string(),
});

export type TenantConfig = z.infer<typeof TenantConfigSchema>;

// API Response Types
export const ApiResponseSchema = z.object({
  success: z.boolean(),
  data: z.unknown().optional(),
  error: z.string().optional(),
  timestamp: z.string(),
  requestId: z.string().optional(),
});

export type ApiResponse<T = unknown> = {
  success: boolean;
  data?: T;
  error?: string;
  timestamp: string;
  requestId?: string | undefined;
};

// Authentication Types
export const OAuthTokenSchema = z.object({
  access_token: z.string(),
  token_type: z.literal('Bearer'),
  expires_in: z.number(),
  refresh_token: z.string().optional(),
  scope: z.string().optional(),
});

export type OAuthToken = z.infer<typeof OAuthTokenSchema>;

export const ApiKeySchema = z.object({
  keyId: z.string(),
  tenantId: z.string(),
  permissions: z.array(z.string()),
  createdAt: z.string(),
  expiresAt: z.string(),
  lastUsed: z.string().optional(),
});

export type ApiKey = z.infer<typeof ApiKeySchema>;

// Audit Log Types
export const AuditLogEntrySchema = z.object({
  tenantId: z.string(),
  action: z.string(),
  resource: z.string(),
  result: z.enum(['success', 'failure', 'error']),
  timestamp: z.string(),
  userId: z.string().optional(),
  sessionId: z.string().optional(),
  details: z.record(z.unknown()).optional(),
  correlationId: z.string(),
});

export type AuditLogEntry = z.infer<typeof AuditLogEntrySchema>;

// Error Types
export enum McpErrorCode {
  INVALID_REQUEST = -32600,
  METHOD_NOT_FOUND = -32601,
  INVALID_PARAMS = -32602,
  INTERNAL_ERROR = -32603,
  PARSE_ERROR = -32700,
  UNAUTHORIZED = -32001,
  FORBIDDEN = -32002,
  NOT_FOUND = -32003,
  RATE_LIMITED = -32004,
  TENANT_SUSPENDED = -32005,
}

export interface McpError {
  code: McpErrorCode;
  message: string;
  data?: unknown;
}

// Environment Types
export interface CloudflareEnv {
  SESSIONS: KVNamespace;
  TENANT_CONFIG: KVNamespace;
  AUDIT_LOGS: KVNamespace;
  MCP_DATA: R2Bucket;
  MCP_SERVER_INSTANCE: DurableObjectNamespace;
  ENVIRONMENT: string;
  LOG_LEVEL: string;
  JWT_SECRET?: string;
  OAUTH_CLIENT_ID?: string;
  OAUTH_CLIENT_SECRET?: string;
}

// Worker Context Types
export interface WorkerContext {
  env: CloudflareEnv;
  ctx: ExecutionContext;
  request: Request;
  session?: SessionContext | undefined;
  tenant?: TenantConfig | undefined;
  correlationId: string;
}
