# SMCP Architecture Design
**Task:** SMCP-001-03 - Architecture Design  
**Date:** 2025-05-25  
**Status:** Completed  

## Executive Summary

This document defines the comprehensive architecture for the Secure MCP (SMCP) platform POC, focusing on multi-tenant MCP server hosting on Cloudflare infrastructure. The architecture leverages Cloudflare Workers' V8 isolate model for security, native auto-scaling capabilities, and the Streamable HTTP transport protocol for MCP compatibility.

## Architecture Overview

### High-Level System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    SMCP Platform Architecture                   │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────┐  HTTP/SSE   ┌─────────────────────────────────┐ │
│  │ MCP Clients │ ──────────► │      Cloudflare Edge Network   │ │
│  │ (Claude,    │  JSON-RPC   │                                 │ │
│  │  Custom)    │             │  ┌─────────────────────────────┐ │ │
│  └─────────────┘             │  │    Global Load Balancer     │ │ │
│                               │  │   (Automatic Routing)       │ │ │
│                               │  └─────────────────────────────┘ │ │
│                               │              │                  │ │
│                               │              ▼                  │ │
│                               │  ┌─────────────────────────────┐ │ │
│                               │  │   MCP Server Workers        │ │ │
│                               │  │   (Multi-Tenant Isolated)   │ │ │
│                               │  └─────────────────────────────┘ │ │
│                               └─────────────────────────────────┘ │
│                                              │                    │
│                                              ▼                    │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │              Cloudflare Services Layer                     │ │
│  │                                                             │ │
│  │  ┌─────────────┐ ┌─────────────┐ ┌─────────────────────────┐ │ │
│  │  │ KV Storage  │ │ R2 Storage  │ │    DNS & Domains        │ │ │
│  │  │ (Sessions,  │ │ (Large Data,│ │  (Custom Endpoints,     │ │ │
│  │  │  Config)    │ │  Files)     │ │   SSL Certificates)     │ │ │
│  │  └─────────────┘ └─────────────┘ └─────────────────────────┘ │ │
│  └─────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

### Core Components

1. **MCP Server Workers** - Isolated Cloudflare Workers hosting individual MCP servers
2. **Global Load Balancer** - Cloudflare's automatic request routing and distribution
3. **Storage Services** - KV for sessions/config, R2 for large data storage
4. **DNS & Domains** - Custom domain management with automatic SSL

## Multi-Tenant Hosting Architecture

### Tenant Isolation Model

```
┌─────────────────────────────────────────────────────────────────┐
│                    Multi-Tenant Isolation                      │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Tenant A                    Tenant B                    Tenant C│
│  ┌─────────────────┐         ┌─────────────────┐         ┌──────┐│
│  │ Worker Instance │         │ Worker Instance │         │ ...  ││
│  │ ┌─────────────┐ │         │ ┌─────────────┐ │         │      ││
│  │ │ V8 Isolate  │ │         │ │ V8 Isolate  │ │         │      ││
│  │ │ MCP Server  │ │         │ │ MCP Server  │ │         │      ││
│  │ └─────────────┘ │         │ └─────────────┘ │         │      ││
│  └─────────────────┘         └─────────────────┘         └──────┘│
│          │                           │                           │
│          ▼                           ▼                           │
│  ┌─────────────────┐         ┌─────────────────┐                 │
│  │ KV Namespace    │         │ KV Namespace    │                 │
│  │ tenant-a:*      │         │ tenant-b:*      │                 │
│  └─────────────────┘         └─────────────────┘                 │
│          │                           │                           │
│          ▼                           ▼                           │
│  ┌─────────────────┐         ┌─────────────────┐                 │
│  │ R2 Bucket       │         │ R2 Bucket       │                 │
│  │ /tenant-a/      │         │ /tenant-b/      │                 │
│  └─────────────────┘         └─────────────────┘                 │
└─────────────────────────────────────────────────────────────────┘
```

