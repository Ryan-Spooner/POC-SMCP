---
Purpose: Document actual issues, solutions, and debugging strategies for POC-SMCP.
Updates: Added by AI/user when new issues are discovered and resolved.
Last Reviewed: 2025-05-26
---

# Troubleshooting Guide - POC-SMCP

## Known Issues & Solutions

### Development Environment Issues

#### Issue: TypeScript Compilation Errors with Cloudflare Workers Types
**Status:** ✅ RESOLVED
**Symptoms:**
- TypeScript errors related to Workers runtime types
- Missing type definitions for KV, R2, or Durable Objects

**Solution:**
```bash
# Ensure correct Workers types are installed
npm install --save-dev @cloudflare/workers-types

# Verify tsconfig.json includes Workers types
# "types": ["@cloudflare/workers-types", "@types/jest"]
```

**Prevention:** Always use latest `@cloudflare/workers-types` and verify tsconfig.json configuration

---

#### Issue: Wrangler Dev Server Connection Issues
**Status:** ✅ RESOLVED
**Symptoms:**
- Local development server fails to start
- Connection refused errors on http://127.0.0.1:8787

**Solution:**
```bash
# Check if port is already in use
lsof -i :8787

# Kill existing processes if needed
kill -9 [PID]

# Restart development server
npm run dev
```

**Prevention:** Always stop dev server properly with Ctrl+C before restarting

---

## Debugging Strategies

### Cloudflare Workers Debugging
```bash
# View Workers logs during development
wrangler tail

# Check build output
npm run build && ls -la dist/

# Validate wrangler configuration
wrangler whoami
wrangler kv:namespace list
```

### TypeScript Debugging
```bash
# Type checking without compilation
npm run type-check

# Detailed TypeScript errors
npx tsc --noEmit --pretty
```

### Test Debugging
```bash
# Run tests with verbose output
npm test -- --verbose

# Run specific test file
npm test -- crypto-utils.test.ts

# Run tests with coverage
npm run test:coverage
```

---

## Emergency Procedures

### Development Environment Recovery
1. **Clean rebuild**: `npm run clean && npm run build`
2. **Dependency reset**: `rm -rf node_modules && npm install`
3. **Configuration check**: Verify `wrangler.toml`, `tsconfig.json`, `package.json`
4. **Test validation**: `npm test` should show 20/20 passing

### Deployment Issues
1. **Authentication check**: `wrangler whoami`
2. **Configuration validation**: `wrangler dev` should work locally
3. **Gradual deployment**: Test in development environment first
4. **Rollback**: Use `wrangler rollback` if deployment fails

---

**Note:** This guide contains only actual issues encountered during POC-SMCP development. Template content moved to `memory-bank/templates/` directory.
