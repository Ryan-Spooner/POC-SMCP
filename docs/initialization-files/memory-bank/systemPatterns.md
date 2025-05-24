---
Purpose: Documents recurring design patterns, coding standards, and architectural choices specific to this project.
Updates: Appended or refined by AI/user as patterns emerge or standards are set.
Last Reviewed: [YYYY-MM-DD]
---

# System Patterns & Conventions

## Coding Style / Linting
* [Linter: (add if defined)]
* [Formatter: (add if defined)]
* [Style Guide: (add if defined)]
* [Docstrings: Google style (Mandatory for public APIs)]
* [Type Hinting: Mandatory for function signatures]

## Common Data Structures
* [e.g., Standard format for API responses, common state objects]

## Architectural Patterns
* [Add if defined]

## Naming Conventions
* [Variables/Functions: snake_case]
* [Constants: UPPER_SNAKE_CASE]
* [Classes: PascalCase]
* [Files: kebab-case]

## Error Handling Strategy
* [add if defined]

## Security Considerations
* [e.g., Input validation practices, secrets management (.env), dependency scanning]

## Testing Patterns

### Unit Testing
* **Framework:** [e.g., Jest, Vitest, pytest, Go test]
* **Coverage Target:** [e.g., 80% minimum]
* **Naming Convention:** [e.g., test_function_name_should_return_expected_result]
* **Test Structure:** [e.g., Arrange-Act-Assert, Given-When-Then]

### Integration Testing
* **Strategy:** [e.g., Test containers, In-memory databases]
* **API Testing:** [e.g., Supertest, requests library]
* **Database Testing:** [e.g., Test fixtures, migrations]

### End-to-End Testing
* **Framework:** [e.g., Playwright, Cypress, Selenium]
* **Test Environment:** [e.g., Staging, dedicated E2E environment]
* **Test Data Management:** [e.g., Seeded data, factories]

### Test Organization
* **File Structure:** [e.g., tests/ directory, __tests__ folders]
* **Test Categories:** [e.g., unit, integration, e2e]
* **Mocking Strategy:** [e.g., Jest mocks, test doubles]

## Performance Considerations

### Frontend Performance
* **Bundle Size Limits:** [e.g., < 250KB initial bundle]
* **Code Splitting:** [e.g., Route-based, component-based]
* **Lazy Loading:** [e.g., Images, components, routes]
* **Caching Strategy:** [e.g., Service workers, CDN caching]

### Backend Performance
* **Response Time Targets:** [e.g., < 200ms for API endpoints]
* **Database Optimization:** [e.g., Indexing strategy, query optimization]
* **Caching Layers:** [e.g., Redis, in-memory caching]
* **Connection Pooling:** [e.g., Database connections, HTTP clients]

### Performance Monitoring
* **Metrics to Track:** [e.g., Response times, throughput, error rates]
* **Performance Budgets:** [e.g., Lighthouse scores, Core Web Vitals]
* **Profiling Tools:** [e.g., Chrome DevTools, profiling libraries]

## Monitoring & Logging Standards

### Application Logging
* **Log Levels:** [e.g., ERROR, WARN, INFO, DEBUG]
* **Log Format:** [e.g., JSON structured logs, timestamp format]
* **Sensitive Data:** [e.g., Never log passwords, PII handling]
* **Log Rotation:** [e.g., Daily rotation, size limits]

### Error Tracking
* **Error Monitoring:** [e.g., Sentry, Bugsnag, Rollbar]
* **Error Context:** [e.g., User ID, request ID, stack traces]
* **Alert Thresholds:** [e.g., Error rate > 1%, response time > 5s]

### Application Metrics
* **Business Metrics:** [e.g., User signups, feature usage]
* **Technical Metrics:** [e.g., Response times, database queries]
* **Infrastructure Metrics:** [e.g., CPU, memory, disk usage]

### Health Checks
* **Endpoint Pattern:** [e.g., /health, /status]
* **Check Components:** [e.g., Database, external APIs, disk space]
* **Response Format:** [e.g., JSON with status and details]

## API Design Patterns

### RESTful API Standards
* **HTTP Methods:** [e.g., GET, POST, PUT, DELETE usage]
* **Status Codes:** [e.g., 200, 201, 400, 404, 500 usage]
* **URL Structure:** [e.g., /api/v1/resources/{id}]
* **Request/Response Format:** [e.g., JSON, content-type headers]

### Error Handling
* **Error Response Format:** [e.g., {error: {code, message, details}}]
* **Validation Errors:** [e.g., Field-specific error messages]
* **Rate Limiting:** [e.g., 429 status, retry-after headers]

### Authentication & Authorization
* **Auth Method:** [e.g., JWT, OAuth 2.0, API keys]
* **Token Management:** [e.g., Refresh tokens, expiration]
* **Permission Model:** [e.g., RBAC, resource-based permissions]

## Data Management Patterns

### Database Patterns
* **Schema Design:** [e.g., Normalization level, indexing strategy]
* **Migration Strategy:** [e.g., Versioned migrations, rollback procedures]
* **Data Validation:** [e.g., Database constraints, application validation]

### Data Access Patterns
* **ORM Usage:** [e.g., Active Record, Data Mapper]
* **Query Optimization:** [e.g., N+1 prevention, eager loading]
* **Transaction Management:** [e.g., ACID compliance, isolation levels]

## Deployment Patterns
* **Deployment Strategy:** [e.g., Blue-green, rolling updates, canary]
* **Environment Management:** [e.g., dev, staging, production]
* **Configuration Management:** [e.g., Environment variables, config files]
* **Database Migrations:** [e.g., Automated, manual approval required]