### Isolation Strategies

#### 1. **Worker-Level Isolation**
- **Separate Worker per Tenant:** Each MCP server runs in dedicated Worker instance
- **V8 Isolate Security:** Cloudflare's V8 isolates provide memory and execution isolation
- **Environment Variables:** Tenant-specific configuration via encrypted environment variables
- **Custom Domains:** Optional custom domains per tenant (e.g., `tenant-a.smcp.example.com`)

#### 2. **Storage Isolation**
- **KV Namespacing:** Tenant prefixes for all KV keys (`tenant-{id}:session:{session-id}`)
- **R2 Bucket Separation:** Dedicated buckets or prefix-based isolation (`/tenant-{id}/`)
- **Access Control:** Worker bindings restrict access to tenant-specific storage

#### 3. **Network Isolation**
- **Request Routing:** Subdomain or path-based routing to correct tenant Worker
- **Session Management:** Tenant-scoped session IDs prevent cross-tenant access
- **Rate Limiting:** Per-tenant rate limiting and quota management

### Tenant Provisioning Flow

```
1. Tenant Registration
   ├── Generate unique tenant ID
   ├── Create dedicated Worker instance
   ├── Configure environment variables
   └── Set up storage namespaces

2. MCP Server Deployment
   ├── Deploy MCP server code to tenant Worker
   ├── Configure KV namespace bindings
   ├── Set up R2 bucket access
   └── Configure custom domain (optional)

3. Client Access
   ├── Provide tenant-specific endpoint
   ├── Configure authentication tokens
   ├── Set up session management
   └── Enable monitoring and logging
```

## Security Isolation Patterns

### Security Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                      Security Layers                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Layer 1: Network Security                                     │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │ • DDoS Protection (Automatic)                               │ │
│  │ • SSL/TLS Termination (Automatic)                           │ │
│  │ • WAF Rules (Configurable)                                  │ │
│  │ • Rate Limiting (Per-tenant)                                │ │
│  └─────────────────────────────────────────────────────────────┘ │
│                              │                                  │
│                              ▼                                  │
│  Layer 2: Application Security                                 │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │ • Authentication (API Keys, JWT)                            │ │
│  │ • Authorization (Tenant-scoped)                             │ │
│  │ • Input Validation (JSON-RPC)                               │ │
│  │ • Session Management (Secure)                               │ │
│  └─────────────────────────────────────────────────────────────┘ │
│                              │                                  │
│                              ▼                                  │
│  Layer 3: Runtime Isolation                                    │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │ • V8 Isolate Separation                                     │ │
│  │ • Memory Isolation (128MB per Worker)                       │ │
│  │ • CPU Time Limits (5min max)                                │ │
│  │ • Network Restrictions (Subrequest limits)                  │ │
│  └─────────────────────────────────────────────────────────────┘ │
│                              │                                  │
│                              ▼                                  │
│  Layer 4: Data Security                                        │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │ • Storage Encryption (At rest)                              │ │
│  │ • Namespace Isolation (KV/R2)                               │ │
│  │ • Access Control (Binding-based)                            │ │
│  │ • Audit Logging (Request/Response)                          │ │
│  └─────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

### Security Implementation Patterns

#### 1. **Authentication & Authorization**
```typescript
// Tenant authentication middleware
async function authenticateTenant(request: Request): Promise<TenantContext> {
  const authHeader = request.headers.get('Authorization');
  const tenantId = await validateApiKey(authHeader);
  return { tenantId, permissions: await getTenantPermissions(tenantId) };
}

// Session-based authorization
async function authorizeSession(sessionId: string, tenantId: string): Promise<boolean> {
  const sessionKey = `tenant-${tenantId}:session:${sessionId}`;
  const session = await KV.get(sessionKey);
  return session !== null && isValidSession(session);
}
```

