# SMCP - Secure MCP Platform (POC)

[![Build Status](https://img.shields.io/badge/build-in--progress-yellow)](https://github.com/Ryan-Spooner/POC-SMCP)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![MCP Protocol](https://img.shields.io/badge/MCP-2025--03--26-green.svg)](https://modelcontextprotocol.io)
[![Cloudflare Workers](https://img.shields.io/badge/Cloudflare-Workers-orange.svg)](https://workers.cloudflare.com)

**Proof of Concept for secure, scalable Model Context Protocol (MCP) server hosting on Cloudflare infrastructure**

## Table of Contents

- [Overview](#overview)
- [Project Status](#project-status)
- [Architecture](#architecture)
- [Research Findings](#research-findings)
- [Development](#development)
- [Project Structure](#project-structure)
- [Contributing](#contributing)
- [License](#license)

## Overview

This POC focuses on building a secure, Cloudflare-based hosting environment for MCP servers as the foundation for the future Secure MCP (SMCP) platform. The mature platform will include a vetted marketplace, learning resources, and robust data infrastructure, but this POC specifically validates the core hosting capabilities.

### Project Goals

- **Goal 1:** Create a secure, Cloudflare-based hosting environment for MCP servers
- **Goal 2:** Demonstrate high availability and scalability of the hosting infrastructure
- **Goal 3:** Establish security patterns and best practices for hosting third-party MCP servers

### Key Features (Planned)

- **MCP Server Hosting:** Deploy and run MCP servers on Cloudflare Workers using Streamable HTTP transport
- **Multi-tenant Isolation:** Secure separation between different MCP server instances using V8 isolates
- **4-Layer Security Model:** Comprehensive security with Network, Application, Runtime, and Data protection
- **Dual Authentication:** OAuth 2.1 for human users and API keys for service-to-service communication
- **Auto-scaling:** Automatic scaling based on demand and usage patterns
- **Health Monitoring:** Real-time monitoring and health checks for hosted servers
- **Global Edge Deployment:** Worldwide distribution via Cloudflare's edge network

### Technical Stack

- **Infrastructure:** Cloudflare Workers, Cloudflare KV, Cloudflare R2, Cloudflare DNS
- **Runtime:** JavaScript/TypeScript on Cloudflare Workers runtime
- **Protocol:** Model Context Protocol (MCP) 2025-03-26 with Streamable HTTP transport
- **Security:** OAuth 2.1, API key authentication, AES-256-GCM encryption, JWT validation
- **Development Tools:** TypeScript, Node.js, Wrangler CLI, Zod (validation), JOSE (JWT), Git

## Project Status

**Current Phase:** Discovery & Planning (Week 1-2)
**Timeline:** 8-week POC development cycle

### Completed Tasks ✅

- **SMCP-001-01** - MCP Protocol Specifications Research
  - ✅ Analyzed MCP server runtime requirements
  - ✅ Documented protocol communication patterns
  - ✅ Identified Cloudflare Workers compatibility constraints
  - ✅ Established Streamable HTTP as the optimal transport mechanism

- **SMCP-001-02** - Cloudflare Services Research
  - ✅ Evaluated Cloudflare Workers capabilities and limitations
  - ✅ Researched Cloudflare KV, R2, and DNS integration options
  - ✅ Documented service limits and pricing considerations
  - ✅ Validated cost-effectiveness and technical compatibility

- **SMCP-001-03** - Architecture Design
  - ✅ Designed multi-tenant hosting architecture with V8 isolate-based separation
  - ✅ Defined 4-layer security isolation patterns with tenant-scoped access controls
  - ✅ Planned auto-scaling and load balancing using Cloudflare's native capabilities
  - ✅ Created comprehensive system architecture diagrams and data flow patterns

- **SMCP-001-04** - Security Strategy Definition (Extended)
  - ✅ Defined comprehensive 4-layer security model (Network, Application, Runtime, Data)
  - ✅ Established multi-tenant isolation requirements with V8 isolate separation
  - ✅ Designed OAuth 2.1 + API key authentication strategy with MCP protocol compliance
  - ✅ Planned secrets management using Cloudflare encrypted environment variables
  - ✅ Created detailed security document with implementation patterns
  - ✅ **Extension**: Researched AI-assisted coding security vulnerabilities and threats
  - ✅ **Extension**: Enhanced to 5-layer security model including AI-generated code security
  - ✅ **Extension**: Developed comprehensive AI coding security mitigation strategies

### Current Tasks 🔄

- **SMCP-001-05** - Development Environment Setup (Next)

### Project Phases

1. **Phase 1: Discovery & Planning** (Weeks 1–2) - *Current*
2. **Phase 2: Infrastructure Development** (Weeks 3–4)
3. **Phase 3: Advanced Features** (Weeks 5–6)
4. **Phase 4: Testing & Validation** (Weeks 7–8)

## Architecture

### High-Level Architecture

```
┌─────────────────┐  Streamable HTTP  ┌──────────────────┐
│   MCP Client    │ ─────────────────► │ Cloudflare Worker│
│   (Claude, etc) │  POST: JSON-RPC   │   MCP Server     │
│                 │  GET: SSE Stream   │  (Single Endpoint)│
└─────────────────┘                   └──────────────────┘
                                              │
                                              ▼
                                      ┌──────────────────┐
                                      │ Cloudflare       │
                                      │ Services         │
                                      │ (KV, R2, D1)     │
                                      └──────────────────┘
```

### Transport Protocol

- **Primary Transport:** Streamable HTTP (MCP 2025-03-26)
- **Communication:** Bidirectional via single HTTP endpoint
- **Authentication:** OAuth 2.1 Bearer tokens or API key authentication
- **Session Management:** `Mcp-Session-Id` headers + Cloudflare KV with tenant isolation
- **Real-time:** Server-Sent Events (SSE) for streaming
- **Resumability:** Event IDs for connection recovery

### Security Architecture

- **4-Layer Security Model:** Network (DDoS, SSL, WAF) → Application (OAuth 2.1, validation) → Runtime (V8 isolates) → Data (encryption, namespacing)
- **Multi-tenant Isolation:** Dedicated Worker instances with V8 isolate separation and storage namespacing
- **Authentication Methods:** OAuth 2.1 with PKCE for human users, API keys for service-to-service
- **Secrets Management:** Encrypted environment variables and KV storage with automated key rotation

For detailed architecture design including multi-tenant isolation, security patterns, and auto-scaling strategies, see: [`docs/architecture-design.md`](docs/architecture-design.md)

## Research Findings

### ✅ MCP Compatibility with Cloudflare Workers

**Key Finding:** MCP is fully compatible with Cloudflare Workers using Streamable HTTP transport.

#### Compatible Features
- **HTTP Transport:** Native support for HTTP requests/responses
- **JSON-RPC 2.0:** Built-in JSON processing capabilities
- **Server-Sent Events:** Real-time streaming support
- **Session Management:** Via headers and KV storage
- **Global Edge:** Automatic worldwide deployment

#### Constraints & Adaptations
- **stdio Transport:** Incompatible (no subprocess support)
- **Local Files:** Must use Cloudflare storage services (KV, R2, DNS)
- **Memory Limit:** 128 MB per Worker instance
- **CPU Time:** 30 seconds default, up to 5 minutes configurable

For detailed MCP research findings, see: [`docs/mcp-protocol-research.md`](docs/mcp-protocol-research.md)

### ✅ Cloudflare Services Ecosystem

**Key Finding:** Cloudflare provides a comprehensive, cost-effective infrastructure stack for MCP hosting.

#### Service Capabilities
- **Workers:** 128MB memory, 5 min CPU time, global edge deployment
- **KV:** Low-latency key-value storage for session management
- **R2:** S3-compatible object storage with zero egress fees
- **DNS:** Custom domains with automatic certificate management

#### Cost Analysis
- **POC Scale:** ~$6/month for 10 concurrent MCP servers
- **Production Scale:** ~$34/month for 100 concurrent MCP servers
- **Free Tier:** Generous limits suitable for development and testing

#### Implementation Strategy
- Use Workers for MCP server hosting with HTTP transport
- Implement session management via KV with `Mcp-Session-Id` headers
- Leverage R2 for larger data storage needs
- Use Custom Domains as clean MCP server endpoints
- Implement multi-tenant isolation at Worker and storage levels

For detailed Cloudflare research findings, see: [`docs/cloudflare-services-research.md`](docs/cloudflare-services-research.md)

### ✅ Multi-Tenant Architecture Design

**Key Finding:** V8 isolate-based architecture provides robust security and scalability for multi-tenant MCP hosting.

#### Architecture Highlights
- **Multi-tenant Isolation:** V8 isolate separation with storage namespace isolation
- **4-Layer Security:** Network, application, runtime, and data security layers
- **Auto-scaling Strategy:** Cloudflare's native scaling with geographic distribution
- **Performance Optimization:** Cold start mitigation and intelligent caching

#### Implementation Patterns
- Worker-level tenant isolation with dedicated instances per MCP server
- KV-based session management with tenant-scoped access controls
- R2 storage separation using bucket-level or prefix-based isolation
- Global load balancing with automatic failover and latency optimization

For detailed architecture design and implementation patterns, see: [`docs/architecture-design.md`](docs/architecture-design.md)

### ✅ Comprehensive Security Strategy

**Key Finding:** 4-layer security model provides enterprise-grade protection for multi-tenant MCP hosting.

#### Security Highlights
- **OAuth 2.1 Compliance:** Full MCP protocol compliance with PKCE, dynamic client registration, metadata discovery
- **Dual Authentication:** OAuth 2.1 for human users, API keys for service-to-service communication
- **Multi-tenant Isolation:** Complete separation using V8 isolates, storage namespacing, and tenant-scoped access controls
- **Secrets Management:** Encrypted environment variables, KV storage with AES-256-GCM, automated key rotation

#### Implementation Strategy
- Implement OAuth 2.1 authorization server with Cloudflare Workers
- Use tenant-scoped API keys with format `smcp_<tenantId>_<randomBytes>`
- Leverage Zod for input validation and JOSE for JWT handling
- Implement comprehensive audit logging with 30-day retention
- Use role-based access control with Admin, MCP User, and Read-Only roles

For detailed security strategy and implementation patterns, see: [`docs/security-strategy.md`](docs/security-strategy.md)

## Development

### Prerequisites

- Node.js 18+ (for development tools)
- Cloudflare account (for deployment)
- Wrangler CLI (Cloudflare Workers development)
- Git (version control)

### Development Setup

```bash
# Clone the repository
git clone https://github.com/Ryan-Spooner/POC-SMCP.git
cd POC-SMCP

# Development environment setup (coming in Phase 1)
# npm install
# wrangler login
# npm run dev
```

*Note: Development setup will be completed in task SMCP-001-05*

## Project Structure

```
POC-SMCP/
├── docs/                    # Project documentation
│   ├── mcp-protocol-research.md
│   ├── cloudflare-services-research.md
│   ├── architecture-design.md
│   └── security-strategy.md
├── memory-bank/             # AI assistant context files
│   ├── activeContext.md
│   ├── decisionLog.md
│   ├── dependencies.md
│   ├── productContext.md
│   ├── product-backlog.md
│   ├── progress.md
│   └── systemPatterns.md
├── src/                     # Source code (coming in Phase 2)
├── tests/                   # Test files (coming in Phase 3)
├── .augment-guidelines      # AI assistant rules
├── projectBrief.md         # Detailed project requirements
└── README.md               # This file
```

### Development Workflow

1. **Research & Planning** (Phase 1) – Current phase
2. **Infrastructure Development** (Phase 2) – Basic MCP server implementation
3. **Advanced Features** (Phase 3) – Auto-scaling, monitoring, deployment
4. **Testing & Validation** (Phase 4) – Security testing, performance validation

## Contributing

This is a proof-of-concept project currently in active development. Contributions will be welcomed once the initial implementation is complete.

### Current Development Status

- **Phase 1:** Research & Planning (In Progress – 4/5 tasks completed)
- **Contributions:** Not yet accepting external contributions
- **Timeline:** Contributions welcome after Phase 2 completion

### Future Contribution Areas

- MCP server implementations
- Security enhancements
- Performance optimizations
- Documentation improvements
- Testing and validation

## License

This project is licensed under the MIT License – see the [LICENSE](LICENSE) file for details.

## Documentation

- **Project Brief:** [`projectBrief.md`](projectBrief.md) - Detailed project requirements and scope
- **MCP Research:** [`docs/mcp-protocol-research.md`](docs/mcp-protocol-research.md) - Protocol analysis and findings
- **Cloudflare Research:** [`docs/cloudflare-services-research.md`](docs/cloudflare-services-research.md) - Infrastructure analysis and cost modeling
- **Architecture Design:** [`docs/architecture-design.md`](docs/architecture-design.md) - Multi-tenant hosting architecture and security patterns
- **Security Strategy:** [`docs/security-strategy.md`](docs/security-strategy.md) - Comprehensive security model and implementation patterns
- **AI Coding Security:** [`docs/ai-assisted-coding-security.md`](docs/ai-assisted-coding-security.md) - AI-assisted coding vulnerabilities and mitigation strategies
- **Task Backlog:** [`memory-bank/product-backlog.md`](memory-bank/product-backlog.md) - Planned tasks for development

## Support & Contact

- **Project Lead:** Rene Quiroz
- **Project Lead:** Ryan Spooner
- **Email:** support@ischyolabs.com
- **Repository:** [GitHub - POC-SMCP](https://github.com/Ryan-Spooner/POC-SMCP)

## Acknowledgments

- **Model Context Protocol:** [Anthropic](https://www.anthropic.com/) and the MCP community
- **Cloudflare Workers:** [Cloudflare](https://www.cloudflare.com/) for the edge computing platform
- **AI Assistant:** Augment Agent for development assistance and documentation
