# Project Initialization System - Usage Guide

**Version:** 2.0  
**Last Updated:** 2024-12-19

## Overview

The Project Initialization System provides a comprehensive, standardized approach to setting up new projects with consistent structure, documentation, and memory management. This system includes three main scripts and a collection of professional templates.

## Quick Start

### Basic Project Setup

```bash
# Navigate to your project directory
cd /path/to/your/project

# Run the initialization script
./docs/initialization-files/init-project.sh

# Validate the setup
./docs/initialization-files/validate-project.sh
```

### With Configuration

```bash
# Create a configuration file
cat > project-config.yml << EOF
project_name: "My Awesome Project"
project_description: "A revolutionary web application"
author_name: "John Doe"
author_email: "john@example.com"
license_type: "MIT"
project_type: "web"
EOF

# Initialize with configuration
./docs/initialization-files/init-project.sh --config project-config.yml
```

## Scripts Reference

### 1. init-project.sh

**Purpose:** Creates the initial project structure with all templates and memory bank files.

#### Basic Usage
```bash
./init-project.sh [OPTIONS]
```

#### Options
- `--dry-run` - Preview what would be created without making changes
- `--force` - Overwrite existing files without prompting
- `--config FILE` - Load configuration from YAML file
- `--name NAME` - Set project name
- `--description DESC` - Set project description
- `--author NAME` - Set author name
- `--email EMAIL` - Set author email
- `--license TYPE` - Set license type (MIT, Apache-2.0, GPL-3.0, etc.)
- `--type TYPE` - Set project type (web, cli, library, api)
- `--help` - Show detailed help

#### Examples
```bash
# Basic initialization
./init-project.sh

# Dry run to see what would be created
./init-project.sh --dry-run

# Initialize with specific settings
./init-project.sh --name "My Project" --author "Jane Smith" --type "api"

# Force overwrite existing files
./init-project.sh --force

# Use configuration file
./init-project.sh --config my-project.yml
```

### 2. validate-project.sh

**Purpose:** Validates project structure, file integrity, and configuration consistency.

#### Basic Usage
```bash
./validate-project.sh [OPTIONS]
```

#### Options
- `--verbose` - Show detailed validation information
- `--fix` - Attempt to fix common issues automatically
- `--report FILE` - Save validation report to file
- `--help` - Show help

#### Examples
```bash
# Basic validation
./validate-project.sh

# Verbose output with detailed information
./validate-project.sh --verbose

# Generate a report
./validate-project.sh --report validation-report.txt

# Attempt to fix issues automatically
./validate-project.sh --fix
```

### 3. update-project.sh

**Purpose:** Migrates existing projects to newer template versions while preserving content.

#### Basic Usage
```bash
./update-project.sh [OPTIONS]
```

#### Options
- `--dry-run` - Show what would be updated without making changes
- `--force` - Force update even if versions match
- `--target-version VER` - Specify target version (default: 2.0)
- `--help` - Show help

#### Examples
```bash
# Update to latest version
./update-project.sh

# Preview update changes
./update-project.sh --dry-run

# Force update even if already current
./update-project.sh --force
```

## Project Structure

After initialization, your project will have this structure:

```
project/
├── README.md                    # Enhanced project documentation
├── projectBrief.md             # Comprehensive project specification
├── .augment-guidelines         # AI assistant configuration
└── memory-bank/                # Project memory system
    ├── productContext.md       # Project goals and architecture
    ├── activeContext.md        # Current focus and recent changes
    ├── progress.md             # Task tracking and milestones
    ├── decisionLog.md          # Technical decisions log
    ├── systemPatterns.md       # Coding standards and patterns
    ├── dependencies.md         # Technology stack and versions
    ├── meetings.md             # Meeting notes and action items
    └── troubleshooting.md      # Common issues and solutions
```

## Configuration File Format

Configuration files use YAML format:

