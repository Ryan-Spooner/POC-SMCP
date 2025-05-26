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
* **MCP Messages:** JSON-RPC 2.0 format with strict schema validation
* **Session Context:** `{ tenantId: string, sessionId: string, permissions: string[] }`
* **API Responses:** `{ success: boolean, data?: any, error?: string, timestamp: string }`
* **Tenant Configuration:** `{ id: string, name: string, endpoints: string[], quotas: object }`

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
* **Input Validation:** Strict JSON-RPC schema validation for all MCP messages
* **Authentication:** API key-based authentication with tenant-scoped permissions
* **Secrets Management:** Cloudflare environment variables for sensitive configuration
* **Tenant Isolation:** V8 isolate separation + storage namespace isolation
* **Rate Limiting:** Per-tenant rate limiting with configurable quotas

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