#### 2. **Input Validation & Sanitization**
```typescript
// JSON-RPC message validation
function validateMcpMessage(message: any): McpMessage {
  const schema = getMcpMessageSchema();
  const result = schema.safeParse(message);
  if (!result.success) {
    throw new McpError('Invalid message format', result.error);
  }
  return result.data;
}
```

#### 3. **Secrets Management**
- **Environment Variables:** Encrypted tenant-specific secrets
- **KV Storage:** Encrypted configuration data with tenant prefixes
- **API Keys:** Secure generation and rotation mechanisms
- **Session Tokens:** Time-limited, cryptographically secure tokens

## Auto-Scaling and Load Balancing

### Auto-Scaling Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    Auto-Scaling Strategy                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Request Volume Monitoring                                      │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │ • Real-time request metrics                                 │ │
│  │ • CPU utilization tracking                                  │ │
│  │ • Memory usage monitoring                                   │ │
│  │ • Response time analysis                                    │ │
│  └─────────────────────────────────────────────────────────────┘ │
│                              │                                  │
│                              ▼                                  │
│  Cloudflare Auto-Scaling                                       │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │ • Instant scaling (0 to high load)                          │ │
│  │ • Global edge distribution                                  │ │
│  │ • Automatic load balancing                                  │ │
│  │ • Cold start optimization                                   │ │
│  └─────────────────────────────────────────────────────────────┘ │
│                              │                                  │
│                              ▼                                  │
│  Performance Optimization                                      │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │ • Connection pooling                                        │ │
│  │ • Response caching                                          │ │
│  │ • Keep-alive strategies                                     │ │
│  │ • Resource preloading                                       │ │
│  └─────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

### Load Balancing Strategy

#### 1. **Geographic Distribution**
- **Edge Deployment:** Automatic deployment to 300+ Cloudflare locations
- **Latency Optimization:** Requests routed to nearest edge location
- **Failover:** Automatic failover to healthy edge locations
- **Global Anycast:** DNS-based geographic load distribution

#### 2. **Request Routing**
```typescript
// Intelligent request routing
async function routeRequest(request: Request): Promise<Response> {
  const tenantId = extractTenantId(request);
  const workerInstance = await getOptimalWorkerInstance(tenantId, {
    location: request.cf?.colo,
    load: await getCurrentLoad(tenantId),
    health: await getHealthStatus(tenantId)
  });
  
  return await forwardToWorker(workerInstance, request);
}
```

#### 3. **Scaling Triggers**
- **Request Volume:** Automatic scaling based on request rate
- **Response Time:** Scale up when latency exceeds thresholds
- **Error Rate:** Additional capacity during error spikes
- **Resource Utilization:** CPU and memory usage monitoring

### Performance Optimization Patterns

#### 1. **Cold Start Mitigation**
```typescript
// Keep-alive mechanism
const KEEP_ALIVE_INTERVAL = 30000; // 30 seconds
setInterval(async () => {
  await fetch('/health', { method: 'HEAD' });
}, KEEP_ALIVE_INTERVAL);

// Preload critical resources
addEventListener('fetch', (event) => {
  event.waitUntil(preloadCriticalResources());
});
```

#### 2. **Caching Strategy**
- **Response Caching:** Cache static MCP responses (tools/prompts lists)
- **Session Caching:** In-memory session data caching
- **Configuration Caching:** Cache tenant configuration data
- **CDN Integration:** Leverage Cloudflare's CDN for static assets

## System Architecture Diagrams

### MCP Protocol Flow

