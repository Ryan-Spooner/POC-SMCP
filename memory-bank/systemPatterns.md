---
Purpose: Documents recurring design patterns, coding standards, and architectural choices specific to this project.
Updates: Appended or refined by AI/user as patterns emerge or standards are set.
Last Reviewed: 2025-05-25
---

# System Patterns & Conventions

## Coding Style / Linting
* **Language:** TypeScript with strict mode enabled
* **Formatter:** Prettier (standard configuration)
* **Linter:** ESLint with TypeScript rules
* **Style Guide:** Cloudflare Workers TypeScript conventions
* **Documentation:** JSDoc comments for all public APIs
* **Type Hinting:** Mandatory for all function signatures and interfaces

## Common Data Structures
* **MCP Messages:** JSON-RPC 2.0 format with strict schema validation using Zod
* **Session Context:** `{ tenantId: string, sessionId: string, permissions: string[], expiresAt: string }`
* **API Responses:** `{ success: boolean, data?: any, error?: string, timestamp: string }`
* **Tenant Configuration:** `{ id: string, name: string, endpoints: string[], quotas: object, roles: Role[] }`
* **OAuth Token:** `{ access_token: string, token_type: "Bearer", expires_in: number, refresh_token?: string }`
* **API Key:** `{ keyId: string, tenantId: string, permissions: string[], createdAt: string, expiresAt: string }`
* **Audit Log Entry:** `{ tenantId: string, action: string, resource: string, result: string, timestamp: string, details?: object }`

## Architectural Patterns
* **Multi-Tenant Isolation:** Dedicated Worker instances with V8 isolate separation
* **Storage Namespacing:** `tenant-{id}:resource-type:{resource-id}` for KV keys
* **Session Management:** HTTP headers (`Mcp-Session-Id`) with KV-backed validation
* **Error Handling:** Structured error responses with tenant-scoped logging
* **Auto-Scaling:** Cloudflare's native edge distribution with keep-alive optimization

## Naming Conventions
* **Variables/Functions:** camelCase (TypeScript standard)
* **Constants:** UPPER_SNAKE_CASE
* **Classes/Interfaces:** PascalCase
* **Files:** kebab-case.ts
* **KV Keys:** tenant-{id}:resource-type:{resource-id}
* **Environment Variables:** UPPER_SNAKE_CASE

## Error Handling Strategy
* **MCP Errors:** JSON-RPC 2.0 error format with standardized error codes
* **HTTP Errors:** Structured responses with error type, message, and tenant context
* **Validation:** Input validation at API boundaries with detailed error messages
* **Logging:** Tenant-scoped error logging with request correlation IDs

## Security Considerations

### Authentication Patterns
* **OAuth 2.1 Implementation:** Full MCP protocol compliance with PKCE, dynamic client registration, metadata discovery
* **API Key Format:** `smcp_<tenantId>_<randomBytes>` with tenant scoping and automated rotation
* **Token Validation:** JWT validation using JOSE library with proper signature verification
* **Session Management:** Secure session tokens with time-limited expiration and tenant validation

### Authorization Patterns
* **Role-Based Access Control:** Admin, MCP User, Read-Only roles with granular permissions
* **Permission Format:** `{ resource: string, actions: string[], conditions?: object }`
* **Tenant Scoping:** All permissions scoped to specific tenant with cross-tenant access prevention
* **Authorization Middleware:** `async function authorize(request: Request, requiredPermissions: Permission[])`

### Input Validation & Security
* **Schema Validation:** Zod schemas for all JSON-RPC messages with strict type checking
* **Request Size Limits:** 1MB max request size, 1000 requests/minute per tenant
* **Sanitization:** Input sanitization to prevent injection attacks and XSS
* **Error Handling:** Sanitized error responses with comprehensive audit logging

### Secrets Management Patterns
* **Environment Variables:** Encrypted secrets via Wrangler CLI (`wrangler secret put KEY_NAME`)
* **KV Storage:** Encrypted configuration with tenant prefixes and AES-256-GCM encryption
* **Key Rotation:** Automated rotation with configurable policies and grace periods
* **Access Patterns:** Least privilege access with tenant-scoped secret retrieval

### Multi-Tenant Isolation
* **Worker Isolation:** Dedicated Worker instances per tenant with V8 isolate separation
* **Storage Isolation:** Tenant-prefixed KV keys and bucket-level R2 separation
* **Network Isolation:** Tenant-scoped rate limiting and request routing
* **Audit Isolation:** Tenant-scoped logging with 30-day retention and correlation IDs

### AI-Assisted Coding Security
* **Code Validation:** Mandatory security review for all AI-generated code sections
* **Metadata Tracking:** `{ source: 'human' | 'ai-assisted' | 'ai-generated', aiTool?: string, securityReviewed: boolean }`
* **Secure Prompting:** Security-focused prompts and context validation for AI interactions
* **Vulnerability Scanning:** Enhanced SAST/DAST scanning specifically for AI-generated code patterns
* **Human Oversight:** Required security expert review for AI-generated authentication and authorization code
* **Behavioral Monitoring:** Runtime monitoring of AI-generated code for anomalous behavior patterns

## Testing Patterns
* **Framework:** Miniflare for local Workers testing, Jest for unit tests
* **Coverage Target:** 80% minimum for core MCP protocol handling
* **Test Structure:** Arrange-Act-Assert pattern with tenant isolation validation
* **Integration Tests:** End-to-end MCP client-server communication testing

## Performance Considerations
* **Response Time Targets:** < 100ms for MCP message handling, < 400ms cold start
* **Memory Limits:** 128MB per Worker instance with efficient memory usage
* **Caching Strategy:** KV caching for session data, response caching for static resources
* **Cold Start Mitigation:** Keep-alive mechanisms and resource preloading

## Monitoring & Logging Standards
* **Log Levels:** ERROR, WARN, INFO, DEBUG with tenant context
* **Error Monitoring:** Cloudflare Workers analytics and custom error tracking
* **Health Checks:** /health endpoint with tenant-specific status checks
* **Performance Metrics:** Request latency, error rates, tenant resource usage

## Deployment Patterns
* **Deployment Strategy:** Wrangler-based deployment with environment promotion
* **Environment Management:** development, staging, production with tenant isolation
* **Rollback Strategy:** Wrangler rollback capabilities with version management
