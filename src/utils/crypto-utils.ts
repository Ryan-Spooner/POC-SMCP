/**
 * Cryptographic utilities for secure operations
 * Following the 5-layer security model requirements
 */

/**
 * Generate a cryptographically secure random string
 */
export function generateSecureId(length: number = 32): string {
  const array = new Uint8Array(length);
  crypto.getRandomValues(array);
  return Array.from(array, byte => byte.toString(16).padStart(2, '0')).join('');
}

/**
 * Generate a correlation ID for request tracking
 */
export function generateCorrelationId(): string {
  return `req_${Date.now()}_${generateSecureId(16)}`;
}

/**
 * Generate a session ID with tenant prefix
 */
export function generateSessionId(tenantId: string): string {
  return `sess_${tenantId}_${generateSecureId(24)}`;
}

/**
 * Generate an API key with tenant scoping
 */
export function generateApiKey(tenantId: string): string {
  return `smcp_${tenantId}_${generateSecureId(32)}`;
}

/**
 * Hash a string using SHA-256
 */
export async function hashString(input: string): Promise<string> {
  const encoder = new TextEncoder();
  const data = encoder.encode(input);
  const hashBuffer = await crypto.subtle.digest('SHA-256', data);
  const hashArray = Array.from(new Uint8Array(hashBuffer));
  return hashArray.map(b => b.toString(16).padStart(2, '0')).join('');
}

/**
 * Encrypt data using AES-256-GCM
 */
export async function encryptData(
  data: string,
  key: CryptoKey
): Promise<{ encrypted: string; iv: string }> {
  const encoder = new TextEncoder();
  const dataBuffer = encoder.encode(data);
  const iv = crypto.getRandomValues(new Uint8Array(12));

  const encrypted = await crypto.subtle.encrypt(
    {
      name: 'AES-GCM',
      iv: iv,
    },
    key,
    dataBuffer
  );

  return {
    encrypted: Array.from(new Uint8Array(encrypted))
      .map(b => b.toString(16).padStart(2, '0'))
      .join(''),
    iv: Array.from(iv)
      .map(b => b.toString(16).padStart(2, '0'))
      .join(''),
  };
}

/**
 * Decrypt data using AES-256-GCM
 */
export async function decryptData(
  encryptedHex: string,
  ivHex: string,
  key: CryptoKey
): Promise<string> {
  const encrypted = new Uint8Array(
    encryptedHex.match(/.{1,2}/g)?.map(byte => parseInt(byte, 16)) ?? []
  );
  const iv = new Uint8Array(
    ivHex.match(/.{1,2}/g)?.map(byte => parseInt(byte, 16)) ?? []
  );

  const decrypted = await crypto.subtle.decrypt(
    {
      name: 'AES-GCM',
      iv: iv,
    },
    key,
    encrypted
  );

  const decoder = new TextDecoder();
  return decoder.decode(decrypted);
}

/**
 * Generate a CryptoKey for AES-256-GCM encryption
 */
export async function generateEncryptionKey(): Promise<CryptoKey> {
  return await crypto.subtle.generateKey(
    {
      name: 'AES-GCM',
      length: 256,
    },
    true,
    ['encrypt', 'decrypt']
  );
}

/**
 * Import a key from raw bytes
 */
export async function importEncryptionKey(keyBytes: Uint8Array): Promise<CryptoKey> {
  return await crypto.subtle.importKey(
    'raw',
    keyBytes,
    {
      name: 'AES-GCM',
      length: 256,
    },
    false,
    ['encrypt', 'decrypt']
  );
}

/**
 * Constant-time string comparison to prevent timing attacks
 */
export function constantTimeCompare(a: string, b: string): boolean {
  if (a.length !== b.length) {
    return false;
  }

  let result = 0;
  for (let i = 0; i < a.length; i++) {
    result |= a.charCodeAt(i) ^ b.charCodeAt(i);
  }

  return result === 0;
}

/**
 * Sanitize input to prevent injection attacks
 */
export function sanitizeInput(input: string): string {
  return input
    .replace(/[<>]/g, '') // Remove potential HTML tags
    .replace(/['"]/g, '') // Remove quotes
    .replace(/[\\]/g, '') // Remove backslashes
    .trim();
}

/**
 * Validate tenant ID format
 */
export function isValidTenantId(tenantId: string): boolean {
  return /^[a-zA-Z0-9_-]{3,64}$/.test(tenantId);
}

/**
 * Validate session ID format
 */
export function isValidSessionId(sessionId: string): boolean {
  return /^sess_[a-zA-Z0-9_-]+_[a-f0-9]{48}$/.test(sessionId);
}

/**
 * Validate API key format
 */
export function isValidApiKey(apiKey: string): boolean {
  return /^smcp_[a-zA-Z0-9_-]+_[a-f0-9]{64}$/.test(apiKey);
}