```
┌─────────────────┐                    ┌──────────────────┐
│   MCP Client    │                    │ Cloudflare Worker│
│   (Claude)      │                    │   MCP Server     │
└─────────────────┘                    └──────────────────┘
         │                                       │
         │ 1. POST /mcp                          │
         │    Content-Type: application/json     │
         │    Mcp-Session-Id: session-123        │
         │    Body: {"jsonrpc":"2.0",...}        │
         ├──────────────────────────────────────►│
         │                                       │
         │ 2. HTTP 200 OK                        │
         │    Content-Type: application/json     │
         │    Body: {"jsonrpc":"2.0",...}        │
         │◄──────────────────────────────────────┤
         │                                       │
         │ 3. GET /mcp                           │
         │    Accept: text/event-stream          │
         │    Mcp-Session-Id: session-123        │
         ├──────────────────────────────────────►│
         │                                       │
         │ 4. HTTP 200 OK                        │
         │    Content-Type: text/event-stream    │
         │    Transfer-Encoding: chunked         │
         │◄──────────────────────────────────────┤
         │                                       │
         │ 5. SSE Stream                         │
         │    data: {"jsonrpc":"2.0",...}        │
         │◄──────────────────────────────────────┤
```

### Data Flow Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                      Data Flow Patterns                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Request Processing Flow                                        │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │                                                             │ │
│  │  1. Request ──► 2. Auth ──► 3. Route ──► 4. Process        │ │
│  │     │             │          │            │                │ │
│  │     ▼             ▼          ▼            ▼                │ │
│  │  Validate     Tenant     Worker      MCP Handler           │ │
│  │  Headers      Lookup     Selection   Execution             │ │
│  │                                                             │ │
│  └─────────────────────────────────────────────────────────────┘ │
│                              │                                  │
│                              ▼                                  │
│  Storage Access Flow                                           │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │                                                             │ │
│  │  Session Data ──► KV Storage ──► Tenant Namespace          │ │
│  │      │               │              │                      │ │
│  │      ▼               ▼              ▼                      │ │
│  │  Large Files ──► R2 Storage ──► Bucket Isolation          │ │
│  │                                                             │ │
│  └─────────────────────────────────────────────────────────────┘ │
│                              │                                  │
│                              ▼                                  │
│  Response Generation Flow                                      │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │                                                             │ │
│  │  5. Generate ──► 6. Cache ──► 7. Stream ──► 8. Log        │ │
│  │     │              │           │             │             │ │
│  │     ▼              ▼           ▼             ▼             │ │
│  │  JSON-RPC      Response     SSE/HTTP     Analytics        │ │
│  │  Response      Caching      Delivery     Tracking         │ │
│  │                                                             │ │
│  └─────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

## Implementation Roadmap

### Phase 1: Core Architecture (Current)
- ✅ Multi-tenant isolation design
- ✅ Security patterns definition
- ✅ Auto-scaling strategy
- ✅ System architecture diagrams

### Phase 2: Infrastructure Implementation
- [ ] Basic Worker setup with HTTP transport
- [ ] KV-based session management
- [ ] Tenant isolation implementation
- [ ] Basic security controls

### Phase 3: Advanced Features
- [ ] Auto-scaling optimization
- [ ] Performance monitoring
- [ ] Advanced caching strategies
- [ ] Load balancing refinements

### Phase 4: Production Readiness
- [ ] Security hardening
- [ ] Comprehensive testing
- [ ] Performance optimization
- [ ] Documentation completion

## Conclusion

This architecture provides a robust, scalable, and secure foundation for hosting MCP servers on Cloudflare infrastructure. The design leverages Cloudflare's native capabilities for isolation, scaling, and global distribution while maintaining strict security boundaries between tenants.

**Key Architectural Benefits:**
- ✅ **Multi-tenant Security:** V8 isolate-based separation with storage isolation
- ✅ **Global Performance:** Edge deployment with automatic load balancing  
- ✅ **Auto-scaling:** Native Cloudflare scaling from 0 to high load
- ✅ **Cost Efficiency:** Pay-per-use model with generous free tiers
- ✅ **Developer Experience:** Simple deployment and management workflows

The architecture is designed to support the full SMCP platform evolution while maintaining compatibility with the MCP protocol specification and Cloudflare's operational constraints.
