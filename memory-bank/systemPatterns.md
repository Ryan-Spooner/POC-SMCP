---
Purpose: Documents recurring design patterns, coding standards, and architectural choices specific to this project.
Updates: Appended or refined by AI/user as patterns emerge or standards are set.
Last Reviewed: 2025-05-24
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
* **Framework:** [e.g., Jest, Vitest, pytest, Go test]
* **Coverage Target:** [e.g., 80% minimum]
* **Test Structure:** [e.g., Arrange-Act-Assert, Given-When-Then]

## Performance Considerations
* **Response Time Targets:** [e.g., < 200ms for API endpoints]
* **Bundle Size Limits:** [e.g., < 250KB initial bundle]
* **Caching Strategy:** [e.g., Redis, CDN caching]

## Monitoring & Logging Standards
* **Log Levels:** [e.g., ERROR, WARN, INFO, DEBUG]
* **Error Monitoring:** [e.g., Sentry, Bugsnag, Rollbar]
* **Health Checks:** [e.g., /health endpoint]

## Deployment Patterns
* **Deployment Strategy:** [e.g., Blue-green, rolling updates, canary]
* **Environment Management:** [e.g., dev, staging, production]
