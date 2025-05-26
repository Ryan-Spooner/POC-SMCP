---
Source: Based on projectBrief.md and initial discussions.
Updates: Appended by AI as project understanding evolves.
Last Reviewed: 2025-05-25
---

# Product Context

## Project Goal
* Build a POC for secure, Cloudflare-based hosting environment for MCP servers as foundation for future SMCP marketplace platform
* Validate technical approach for hosting third-party MCP servers in secure, scalable environment
* Establish infrastructure patterns that will support future marketplace, learning platform, and data pipeline components

## Key Features
* MCP Server Hosting: Deploy and run MCP servers on Cloudflare Workers with secure isolation
* Multi-tenant Security: Complete separation between different MCP server instances
* Auto-scaling: Automatic scaling based on demand and usage patterns
* Health Monitoring: Real-time monitoring and health checks for hosted servers
* Deployment Automation: Infrastructure-as-code and automated deployment pipelines

## Target Audience
* Primary: MCP server developers needing reliable hosting infrastructure
* Secondary: AI application developers consuming MCP services
* Future: Users of the complete SMCP marketplace platform

## High-Level Architecture
* **Multi-Tenant Hosting:** V8 isolate-based separation with dedicated Worker instances per tenant
* **4-Layer Security Model:** Network (DDoS, SSL), Application (auth, validation), Runtime (V8 isolates), Data (namespace isolation)
* **Auto-Scaling Strategy:** Cloudflare's native edge scaling with geographic distribution and automatic load balancing
* **Storage Architecture:** KV for session management with tenant prefixes, R2 for object storage with bucket isolation
* **Transport Protocol:** Streamable HTTP with Server-Sent Events for real-time bidirectional communication
* **Global Performance:** 300+ edge locations with <100ms latency worldwide and automatic failover
