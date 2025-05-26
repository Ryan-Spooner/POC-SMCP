---
Purpose: Records significant technical or architectural choices.
Updates: New decisions appended by AI or user.
---

# Decision Log

**Decision:**
* Use HTTP Transport Only for MCP Server Implementation on Cloudflare Workers

**Rationale:**
* stdio transport is incompatible with Cloudflare Workers (no subprocess support)
* HTTP transport provides full MCP protocol compatibility
* Streamable HTTP with SSE enables real-time communication
* Aligns with Cloudflare Workers' HTTP-first architecture
* Enables global edge deployment and auto-scaling benefits

**Context/Trigger:**
* SMCP-001-01 research revealed MCP supports two transport mechanisms
* Cloudflare Workers runtime constraints eliminate stdio option
* Need to establish viable technical path for MCP hosting POC

**Implementation Notes:**
* Focus on Streamable HTTP transport implementation
* Use Server-Sent Events (SSE) for streaming capabilities
* Implement session management via Mcp-Session-Id headers
* Leverage Cloudflare KV for session storage
* Skip stdio compatibility entirely to avoid complexity

**Timestamp:** 2025-01-25

---

**Decision:**
* Adopt Cloudflare Workers + KV + R2 + DNS as Primary Infrastructure Stack

**Rationale:**
* Comprehensive service ecosystem with excellent MCP compatibility
* Cost-effective with generous free tiers ($6/month for POC, $34/month for production scale)
* Global edge performance with <100ms latency worldwide
* Built-in security, DDoS protection, and multi-tenant isolation capabilities
* Excellent developer experience with Wrangler CLI and local development tools

**Context/Trigger:**
* SMCP-001-02 research revealed Cloudflare provides all required services
* Need to establish infrastructure foundation for MCP server hosting POC
* Alternative cloud providers would require more complex setup and higher costs

**Implementation Notes:**
* Workers: Use HTTP transport exclusively, leverage 128MB memory and 5min CPU limits
* KV: Implement session management via Mcp-Session-Id headers with tenant isolation
* R2: Use for larger data storage needs with S3-compatible API
* DNS: Leverage Custom Domains for clean MCP server endpoints
* Multi-tenancy: Worker-level isolation + KV namespacing + R2 bucket separation

**Timestamp:** 2025-05-25

---

**Decision:**
* Adopt V8 Isolate-Based Multi-Tenant Architecture with 4-Layer Security Model

**Rationale:**
* V8 isolates provide robust runtime isolation between tenant MCP servers
* 4-layer security (Network, Application, Runtime, Data) ensures comprehensive protection
* Worker-level isolation prevents cross-tenant access and resource conflicts
* Storage namespace isolation (KV prefixes, R2 buckets) maintains data separation
* Cloudflare's native auto-scaling eliminates need for custom scaling logic

**Context/Trigger:**
* SMCP-001-03 architecture design required defining multi-tenant hosting approach
* Need to balance security, performance, and operational simplicity
* Must leverage Cloudflare Workers' strengths while mitigating limitations

**Implementation Notes:**
* Each tenant gets dedicated Worker instance with isolated V8 runtime
* KV storage uses tenant-{id}: prefixes for all keys
* R2 storage uses bucket-level or prefix-based separation
* Session management via Mcp-Session-Id headers with tenant validation
* Auto-scaling handled by Cloudflare's native edge distribution
* Cold start mitigation through keep-alive strategies and resource preloading

**Timestamp:** 2025-05-25

---

*(New entries added above this line)*
