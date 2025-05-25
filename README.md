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
- **Multi-tenant Isolation:** Secure separation between different MCP server instances
- **Auto-scaling:** Automatic scaling based on demand and usage patterns
- **Health Monitoring:** Real-time monitoring and health checks for hosted servers
- **Global Edge Deployment:** Worldwide distribution via Cloudflare's edge network

### Technical Stack

- **Infrastructure:** Cloudflare Workers, Cloudflare KV, Cloudflare R2, Cloudflare DNS
- **Runtime:** JavaScript/TypeScript on Cloudflare Workers runtime
- **Protocol:** Model Context Protocol (MCP) 2025-03-26 with Streamable HTTP transport
- **Development Tools:** TypeScript, Node.js, Wrangler CLI, Git

## Project Status

**Current Phase:** Discovery & Planning (Week 1-2)
**Timeline:** 8-week POC development cycle

### Completed Tasks ✅

- **SMCP-001-01** - MCP Protocol Specifications Research
  - ✅ Analyzed MCP server runtime requirements
  - ✅ Documented protocol communication patterns
  - ✅ Identified Cloudflare Workers compatibility constraints
  - ✅ Established Streamable HTTP as optimal transport mechanism

- **SMCP-001-02** - Cloudflare Services Research
  - ✅ Evaluated Cloudflare Workers capabilities and limitations
  - ✅ Researched Cloudflare KV, R2, and DNS integration options
  - ✅ Documented service limits and pricing considerations
  - ✅ Validated cost-effectiveness and technical compatibility

### Current Tasks 🔄

- **SMCP-001-03** - Architecture Design (Next)
- **SMCP-001-04** - Security Strategy Definition (Planned)
- **SMCP-001-05** - Development Environment Setup (Planned)

### Project Phases

1. **Phase 1: Discovery & Planning** (Weeks 1-2) - *Current*
2. **Phase 2: Infrastructure Development** (Weeks 3-4)
3. **Phase 3: Advanced Features** (Weeks 5-6)
4. **Phase 4: Testing & Validation** (Weeks 7-8)

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
- **Session Management:** `Mcp-Session-Id` headers + Cloudflare KV
- **Real-time:** Server-Sent Events (SSE) for streaming
- **Resumability:** Event IDs for connection recovery

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
- **Local Files:** Must use Cloudflare storage services (KV, R2, D1)
- **Memory Limit:** 128 MB per Worker instance
- **CPU Time:** 30 seconds default, up to 5 minutes configurable

#### Implementation Strategy
- Focus exclusively on Streamable HTTP transport
- Leverage Cloudflare services for persistence and storage
- Implement multi-tenancy via session isolation
- Use global edge network for performance and availability

For detailed research findings, see: [`docs/mcp-protocol-research.md`](docs/mcp-protocol-research.md)

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
│   └── mcp-protocol-research.md
├── memory-bank/             # AI assistant context files
│   ├── activeContext.md
│   ├── decisionLog.md
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

1. **Research & Planning** (Phase 1) - Current phase
2. **Infrastructure Development** (Phase 2) - Basic MCP server implementation
3. **Advanced Features** (Phase 3) - Auto-scaling, monitoring, deployment
4. **Testing & Validation** (Phase 4) - Security testing, performance validation

## Contributing

This is a proof-of-concept project currently in active development. Contributions will be welcomed once the initial implementation is complete.

### Current Development Status

- **Phase 1:** Research & Planning (In Progress)
- **Contributions:** Not yet accepting external contributions
- **Timeline:** Contributions welcome after Phase 2 completion

### Future Contribution Areas

- MCP server implementations
- Security enhancements
- Performance optimizations
- Documentation improvements
- Testing and validation

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Documentation

- **Project Brief:** [`projectBrief.md`](projectBrief.md) - Detailed project requirements and scope
- **MCP Research:** [`docs/mcp-protocol-research.md`](docs/mcp-protocol-research.md) - Protocol analysis and findings
- **Memory Bank:** [`memory-bank/`](memory-bank/) - AI assistant context and decision tracking

## Support & Contact

- **Project Lead:** Rene Quiroz
- **Project Lead:** Ryan Spooner
- **Email:** support@ischyolabs.com
- **Repository:** [GitHub - POC-SMCP](https://github.com/Ryan-Spooner/POC-SMCP)

## Acknowledgments

- **Model Context Protocol:** [Anthropic](https://www.anthropic.com/) and the MCP community
- **Cloudflare Workers:** [Cloudflare](https://www.cloudflare.com/) for the edge computing platform
- **AI Assistant:** Augment Agent for development assistance and documentation
