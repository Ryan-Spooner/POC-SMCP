/**
 * Audit logging utility
 * Implements comprehensive audit logging as part of the 5-layer security model
 */

import { WorkerContext, AuditLogEntry } from '../types/mcp-types';

class AuditLogger {
  /**
   * Log a successful action
   */
  async logSuccess(
    context: WorkerContext,
    action: string,
    resource: string,
    details?: Record<string, unknown>
  ): Promise<void> {
    await this.logEntry(context, action, resource, 'success', details);
  }

  /**
   * Log a failed action
   */
  async logFailure(
    context: WorkerContext,
    action: string,
    resource: string,
    details?: Record<string, unknown>
  ): Promise<void> {
    await this.logEntry(context, action, resource, 'failure', details);
  }

  /**
   * Log an error
   */
  async logError(
    context: WorkerContext,
    error: Error,
    action?: string,
    resource?: string
  ): Promise<void> {
    const details = {
      error: error.message,
      stack: error.stack,
    };

    await this.logEntry(
      context,
      action || 'error',
      resource || 'unknown',
      'error',
      details
    );
  }

  /**
   * Log an audit entry
   */
  private async logEntry(
    context: WorkerContext,
    action: string,
    resource: string,
    result: 'success' | 'failure' | 'error',
    details?: Record<string, unknown>
  ): Promise<void> {
    try {
      const entry: AuditLogEntry = {
        tenantId: context.tenant?.id || 'unknown',
        action,
        resource,
        result,
        timestamp: new Date().toISOString(),
        userId: context.session?.tenantId,
        sessionId: context.session?.sessionId,
        details,
        correlationId: context.correlationId,
      };

      // Store in KV with tenant-scoped key
      const key = `audit:${entry.tenantId}:${Date.now()}:${context.correlationId}`;
      await context.env.AUDIT_LOGS.put(key, JSON.stringify(entry), {
        expirationTtl: 30 * 24 * 60 * 60, // 30 days retention
      });

      // Also log to console for development
      if (context.env.ENVIRONMENT === 'development') {
        console.log(`[AUDIT] ${entry.tenantId}:${action}:${resource}:${result}`, details);
      }
    } catch (error) {
      // Fallback to console logging if KV fails
      console.error('Failed to write audit log:', error);
      console.log(`[AUDIT-FALLBACK] ${action}:${resource}:${result}`, details);
    }
  }

  /**
   * Retrieve audit logs for a tenant
   */
  async getAuditLogs(
    context: WorkerContext,
    tenantId: string,
    limit: number = 100
  ): Promise<AuditLogEntry[]> {
    try {
      const prefix = `audit:${tenantId}:`;
      const list = await context.env.AUDIT_LOGS.list({ prefix, limit });
      
      const entries: AuditLogEntry[] = [];
      for (const key of list.keys) {
        const value = await context.env.AUDIT_LOGS.get(key.name);
        if (value) {
          entries.push(JSON.parse(value) as AuditLogEntry);
        }
      }

      // Sort by timestamp descending
      return entries.sort((a, b) => 
        new Date(b.timestamp).getTime() - new Date(a.timestamp).getTime()
      );
    } catch (error) {
      console.error('Failed to retrieve audit logs:', error);
      return [];
    }
  }
}

export const auditLogger = new AuditLogger();
