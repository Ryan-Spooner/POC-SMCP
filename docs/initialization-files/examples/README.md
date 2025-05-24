# Project Configuration Examples

This directory contains example configuration files for different types of projects. These examples demonstrate best practices and common patterns for using the project initialization system.

## Available Examples

### 1. Web Application (`web-app-config.yml`)

**Use Case:** Modern web applications (React, Vue, Angular, etc.)

**Features:**
- Frontend-focused project structure
- Modern web development practices
- Client-side deployment considerations

**Usage:**
```bash
./init-project.sh --config examples/web-app-config.yml
```

**Typical Tech Stack:**
- Frontend: React/Vue/Angular + TypeScript
- Build Tools: Vite/Webpack
- Styling: Tailwind CSS/Styled Components
- Testing: Jest/Vitest + Testing Library

### 2. CLI Tool (`cli-tool-config.yml`)

**Use Case:** Command-line applications and developer tools

**Features:**
- Command-line interface focus
- Cross-platform compatibility
- Distribution and installation guidance

**Usage:**
```bash
./init-project.sh --config examples/cli-tool-config.yml
```

**Typical Tech Stack:**
- Runtime: Node.js/Python/Go
- CLI Framework: Commander.js/Click/Cobra
- Package Management: npm/pip/go modules
- Distribution: npm/PyPI/GitHub Releases

### 3. Library (`library-config.yml`)

**Use Case:** Reusable libraries and packages

**Features:**
- Package-focused documentation
- API design considerations
- Distribution and versioning

**Usage:**
```bash
./init-project.sh --config examples/library-config.yml
```

**Typical Tech Stack:**
- Language: TypeScript/JavaScript/Python
- Build: Rollup/esbuild/setuptools
- Testing: Jest/pytest
- Documentation: TypeDoc/Sphinx

### 4. API Service (`api-service-config.yml`)

**Use Case:** Backend APIs and microservices

**Features:**
- API-first design approach
- Service architecture patterns
- Deployment and scaling considerations

**Usage:**
```bash
./init-project.sh --config examples/api-service-config.yml
```

**Typical Tech Stack:**
- Backend: Express.js/FastAPI/Gin
- Database: PostgreSQL/MongoDB
- Authentication: JWT/OAuth
- Deployment: Docker/Kubernetes

## Customizing Examples

### Basic Customization

1. **Copy an example:**
   ```bash
   cp examples/web-app-config.yml my-project-config.yml
   ```

2. **Edit the configuration:**
   ```yaml
   project_name: "Your Project Name"
   project_description: "Your project description"
   author_name: "Your Name"
   author_email: "your.email@example.com"
   ```

3. **Use your configuration:**
   ```bash
   ./init-project.sh --config my-project-config.yml
   ```

### Advanced Customization

You can extend the configuration files with additional metadata:

```yaml
# Standard fields
project_name: "My Project"
project_description: "Project description"
author_name: "Author Name"
author_email: "author@example.com"
license_type: "MIT"
project_type: "web"

# Custom fields (for documentation purposes)
repository_url: "https://github.com/user/repo"
documentation_url: "https://docs.example.com"
demo_url: "https://demo.example.com"
api_version: "v1"
target_audience: "Developers"
deployment_environment: "AWS"
```

## Project Type Guidelines

### Web Applications
- Focus on user experience and performance
- Include accessibility considerations
- Plan for responsive design
- Consider SEO requirements

### CLI Tools
- Emphasize usability and clear help text
- Plan for cross-platform compatibility
- Include installation and update mechanisms
- Consider configuration file support

### Libraries
- Design clean, intuitive APIs
- Provide comprehensive documentation
- Include usage examples
- Plan for backward compatibility

### API Services
- Design RESTful or GraphQL APIs
- Include authentication and authorization
- Plan for scalability and monitoring
- Document API endpoints thoroughly

## Best Practices

### Configuration Management

1. **Version Control:** Always commit your configuration files
2. **Team Sharing:** Use shared configurations for team consistency
3. **Environment Specific:** Create different configs for different environments
4. **Documentation:** Document any custom fields or special requirements

### Project Setup Workflow

1. **Choose Template:** Select the example closest to your project type
2. **Customize:** Modify the configuration for your specific needs
3. **Initialize:** Run the initialization script with your config
4. **Validate:** Use the validation script to check the setup
5. **Customize Further:** Modify templates as needed for your project

### Maintenance

1. **Regular Updates:** Keep configurations updated as projects evolve
2. **Template Evolution:** Update examples when new best practices emerge
3. **Team Feedback:** Incorporate team feedback into standard configurations

## Creating New Examples

To create a new example configuration:

1. **Identify the Use Case:** What type of project is this for?
2. **Create the Configuration:** Start with a similar existing example
3. **Test Thoroughly:** Ensure the configuration works correctly
4. **Document:** Add clear documentation about when to use it
5. **Add to This README:** Update this file with the new example

### Example Template

```yaml
# [Project Type] Project Configuration
# Use with: ./init-project.sh --config examples/[filename].yml

# Basic project information
project_name: "[Example Project Name]"
project_description: "[Brief description of what this project does]"

# Author information
author_name: "[Team/Author Name]"
author_email: "[contact@example.com]"

# Project settings
license_type: "[License Type]"
project_type: "[project_type]"

# Additional metadata (optional)
# Add any project-type specific fields here
```

## Troubleshooting

### Common Issues

1. **YAML Syntax Errors:**
   - Check indentation (use spaces, not tabs)
   - Ensure proper quoting of strings with special characters
   - Validate YAML syntax online if needed

2. **Missing Required Fields:**
   - Ensure all required fields are present
   - Check field names for typos

3. **File Not Found:**
   - Verify the path to the configuration file
   - Ensure the file has the correct extension (.yml or .yaml)

### Getting Help

1. **Validate Configuration:**
   ```bash
   ./validate-project.sh --verbose
   ```

2. **Test with Dry Run:**
   ```bash
   ./init-project.sh --config your-config.yml --dry-run
   ```

3. **Check Script Help:**
   ```bash
   ./init-project.sh --help
   ```
