---
Purpose: Central navigation and priority system for AI assistant context consumption
Created: 2025-05-26
Last Updated: 2025-05-26
Priority: Critical - Read First
---

# AI Assistant Context Index

## Quick Project Status
**Project**: POC-SMCP - Secure MCP Server Hosting on Cloudflare Workers
**Phase**: Infrastructure Development (Week 3-4)
**Current Task**: SMCP-002-01 - MCP Protocol Implementation ⭐
**Status**: Ready to implement Streamable HTTP transport protocol
**Tests**: 20/20 passing ✅ | **Build**: Working ✅ | **Environment**: Functional ✅

## Context File Hierarchy

### 🔥 PRIMARY CONTEXT (Read First)
Essential information for immediate AI assistance on current tasks.

1. **[activeContext.md](./activeContext.md)** - Current focus, immediate next steps, blockers
   - **When to use**: Starting any new task or session
   - **Key info**: Current priorities, recent changes, next immediate steps
   - **Links to**: Current codebase files, active tasks

2. **[context-summary.md](./context-summary.md)** - Condensed project overview
   - **When to use**: Quick context loading, new AI sessions
   - **Key info**: Project status, architecture, immediate priorities
   - **Links to**: All major context files and codebase

3. **[productContext.md](./productContext.md)** - Core project goals and architecture
   - **When to use**: Understanding project purpose and high-level design
   - **Key info**: Goals, features, target audience, architecture overview
   - **Links to**: Architecture docs, security strategy

### 📋 SECONDARY CONTEXT (Reference as Needed)
Supporting information for specific tasks and decisions.

4. **[product-backlog.md](./product-backlog.md)** - Current phase tasks and future planning
   - **When to use**: Task planning, understanding project scope
   - **Key info**: Current phase tasks, acceptance criteria, dependencies
   - **Links to**: Codebase files, documentation, test files

5. **[systemPatterns.md](./systemPatterns.md)** - Coding standards and architectural patterns
   - **When to use**: Writing code, making architectural decisions
   - **Key info**: Coding standards, security patterns, naming conventions
   - **Links to**: Example code files, configuration files

6. **[decisionLog.md](./decisionLog.md)** - Technical and architectural decisions
   - **When to use**: Understanding why certain approaches were chosen
   - **Key info**: Major decisions, rationale, implementation notes
   - **Links to**: Related documentation, affected code files

### 📚 REFERENCE CONTEXT (Lookup Information)
Historical information and detailed references.

7. **[progress.md](./progress.md)** - Task completion history and status
   - **When to use**: Understanding what's been completed, tracking progress
   - **Key info**: Completed tasks, current tasks, resolved issues
   - **Links to**: Task deliverables, documentation

8. **[dependencies.md](./dependencies.md)** - Technology stack and dependency decisions
   - **When to use**: Adding dependencies, understanding tech stack
   - **Key info**: Current dependencies, versions, decision rationale
   - **Links to**: package.json, configuration files

9. **[troubleshooting.md](./troubleshooting.md)** - Known issues and solutions
   - **When to use**: Debugging problems, resolving common issues
   - **Key info**: Common problems, solutions, debugging strategies
   - **Links to**: Related code files, configuration

## Current Phase Context Map

### SMCP-002-01: MCP Protocol Implementation (⭐ CURRENT)
**Primary Files**:
- [activeContext.md](./activeContext.md) - Current implementation status
- [systemPatterns.md](./systemPatterns.md) - MCP protocol patterns
- [productContext.md](./productContext.md) - Transport protocol decisions

**Codebase Files**:
- `src/workers/mcp-host-worker.ts` - Main worker implementation
- `src/workers/mcp-server-instance.ts` - Durable Object for MCP instances
- `src/types/mcp-types.ts` - MCP protocol type definitions
- `wrangler.toml` - Worker configuration and bindings

**Documentation**:
- `docs/mcp-protocol-research.md` - Protocol research and requirements
- `docs/architecture-design.md` - System architecture and design

### Next Tasks Context
**SMCP-002-02**: Authentication & Authorization
- **Context**: [decisionLog.md](./decisionLog.md) - OAuth 2.1 + API key decisions
- **Patterns**: [systemPatterns.md](./systemPatterns.md) - Auth patterns and security
- **Code**: `src/auth/`, `src/middleware/auth-middleware.ts`

**SMCP-002-03**: Multi-tenant Isolation
- **Context**: [productContext.md](./productContext.md) - Multi-tenant architecture
- **Patterns**: [systemPatterns.md](./systemPatterns.md) - Isolation patterns
- **Code**: `src/workers/mcp-server-instance.ts`, `src/storage/`

## AI Assistant Usage Guidelines

### For New Sessions
1. **Start with**: [context-summary.md](./context-summary.md) for quick overview
2. **Then read**: [activeContext.md](./activeContext.md) for current status
3. **Reference**: Relevant secondary context based on task type

### For Code Changes
1. **Check**: [systemPatterns.md](./systemPatterns.md) for coding standards
2. **Review**: [decisionLog.md](./decisionLog.md) for architectural decisions
3. **Update**: [activeContext.md](./activeContext.md) and [progress.md](./progress.md) after completion

### For Planning Tasks
1. **Review**: [product-backlog.md](./product-backlog.md) for task details
2. **Check**: [dependencies.md](./dependencies.md) for technical constraints
3. **Reference**: [productContext.md](./productContext.md) for alignment with goals

### For Debugging
1. **Check**: [troubleshooting.md](./troubleshooting.md) for known issues
2. **Review**: [systemPatterns.md](./systemPatterns.md) for expected patterns
3. **Reference**: [dependencies.md](./dependencies.md) for version compatibility

## Context Maintenance

### Update Frequency
- **activeContext.md**: After each significant task or session
- **progress.md**: When tasks are completed or status changes
- **product-backlog.md**: When tasks are added, completed, or reprioritized
- **decisionLog.md**: When significant technical decisions are made
- **systemPatterns.md**: When new patterns are established or changed

### Cross-Reference Validation
- All context files should link to relevant codebase files
- Decisions in decisionLog.md should reference implementation in code
- Patterns in systemPatterns.md should have examples in codebase
- Tasks in product-backlog.md should link to actual deliverables

## Quick Reference Links

### Key Codebase Files
- **Main Worker**: `src/workers/mcp-host-worker.ts`
- **MCP Types**: `src/types/mcp-types.ts`
- **Configuration**: `wrangler.toml`, `package.json`, `tsconfig.json`
- **Tests**: `tests/unit/`, `tests/integration/`

### Key Documentation
- **Architecture**: `docs/architecture-design.md`
- **Security**: `docs/security-strategy.md`
- **MCP Research**: `docs/mcp-protocol-research.md`
- **Project Brief**: `projectBrief.md`

### Development Commands
- **Build**: `npm run build`
- **Test**: `npm test` (20/20 passing)
- **Dev Server**: `npm run dev`
- **Deploy**: `npm run deploy`

---

**Note**: This index is designed to optimize AI assistant context consumption. Always start with PRIMARY CONTEXT files for the most relevant and current information.