```yaml
# Basic project information
project_name: "My Project Name"
project_description: "Brief description of the project"

# Author information
author_name: "Your Name"
author_email: "your.email@example.com"

# Project settings
license_type: "MIT"           # MIT, Apache-2.0, GPL-3.0, BSD-3-Clause
project_type: "web"          # web, cli, library, api

# Optional: Custom settings
custom_field: "custom_value"
```

## Memory Bank System

The memory bank is the core of the project's knowledge management system:

### Core Files

1. **productContext.md** - High-level project information
   - Project goals and objectives
   - Target audience and stakeholders
   - Key features and architecture overview

2. **activeContext.md** - Current project state
   - What you're currently working on
   - Recent changes and decisions
   - Open questions and blockers

3. **progress.md** - Task and milestone tracking
   - Completed tasks
   - Current work in progress
   - Backlog and future plans

4. **decisionLog.md** - Technical decision history
   - Architecture decisions
   - Technology choices
   - Design patterns adopted

5. **systemPatterns.md** - Development standards
   - Coding style and conventions
   - Testing strategies
   - Performance guidelines
   - Monitoring and logging standards

### Extended Files (v2.0+)

6. **dependencies.md** - Technology stack management
   - Production and development dependencies
   - Version tracking and update decisions
   - Security considerations

7. **meetings.md** - Communication history
   - Meeting notes and decisions
   - Action items and follow-ups
   - Stakeholder communications

8. **troubleshooting.md** - Problem-solving knowledge
   - Common issues and solutions
   - Debugging strategies
   - Emergency procedures

## Best Practices

### Initial Setup

1. **Start with projectBrief.md**
   - Define clear project goals and scope
   - Identify stakeholders and success criteria
   - Document technical requirements

2. **Populate productContext.md**
   - Extract key information from project brief
   - Define high-level architecture
   - Identify target audience

3. **Configure systemPatterns.md**
   - Set coding standards early
   - Define testing strategies
   - Establish monitoring practices

### Ongoing Maintenance

1. **Regular Updates**
   - Update activeContext.md weekly
   - Log decisions in decisionLog.md immediately
   - Track progress in progress.md regularly

2. **Validation**
   - Run validate-project.sh before major milestones
   - Address warnings and errors promptly
   - Keep documentation current

3. **Team Collaboration**
   - Use meetings.md for team communications
   - Share troubleshooting knowledge
   - Maintain dependency documentation

## Troubleshooting

### Common Issues

#### "Permission denied" when running scripts
```bash
# Make scripts executable
chmod +x docs/initialization-files/*.sh
```

#### "File already exists" warnings
```bash
# Use --force to overwrite
./init-project.sh --force

# Or use --dry-run to preview changes
./init-project.sh --dry-run
```

#### Validation failures
```bash
# Run with verbose output to see details
./validate-project.sh --verbose

# Attempt automatic fixes
./validate-project.sh --fix
```

### Getting Help

1. **Script Help**
   ```bash
   ./init-project.sh --help
   ./validate-project.sh --help
   ./update-project.sh --help
   ```

2. **Validation Reports**
   ```bash
   ./validate-project.sh --report issues.txt
   cat issues.txt
   ```

3. **Dry Run Mode**
   ```bash
   # Preview any script's actions
   ./script-name.sh --dry-run
   ```

## Advanced Usage

### Custom Project Types

The system supports different project types with appropriate defaults:

- **web** - Web applications (React, Vue, Angular, etc.)
- **cli** - Command-line tools
- **library** - Reusable libraries and packages
- **api** - Backend APIs and services

### Integration with CI/CD

```bash
# Add validation to your CI pipeline
./docs/initialization-files/validate-project.sh --report validation.txt
```

### Team Onboarding

1. New team members run validation to check setup
2. Use troubleshooting.md for common environment issues
3. Reference systemPatterns.md for coding standards

## Version History

- **v2.0** - Added dependencies.md, meetings.md, troubleshooting.md, configuration support
- **v1.0** - Initial release with core memory bank system

## Support

For issues or questions:
1. Check troubleshooting.md in your project
2. Run validation with --verbose flag
3. Review this usage guide
4. Check script help with --help flag
