---
Purpose: Track technology choices, versions, and dependency management decisions.
Updates: Updated by AI/user when dependencies are added, updated, or removed.
Last Reviewed: 2025-05-25
---

# Dependencies & Technology Stack

## Core Dependencies

### Production Dependencies
| Package/Library | Version | Purpose | Installation Command | Notes |
|----------------|---------|---------|---------------------|-------|
| `@cloudflare/workers-types` | `^4.20241218.0` | TypeScript types for Workers | `npm install @cloudflare/workers-types` | Core Workers development |
| `zod` | `^3.22.4` | Schema validation for JSON-RPC | `npm install zod` | Input validation & type safety |
| `jose` | `^5.2.0` | OAuth 2.1 JWT handling | `npm install jose` | Token validation & generation |
| `@noble/hashes` | `^1.3.3` | Cryptographic hashing | `npm install @noble/hashes` | Secure password hashing |
| `@noble/ciphers` | `^0.4.1` | Encryption/decryption | `npm install @noble/ciphers` | Secrets encryption |

### Development Dependencies
| Package/Library | Version | Purpose | Installation Command | Notes |
|----------------|---------|---------|---------------------|-------|
| `wrangler` | `^3.78.12` | Cloudflare Workers CLI | `npm install -D wrangler` | Development & deployment |
| `miniflare` | `^3.20241106.2` | Local Workers testing | `npm install -D miniflare` | Local development server |
| `vitest` | `^1.6.0` | Testing framework | `npm install -D vitest` | Unit & integration testing |
| `typescript` | `^5.3.3` | TypeScript compiler | `npm install -D typescript` | Type checking & compilation |
| `@typescript-eslint/eslint-plugin` | `^6.21.0` | TypeScript linting | `npm install -D @typescript-eslint/eslint-plugin` | Code quality |
| `prettier` | `^3.1.1` | Code formatting | `npm install -D prettier` | Consistent code style |

## Technology Stack

### Runtime & Language
- **Runtime:** Cloudflare Workers (V8 JavaScript Engine)
- **Language:** TypeScript/JavaScript (ES2022+)
- **Protocol:** Model Context Protocol (MCP) 2025-03-26
- **Transport:** Streamable HTTP with Server-Sent Events (SSE)

### Infrastructure (Cloudflare Services)
- **Compute:** Cloudflare Workers (128MB memory, 5min CPU time)
- **Storage:** Cloudflare KV (session management), Cloudflare R2 (object storage)
- **Networking:** Cloudflare DNS (custom domains), Global Edge Network
- **Security:** Built-in DDoS protection, SSL/TLS termination, WAF, OAuth 2.1 endpoints
- **Authentication:** OAuth 2.1 authorization server, API key management, JWT validation

### Development Tools
- **CLI:** Wrangler (Cloudflare Workers development)
- **Package Manager:** npm/yarn/pnpm
- **Build Tool:** Wrangler (built-in bundling and deployment)
- **Local Development:** Miniflare (local Workers testing)

### Monitoring & Observability
- **Analytics:** Cloudflare Analytics (built-in)
- **Logging:** Cloudflare Workers logs and custom logging
- **Health Checks:** Custom health endpoints
- **Performance:** Cloudflare Performance monitoring

## Dependency Decisions Log

### 2025-05-25 - Cloudflare Workers as Primary Runtime
**Decision:** Use Cloudflare Workers exclusively for MCP server hosting
**Rationale:** Native HTTP support, global edge deployment, auto-scaling, built-in security
**Alternatives Considered:** AWS Lambda, Vercel Functions, traditional VPS hosting
**Impact:** Enables global performance, eliminates infrastructure management, reduces costs

### 2025-05-25 - TypeScript as Primary Language
**Decision:** Use TypeScript for all MCP server implementations
**Rationale:** Type safety, excellent tooling, native Cloudflare Workers support
**Alternatives Considered:** JavaScript only, Python (incompatible), Go (limited support)
**Impact:** Improved code quality, better developer experience, easier maintenance

### 2025-05-25 - Zod for Schema Validation
**Decision:** Use Zod for JSON-RPC message validation and type safety
**Rationale:** Runtime type checking, excellent TypeScript integration, comprehensive validation
**Alternatives Considered:** Joi, Yup, manual validation
**Impact:** Ensures data integrity, prevents injection attacks, improves error handling

### 2025-05-25 - JOSE for OAuth 2.1 Implementation
**Decision:** Use JOSE library for JWT handling in OAuth 2.1 implementation
**Rationale:** Standards-compliant, secure, lightweight, excellent Workers compatibility
**Alternatives Considered:** jsonwebtoken, node-jose, custom implementation
**Impact:** Secure token handling, MCP protocol compliance, reduced security risks

### 2025-05-25 - Noble Crypto Libraries for Security
**Decision:** Use @noble/hashes and @noble/ciphers for cryptographic operations
**Rationale:** Audited, lightweight, no dependencies, excellent Workers compatibility
**Alternatives Considered:** Node.js crypto (incompatible), Web Crypto API (limited), other libraries
**Impact:** Secure encryption/hashing, tenant isolation, secrets management

## Troubleshooting

### Common Issues
- **Issue:** [Description of common dependency problem]
- **Solution:** [How to resolve it]
- **Prevention:** [How to avoid it in the future]

---

**Note:** Keep this file updated whenever dependencies are added, removed, or significantly updated.
