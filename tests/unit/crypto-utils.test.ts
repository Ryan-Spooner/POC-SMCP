/**
 * Unit tests for crypto utilities
 */

import { describe, it, expect } from '@jest/globals';
import {
  generateSecureId,
  generateCorrelationId,
  generateSessionId,
  generateApiKey,
  constantTimeCompare,
  sanitizeInput,
  isValidTenantId,
  isValidSessionId,
  isValidApiKey,
} from '../../src/utils/crypto-utils';

describe('Crypto Utils', () => {
  describe('generateSecureId', () => {
    it('should generate a secure ID of default length', () => {
      const id = generateSecureId();
      expect(id).toHaveLength(64); // 32 bytes * 2 hex chars
      expect(id).toMatch(/^[a-f0-9]+$/);
    });

    it('should generate a secure ID of specified length', () => {
      const id = generateSecureId(16);
      expect(id).toHaveLength(32); // 16 bytes * 2 hex chars
      expect(id).toMatch(/^[a-f0-9]+$/);
    });

    it('should generate unique IDs', () => {
      const id1 = generateSecureId();
      const id2 = generateSecureId();
      expect(id1).not.toBe(id2);
    });
  });

  describe('generateCorrelationId', () => {
    it('should generate a correlation ID with correct format', () => {
      const id = generateCorrelationId();
      expect(id).toMatch(/^req_\d+_[a-f0-9]{32}$/);
    });

    it('should generate unique correlation IDs', () => {
      const id1 = generateCorrelationId();
      const id2 = generateCorrelationId();
      expect(id1).not.toBe(id2);
    });
  });

  describe('generateSessionId', () => {
    it('should generate a session ID with tenant prefix', () => {
      const tenantId = 'test-tenant';
      const sessionId = generateSessionId(tenantId);
      expect(sessionId).toMatch(/^sess_test-tenant_[a-f0-9]{48}$/);
    });
  });

  describe('generateApiKey', () => {
    it('should generate an API key with tenant prefix', () => {
      const tenantId = 'test-tenant';
      const apiKey = generateApiKey(tenantId);
      expect(apiKey).toMatch(/^smcp_test-tenant_[a-f0-9]{64}$/);
    });
  });

  describe('constantTimeCompare', () => {
    it('should return true for identical strings', () => {
      const str = 'test-string';
      expect(constantTimeCompare(str, str)).toBe(true);
    });

    it('should return false for different strings', () => {
      expect(constantTimeCompare('test1', 'test2')).toBe(false);
    });

    it('should return false for strings of different lengths', () => {
      expect(constantTimeCompare('short', 'longer-string')).toBe(false);
    });
  });

  describe('sanitizeInput', () => {
    it('should remove HTML tags', () => {
      const input = '<script>alert("xss")</script>';
      const sanitized = sanitizeInput(input);
      expect(sanitized).toBe('scriptalert(xss)/script');
    });

    it('should remove quotes', () => {
      const input = 'test "quoted" and \'single\' quotes';
      const sanitized = sanitizeInput(input);
      expect(sanitized).toBe('test quoted and single quotes');
    });

    it('should remove backslashes', () => {
      const input = 'test\\with\\backslashes';
      const sanitized = sanitizeInput(input);
      expect(sanitized).toBe('testwithbackslashes');
    });

    it('should trim whitespace', () => {
      const input = '  test input  ';
      const sanitized = sanitizeInput(input);
      expect(sanitized).toBe('test input');
    });
  });

  describe('isValidTenantId', () => {
    it('should accept valid tenant IDs', () => {
      expect(isValidTenantId('test-tenant')).toBe(true);
      expect(isValidTenantId('tenant_123')).toBe(true);
      expect(isValidTenantId('ABC123')).toBe(true);
    });

    it('should reject invalid tenant IDs', () => {
      expect(isValidTenantId('ab')).toBe(false); // too short
      expect(isValidTenantId('a'.repeat(65))).toBe(false); // too long
      expect(isValidTenantId('test@tenant')).toBe(false); // invalid chars
      expect(isValidTenantId('test tenant')).toBe(false); // spaces
    });
  });

  describe('isValidSessionId', () => {
    it('should accept valid session IDs', () => {
      const sessionId = generateSessionId('test-tenant');
      expect(isValidSessionId(sessionId)).toBe(true);
    });

    it('should reject invalid session IDs', () => {
      expect(isValidSessionId('invalid-session')).toBe(false);
      expect(isValidSessionId('sess_tenant_short')).toBe(false);
    });
  });

  describe('isValidApiKey', () => {
    it('should accept valid API keys', () => {
      const apiKey = generateApiKey('test-tenant');
      expect(isValidApiKey(apiKey)).toBe(true);
    });

    it('should reject invalid API keys', () => {
      expect(isValidApiKey('invalid-key')).toBe(false);
      expect(isValidApiKey('smcp_tenant_short')).toBe(false);
    });
  });
});
