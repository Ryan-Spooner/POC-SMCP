#!/bin/zsh

# Project Initialization Script with Safety Features
# Version: 2.0
# Enhanced with file existence checks, backup mechanism, and dry-run mode

# Exit immediately if a command exits with a non-zero status.
set -e
# Treat unset variables as an error when substituting.
set -u
# Prevent errors in pipelines from being masked.
set -o pipefail

# --- Configuration ---
SCRIPT_VERSION="2.0"
BACKUP_DIR="backup-$(date '+%Y%m%d-%H%M%S')"
DRY_RUN=false
FORCE_OVERWRITE=false
CONFIG_FILE=""

# Default project configuration
PROJECT_NAME=""
PROJECT_DESCRIPTION=""
AUTHOR_NAME=""
AUTHOR_EMAIL=""
LICENSE_TYPE="MIT"
PROJECT_TYPE="web"  # web, cli, library, api

# --- Parse Command Line Arguments ---
while [[ $# -gt 0 ]]; do
  case $1 in
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --force)
      FORCE_OVERWRITE=true
      shift
      ;;
    --config)
      CONFIG_FILE="$2"
      shift 2
      ;;
    --name)
      PROJECT_NAME="$2"
      shift 2
      ;;
    --description)
      PROJECT_DESCRIPTION="$2"
      shift 2
      ;;
    --author)
      AUTHOR_NAME="$2"
      shift 2
      ;;
    --email)
      AUTHOR_EMAIL="$2"
      shift 2
      ;;
    --license)
      LICENSE_TYPE="$2"
      shift 2
      ;;
    --type)
      PROJECT_TYPE="$2"
      shift 2
      ;;
    --help|-h)
      echo "Project Initialization Script v${SCRIPT_VERSION}"
      echo ""
      echo "Usage: $0 [OPTIONS]"
      echo ""
      echo "Options:"
      echo "  --dry-run              Show what would be created without making changes"
      echo "  --force                Overwrite existing files without prompting"
      echo "  --config FILE          Load configuration from file"
      echo "  --name NAME            Set project name"
      echo "  --description DESC     Set project description"
      echo "  --author NAME          Set author name"
      echo "  --email EMAIL          Set author email"
      echo "  --license TYPE         Set license type (MIT, Apache-2.0, GPL-3.0, etc.)"
      echo "  --type TYPE            Set project type (web, cli, library, api)"
      echo "  --help, -h             Show this help message"
      echo ""
      echo "Configuration File Format (YAML):"
      echo "  project_name: \"My Project\""
      echo "  project_description: \"A brief description\""
      echo "  author_name: \"John Doe\""
      echo "  author_email: \"john@example.com\""
      echo "  license_type: \"MIT\""
      echo "  project_type: \"web\""
      echo ""
      echo "This script creates a standardized project structure with:"
      echo "  - Memory bank directory and files"
      echo "  - Enhanced README.md template"
      echo "  - Comprehensive projectBrief.md template"
      echo "  - .augment-guidelines configuration"
      echo ""
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      echo "Use --help for usage information"
      exit 1
      ;;
  esac
done

# --- Helper Functions ---
log_info() {
  echo "ℹ️  $1"
}

log_success() {
  echo "✅ $1"
}

log_warning() {
  echo "⚠️  $1"
}

log_error() {
  echo "❌ $1"
}

# --- Load Configuration File ---
load_config() {
  local config_file="$1"

  if [[ ! -f "$config_file" ]]; then
    log_error "Configuration file not found: $config_file"
    exit 1
  fi

  log_info "Loading configuration from: $config_file"

  # Simple YAML parser for basic key-value pairs
  while IFS=': ' read -r key value; do
    # Skip comments and empty lines
    [[ "$key" =~ ^[[:space:]]*# ]] && continue
    [[ -z "$key" ]] && continue

    # Remove quotes from value
    value=$(echo "$value" | sed 's/^["'\'']//' | sed 's/["'\'']$//')

    case "$key" in
      project_name)
        [[ -z "$PROJECT_NAME" ]] && PROJECT_NAME="$value"
        ;;
      project_description)
        [[ -z "$PROJECT_DESCRIPTION" ]] && PROJECT_DESCRIPTION="$value"
        ;;
      author_name)
        [[ -z "$AUTHOR_NAME" ]] && AUTHOR_NAME="$value"
        ;;
      author_email)
        [[ -z "$AUTHOR_EMAIL" ]] && AUTHOR_EMAIL="$value"
        ;;
      license_type)
        [[ -z "$LICENSE_TYPE" || "$LICENSE_TYPE" == "MIT" ]] && LICENSE_TYPE="$value"
        ;;
      project_type)
        [[ -z "$PROJECT_TYPE" || "$PROJECT_TYPE" == "web" ]] && PROJECT_TYPE="$value"
        ;;
    esac
  done < "$config_file"
}

# Get current date and timestamp
CURRENT_DATE=$(date '+%Y-%m-%d')
CURRENT_TS=$(date '+%Y-%m-%d %H:%M:%S')

# Load configuration file if specified
if [[ -n "$CONFIG_FILE" ]]; then
  load_config "$CONFIG_FILE"
fi

# Check if file exists and handle accordingly
check_file_exists() {
  local file_path="$1"
  local file_description="$2"

  if [[ -f "$file_path" ]]; then
    if [[ "$FORCE_OVERWRITE" == "true" ]]; then
      log_warning "Will overwrite existing $file_description: $file_path"
      return 0
    elif [[ "$DRY_RUN" == "false" ]]; then
      log_warning "File already exists: $file_path"
      echo -n "Do you want to overwrite it? [y/N]: "
      read -r response
      case "$response" in
        [yY][eE][sS]|[yY])
          log_info "Will overwrite $file_path"
          return 0
          ;;
        *)
          log_info "Skipping $file_path"
          return 1
          ;;
      esac
    else
      log_warning "Would overwrite existing $file_description: $file_path"
      return 0
    fi
  fi
  return 0
}

# Create backup of existing file
backup_file() {
  local file_path="$1"

  if [[ -f "$file_path" && "$DRY_RUN" == "false" ]]; then
    if [[ ! -d "$BACKUP_DIR" ]]; then
      mkdir -p "$BACKUP_DIR"
      log_info "Created backup directory: $BACKUP_DIR"
    fi

    cp "$file_path" "$BACKUP_DIR/"
    log_info "Backed up $file_path to $BACKUP_DIR/"
  fi
}

# Create file with content (respects dry-run mode)
create_file() {
  local file_path="$1"
  local file_description="$2"
  local content="$3"

  if [[ "$DRY_RUN" == "true" ]]; then
    log_info "Would create $file_description: $file_path"
    return 0
  fi

  if check_file_exists "$file_path" "$file_description"; then
    backup_file "$file_path"
    # Apply configuration substitutions
    content=$(substitute_placeholders "$content")
    echo "$content" > "$file_path"
    log_success "Created $file_description: $file_path"
  else
    log_info "Skipped $file_description: $file_path"
  fi
}

# Substitute configuration placeholders in content
substitute_placeholders() {
  local content="$1"

  # Only substitute if values are provided
  if [[ -n "$PROJECT_NAME" ]]; then
    content=$(echo "$content" | sed "s/Project Title (Replace Me)/$PROJECT_NAME/g")
    content=$(echo "$content" | sed "s/\[Project Name\]/$PROJECT_NAME/g")
  fi

  if [[ -n "$PROJECT_DESCRIPTION" ]]; then
    content=$(echo "$content" | sed "s/One-line description of the project. (Replace Me)/$PROJECT_DESCRIPTION/g")
    content=$(echo "$content" | sed "s/\[Project Description\]/$PROJECT_DESCRIPTION/g")
  fi

  if [[ -n "$AUTHOR_NAME" ]]; then
    content=$(echo "$content" | sed "s/\[Name\]/$AUTHOR_NAME/g")
    content=$(echo "$content" | sed "s/\[Author Name\]/$AUTHOR_NAME/g")
    content=$(echo "$content" | sed "s/username\/repo/$AUTHOR_NAME\/$(basename "$PWD")/g")
  fi

  if [[ -n "$AUTHOR_EMAIL" ]]; then
    content=$(echo "$content" | sed "s/(Add contact email)/$AUTHOR_EMAIL/g")
    content=$(echo "$content" | sed "s/\[Author Email\]/$AUTHOR_EMAIL/g")
  fi

  if [[ -n "$LICENSE_TYPE" ]]; then
    content=$(echo "$content" | sed "s/MIT License/$LICENSE_TYPE License/g")
    content=$(echo "$content" | sed "s/license-MIT-blue/$LICENSE_TYPE-blue/g")
  fi

  # Add current date
  content=$(echo "$content" | sed "s/\[YYYY-MM-DD\]/$CURRENT_DATE/g")
  content=$(echo "$content" | sed "s/\[YYYY-MM-DD HH:MM:SS\]/$CURRENT_TS/g")

  echo "$content"
}

# --- Main Script ---
echo "🚀 Project Initialization Script v${SCRIPT_VERSION}"
echo "=================================================="

if [[ "$DRY_RUN" == "true" ]]; then
  log_info "DRY RUN MODE - No files will be created or modified"
  echo ""
fi

# Display configuration summary
echo ""
log_info "Configuration Summary:"
echo "  📝 Project Name: ${PROJECT_NAME:-"[Not specified]"}"
echo "  📄 Description: ${PROJECT_DESCRIPTION:-"[Not specified]"}"
echo "  👤 Author: ${AUTHOR_NAME:-"[Not specified]"}"
echo "  📧 Email: ${AUTHOR_EMAIL:-"[Not specified]"}"
echo "  📜 License: $LICENSE_TYPE"
echo "  🏗️  Type: $PROJECT_TYPE"
echo ""

log_info "Initializing project structure..."

# --- Create Directories ---
log_info "Creating memory-bank directory"
if [[ "$DRY_RUN" == "false" ]]; then
  mkdir -p memory-bank
  log_success "Created memory-bank directory"
else
  log_info "Would create memory-bank directory"
fi

# --- Create Memory Bank Files ---
log_info "Creating memory-bank files"

# Define content for productContext.md
PRODUCT_CONTEXT_CONTENT=$(cat << 'EOF'
---
Source: Based on projectBrief.md and initial discussions.
Updates: Appended by AI as project understanding evolves.
Last Reviewed: [YYYY-MM-DD]
---

# Product Context

## Project Goal
* [Brief description of the overall aim. Add once projectBrief.md is finalized]

## Key Features
* [List of primary features or user stories. Add once projectBrief.md is finalized]

## Target Audience
* [Who is this product for? Add once projectBrief.md is finalized]

## High-Level Architecture
* [Overview of major components and technologies. Define as early as possible]
EOF
)

create_file "memory-bank/productContext.md" "Product Context file" "$PRODUCT_CONTEXT_CONTENT"

# Define content for activeContext.md
ACTIVE_CONTEXT_CONTENT=$(cat << 'EOF'
---
Purpose: Tracks the immediate state of work for AI assistance.
Updates: Sections often replaced by AI based on recent activity.
Timestamp: [YYYY-MM-DD HH:MM:SS]
---

# Active Context

## Current Focus
* [Specific task, module, or problem being worked on right now]

## Recent Significant Changes (Last 1-2 sessions)
* [Brief summary of major code changes, file additions, etc.]

## Open Questions / Blockers / Issues
* [Any unresolved questions, dependencies, or problems hindering progress]

## Next Immediate Step(s)
* [What the user plans to do next]
EOF
)

create_file "memory-bank/activeContext.md" "Active Context file" "$ACTIVE_CONTEXT_CONTENT"

# Define content for progress.md
PROGRESS_CONTENT=$(cat << 'EOF'
---
Purpose: High-level overview of task status.
Updates: Primarily appended by AI upon task completion or discovery.
Last Updated: [YYYY-MM-DD]
---

# Progress Tracker

## Completed Tasks
* [YYYY-MM-DD] - [Description of completed task]

## Current Tasks / In Progress
* [Task ID/Link] - [Description of task currently being worked on]

## Blocked Tasks
* [Task ID/Link] - [Description] - **Blocker:** [Reason]

## Next Steps / Backlog (Prioritized)
* [Task ID/Link] - [Description]

## Discovered During Work (Needs Triaging)
* [YYYY-MM-DD] - [New subtask, bug, or required refactor identified]
EOF
)

create_file "memory-bank/progress.md" "Progress Tracker file" "$PROGRESS_CONTENT"

# Define content for decisionLog.md
DECISION_LOG_CONTENT=$(cat << 'EOF'
---
Purpose: Records significant technical or architectural choices.
Updates: New decisions appended by AI or user.
---

# Decision Log

**Decision:**
* [Clear statement of the decision made]

**Rationale:**
* [Why this decision was made; alternatives considered]

**Context/Trigger:**
* [What led to needing this decision?]

**Implementation Notes:**
* [Key files affected, specific techniques used, gotchas]

**Timestamp:** [YYYY-MM-DD HH:MM:SS]

---

*(New entries added above this line)*
EOF
)

create_file "memory-bank/decisionLog.md" "Decision Log file" "$DECISION_LOG_CONTENT"

# Define content for systemPatterns.md
SYSTEM_PATTERNS_CONTENT=$(cat << 'EOF'
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
EOF
)

create_file "memory-bank/systemPatterns.md" "System Patterns file" "$SYSTEM_PATTERNS_CONTENT"

# Define content for dependencies.md
DEPENDENCIES_CONTENT=$(cat << 'EOF'
---
Purpose: Track technology choices, versions, and dependency management decisions.
Updates: Updated by AI/user when dependencies are added, updated, or removed.
Last Reviewed: [YYYY-MM-DD]
---

# Dependencies & Technology Stack

## Core Dependencies

### Production Dependencies
| Package/Library | Version | Purpose | Installation Command | Notes |
|----------------|---------|---------|---------------------|-------|
| [Package Name] | [Version] | [Brief description] | `[install command]` | [Any important notes] |

### Development Dependencies
| Package/Library | Version | Purpose | Installation Command | Notes |
|----------------|---------|---------|---------------------|-------|
| [Package Name] | [Version] | [Brief description] | `[install command]` | [Any important notes] |

## Technology Stack

### Frontend
- **Framework:** [e.g., React 18.2.0, Vue 3.x, Angular 15.x]
- **Build Tool:** [e.g., Vite, Webpack, Parcel]
- **Styling:** [e.g., Tailwind CSS, Styled Components, SCSS]
- **State Management:** [e.g., Redux, Zustand, Pinia]

### Backend
- **Runtime/Language:** [e.g., Node.js 18.x, Python 3.11, Go 1.19]
- **Framework:** [e.g., Express.js, FastAPI, Gin]
- **Database:** [e.g., PostgreSQL 15.x, MongoDB 6.x, Redis 7.x]
- **ORM/ODM:** [e.g., Prisma, SQLAlchemy, Mongoose]

### Infrastructure & DevOps
- **Hosting:** [e.g., Vercel, AWS, Google Cloud, Docker]
- **CI/CD:** [e.g., GitHub Actions, GitLab CI, Jenkins]
- **Monitoring:** [e.g., Sentry, DataDog, New Relic]
- **Analytics:** [e.g., Google Analytics, Mixpanel, PostHog]

## Dependency Decisions Log

### [YYYY-MM-DD] - [Decision Title]
**Decision:** [What was decided]
**Rationale:** [Why this choice was made]
**Alternatives Considered:** [Other options that were evaluated]
**Impact:** [How this affects the project]

## Troubleshooting

### Common Issues
- **Issue:** [Description of common dependency problem]
- **Solution:** [How to resolve it]
- **Prevention:** [How to avoid it in the future]

---

**Note:** Keep this file updated whenever dependencies are added, removed, or significantly updated.
EOF
)

create_file "memory-bank/dependencies.md" "Dependencies file" "$DEPENDENCIES_CONTENT"

# Define content for meetings.md
MEETINGS_CONTENT=$(cat << 'EOF'
---
Purpose: Record important project discussions, decisions, and action items from meetings.
Updates: Added by AI/user after significant meetings or discussions.
Last Reviewed: [YYYY-MM-DD]
---

# Meeting Notes & Discussions

## Meeting Template

### [YYYY-MM-DD] - [Meeting Title/Type]
**Date:** [YYYY-MM-DD]
**Time:** [HH:MM - HH:MM]
**Type:** [Kickoff, Sprint Planning, Review, Stakeholder, Technical Discussion, etc.]
**Attendees:** [List of participants]
**Meeting Lead:** [Name]

#### Agenda
1. [Agenda item 1]
2. [Agenda item 2]
3. [Agenda item 3]

#### Key Discussions
- **Topic:** [Discussion topic]
  - **Summary:** [Brief summary of discussion]
  - **Outcome:** [What was decided or concluded]

#### Decisions Made
- **Decision:** [Clear statement of decision]
- **Rationale:** [Why this decision was made]
- **Owner:** [Who is responsible for implementation]
- **Timeline:** [When this should be completed]

#### Action Items
- [ ] **[Action Item]** - Assigned to: [Name] - Due: [YYYY-MM-DD]
- [ ] **[Action Item]** - Assigned to: [Name] - Due: [YYYY-MM-DD]

#### Next Steps
- [What happens next]
- [Follow-up meetings needed]

---

## Meeting Action Items Tracker

### Open Action Items
- [ ] **[Action Item]** - Assigned to: [Name] - Due: [Date] - From: [Meeting]

### Completed Action Items
- ✅ **[Completed Action]** - Completed: [Date] - From: [Meeting]

---

**Note:** Update this file after each significant meeting or discussion.
EOF
)

create_file "memory-bank/meetings.md" "Meetings file" "$MEETINGS_CONTENT"

# Define content for troubleshooting.md
TROUBLESHOOTING_CONTENT=$(cat << 'EOF'
---
Purpose: Document common issues, solutions, and debugging strategies for the project.
Updates: Added by AI/user when new issues are discovered and resolved.
Last Reviewed: [YYYY-MM-DD]
---

# Troubleshooting Guide

## Common Issues & Solutions

### Development Environment

#### Issue: [Common Dev Environment Problem]
**Symptoms:**
- [Symptom 1]
- [Symptom 2]

**Cause:**
[Root cause explanation]

**Solution:**
```bash
# Step-by-step solution
[command 1]
[command 2]
```

**Prevention:**
[How to avoid this issue in the future]

---

### Build & Deployment Issues

#### Issue: Build Failures
**Symptoms:**
- Build process stops with errors
- Missing assets in build output

**Common Solutions:**
```bash
# Clean build
npm run clean
npm run build

# Check environment variables
echo $NODE_ENV
```

---

### Runtime Issues

#### Issue: Performance Problems
**Symptoms:**
- Slow response times
- High memory usage

**Debugging Steps:**
1. Check application metrics
2. Profile the application
3. Check database performance

---

## Debugging Strategies

### Log Analysis
```bash
# View recent logs
[log-view-command]

# Search logs for specific errors
[log-search-command]
```

## Emergency Procedures

### Production Incident Response
1. Assess impact and severity
2. Notify stakeholders
3. Begin investigation
4. Implement fix or rollback

---

**Note:** Keep this guide updated with new issues and solutions.
EOF
)

create_file "memory-bank/troubleshooting.md" "Troubleshooting file" "$TROUBLESHOOTING_CONTENT"

log_success "Memory bank files processing completed"

# --- Create README.md (Enhanced template) ---
log_info "Creating README.md..."

# Define content for README.md
README_CONTENT=$(cat << 'EOF'
# Project Title (Replace Me)

[![Build Status](https://img.shields.io/badge/build-passing-brightgreen)](https://github.com/username/repo)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](https://github.com/username/repo/releases)

One-line description of the project. (Replace Me)

## Table of Contents

- [Overview](#overview)
- [Installation](#installation)
- [Usage](#usage)
- [API Documentation](#api-documentation)
- [Development](#development)
- [Testing](#testing)
- [Contributing](#contributing)
- [License](#license)

## Overview

(Provide a more detailed overview of the project goals and functionality)

### Key Features

- Feature 1: (Brief description)
- Feature 2: (Brief description)
- Feature 3: (Brief description)

### Prerequisites

- (List any software, tools, or dependencies required)
- (e.g., Node.js 18+, Python 3.9+, Docker, etc.)

## Installation

### Quick Start

```bash
# Clone the repository
git clone https://github.com/username/repo.git
cd repo

# Install dependencies
(Add installation commands here)

# Run the application
(Add run commands here)
```

### Detailed Installation

(Provide step-by-step installation instructions)

## Usage

### Basic Usage

```bash
# Example command
(Add usage examples here)
```

### Advanced Usage

(Provide more complex usage examples and configuration options)

## API Documentation

(If applicable, provide API documentation or link to external docs)

### Endpoints

- `GET /api/endpoint` - Description
- `POST /api/endpoint` - Description

## Development

### Development Setup

```bash
# Clone and setup for development
git clone https://github.com/username/repo.git
cd repo

# Install development dependencies
(Add dev setup commands)

# Start development server
(Add dev server commands)
```

### Project Structure

```
project/
├── src/           # Source code
├── tests/         # Test files
├── docs/          # Documentation
├── config/        # Configuration files
└── README.md      # This file
```

### Coding Standards

- (List coding standards, linting rules, formatting requirements)
- (Reference to style guides or configuration files)

## Testing

```bash
# Run all tests
(Add test commands)

# Run specific test suite
(Add specific test commands)

# Generate coverage report
(Add coverage commands)
```

## Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

### Quick Contribution Guide

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Workflow

(Describe the development workflow, code review process, etc.)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

- 📧 Email: (Add contact email)
- 🐛 Issues: [GitHub Issues](https://github.com/username/repo/issues)
- 📖 Documentation: [Project Wiki](https://github.com/username/repo/wiki)

## Acknowledgments

- (Credit contributors, libraries, or resources used)
- (Thank sponsors or supporters)
EOF
)

create_file "README.md" "README file" "$README_CONTENT"

# --- Create projectBrief.md (Enhanced template) ---
log_info "Creating projectBrief.md..."

# Define content for projectBrief.md
PROJECT_BRIEF_CONTENT=$(cat << 'EOF'
# Project Brief

**Document Purpose:** Define project scope, requirements, and success criteria
**Created:** [YYYY-MM-DD]
**Last Updated:** [YYYY-MM-DD]
**Status:** Draft | In Review | Approved

## Executive Summary

(Provide a 2-3 sentence high-level summary of the project)

## Overview

### Project Purpose
- (Describe the problem this project solves)
- (Explain why this project is needed now)

### Target Audience
- **Primary Users:** (Who will use this directly?)
- **Secondary Users:** (Who will benefit indirectly?)
- **Stakeholders:** (Who has decision-making authority?)

### High-Level Goals
- Goal 1: (Specific, measurable objective)
- Goal 2: (Specific, measurable objective)
- Goal 3: (Specific, measurable objective)

## Success Criteria

### Definition of Done
- [ ] Criterion 1: (Specific, measurable outcome)
- [ ] Criterion 2: (Specific, measurable outcome)
- [ ] Criterion 3: (Specific, measurable outcome)

### Key Performance Indicators (KPIs)
- **Performance:** (e.g., response time < 200ms)
- **Usage:** (e.g., 100+ daily active users)
- **Quality:** (e.g., 99.9% uptime)

### Acceptance Criteria
- (List specific conditions that must be met for project completion)

## Technical Requirements

### Functional Requirements
- **Core Features:**
  - Feature 1: (Detailed description)
  - Feature 2: (Detailed description)
  - Feature 3: (Detailed description)

- **User Stories:**
  - As a [user type], I want [functionality] so that [benefit]
  - As a [user type], I want [functionality] so that [benefit]

### Non-Functional Requirements
- **Performance:** (Response times, throughput, scalability)
- **Security:** (Authentication, authorization, data protection)
- **Reliability:** (Uptime, error handling, recovery)
- **Usability:** (User experience, accessibility)
- **Compatibility:** (Browser support, device compatibility)

### Technical Stack
- **Frontend:** (Framework, libraries, tools)
- **Backend:** (Language, framework, database)
- **Infrastructure:** (Hosting, deployment, monitoring)
- **Development Tools:** (IDE, testing, CI/CD)

## Stakeholders

### Project Team
- **Project Owner:** [Name] - [Role/Responsibility]
- **Technical Lead:** [Name] - [Role/Responsibility]
- **Developers:** [Names] - [Roles/Responsibilities]
- **Designers:** [Names] - [Roles/Responsibilities]

### Business Stakeholders
- **Sponsor:** [Name] - [Decision authority]
- **Product Manager:** [Name] - [Requirements authority]
- **End Users:** [Representative groups]

## Timeline & Milestones

### Project Phases
1. **Discovery & Planning** ([Start Date] - [End Date])
   - Requirements gathering
   - Technical design
   - Resource allocation

2. **Development Phase 1** ([Start Date] - [End Date])
   - Core functionality
   - Basic UI/UX
   - Initial testing

3. **Development Phase 2** ([Start Date] - [End Date])
   - Advanced features
   - Integration testing
   - Performance optimization

4. **Testing & Deployment** ([Start Date] - [End Date])
   - User acceptance testing
   - Production deployment
   - Documentation

### Key Milestones
- [ ] **[Date]:** Project kickoff and requirements finalized
- [ ] **[Date]:** Technical architecture approved
- [ ] **[Date]:** MVP (Minimum Viable Product) completed
- [ ] **[Date]:** Beta version ready for testing
- [ ] **[Date]:** Production release
- [ ] **[Date]:** Post-launch review completed

## Constraints & Assumptions

### Technical Constraints
- **Budget:** $[Amount] total budget
- **Timeline:** Must be completed by [Date]
- **Resources:** [Number] developers available
- **Technology:** Must use [specific technologies/platforms]

### Business Constraints
- **Regulatory:** (Compliance requirements)
- **Integration:** (Must work with existing systems)
- **Performance:** (Specific performance requirements)

### Assumptions
- **User Adoption:** (Expected usage patterns)
- **Technical:** (Technology availability, team skills)
- **Business:** (Market conditions, resource availability)
- **External Dependencies:** (Third-party services, APIs)

## Risks & Mitigation

### High-Risk Items
- **Risk 1:** [Description] - **Mitigation:** [Strategy]
- **Risk 2:** [Description] - **Mitigation:** [Strategy]

### Medium-Risk Items
- **Risk 3:** [Description] - **Mitigation:** [Strategy]

## Out of Scope

### Explicitly Excluded Features
- Feature X: (Reason for exclusion)
- Feature Y: (Reason for exclusion)

### Future Considerations
- Enhancement A: (Potential future addition)
- Enhancement B: (Potential future addition)

## Dependencies

### Internal Dependencies
- (Other projects or teams this depends on)

### External Dependencies
- (Third-party services, vendors, or external factors)

## Communication Plan

### Regular Updates
- **Daily Standups:** [Time/Frequency]
- **Sprint Reviews:** [Frequency]
- **Stakeholder Updates:** [Frequency]

### Escalation Path
- **Technical Issues:** [Contact/Process]
- **Scope Changes:** [Contact/Process]
- **Timeline Issues:** [Contact/Process]

## Approval

- [ ] **Technical Lead:** [Name] - [Date]
- [ ] **Product Owner:** [Name] - [Date]
- [ ] **Project Sponsor:** [Name] - [Date]

---

**Note:** This document should be reviewed and updated regularly throughout the project lifecycle.

EOF
)

create_file "projectBrief.md" "Project Brief file" "$PROJECT_BRIEF_CONTENT"

# --- Create .augment-guidelines (Version 2.0) ---
log_info "Creating .augment-guidelines..."

# Define content for .augment-guidelines
AUGMENT_GUIDELINES_CONTENT=$(cat << 'EOF'
# .augment-guidelines
# Defines rules and context management for the AI assistant in this workspace.
# Version: 1.0

# --- Rule Priority ---
# Ensures these workspace-specific rules take precedence over any global settings.
rule_priority:
  description: "These Workspace AI Rules override any conflicting global or system rules."
  precedence: ABSOLUTE # Workspace rules are final.

# --- Memory System ---
# Configures the file-based memory bank used by the AI for context persistence.
memory_system:
  type: memory-bank # Specifies the type of memory system.
  directory: ./memory-bank # Relative path to the directory storing memory files.

  # Core Files: Key documents the AI should be aware of and potentially update.
  core_files:
    productContext: productContext.md   # High-level project goals, features, architecture.
    activeContext: activeContext.md    # Current focus, recent changes, open questions.
    progress: progress.md            # Task tracking (completed, current, backlog).
    decisionLog: decisionLog.md        # Log of significant technical decisions.
    systemPatterns: systemPatterns.md  # Recurring code patterns, architectural choices, style guides.

  # Update Strategy: Defines how the AI should modify core files.
  # Options: APPEND (add to end), REPLACE_SECTION (find header, replace content below it), OVERWRITE (replace entire file).
  # Note: The AI should use judgment; e.g., 'APPEND' to logs, 'REPLACE_SECTION' for dynamic states.
  update_strategies:
    productContext.md: APPEND # Product context generally evolves by adding info.
    activeContext.md: REPLACE_SECTION # Current focus/changes usually replace previous state. Use ## headers as anchors.
    progress.md: APPEND # Append completed tasks, discovered items. Current tasks might need section replacement.
    decisionLog.md: APPEND # Always append new decisions chronologically.
    systemPatterns.md: APPEND # Add new patterns or refine existing ones (manual edit might be better for refinement).

  # Initial Content Templates: Defines the structure if files need creation.
  # These are primarily for reference; an initialization script should handle actual creation.
  initial_content_templates:
    productContext.md: |
      ---
      Source: Based on projectBrief.md and initial discussions.
      Updates: Appended by AI as project understanding evolves.
      Last Reviewed: [YYYY-MM-DD]
      ---

      # Product Context

      ## Project Goal
      * [Brief description of the overall aim]

      ## Key Features
      * [List of primary features or user stories]

      ## Target Audience
      * [Who is this product for?]

      ## High-Level Architecture
      * [Overview of major components and technologies]

    activeContext.md: |
      ---
      Purpose: Tracks the immediate state of work for AI assistance.
      Updates: Sections often replaced by AI based on recent activity.
      Timestamp: [YYYY-MM-DD HH:MM:SS]
      ---

      # Active Context

      ## Current Focus
      * [Specific task, module, or problem being worked on right now]

      ## Recent Significant Changes (Last 1-2 sessions)
      * [Brief summary of major code changes, file additions, etc.]

      ## Open Questions / Blockers / Issues
      * [Any unresolved questions, dependencies, or problems hindering progress]

      ## Next Immediate Step(s)
      * [What the user plans to do next]

    progress.md: |
      ---
      Purpose: High-level overview of task status.
      Updates: Primarily appended by AI upon task completion or discovery.
      Last Updated: [YYYY-MM-DD]
      ---

      # Progress Tracker

      ## Completed Tasks
      * [YYYY-MM-DD] - [Description of completed task]

      ## Current Tasks / In Progress
      * [Task ID/Link] - [Description of task currently being worked on]

      ## Blocked Tasks
      * [Task ID/Link] - [Description] - **Blocker:** [Reason]

      ## Next Steps / Backlog (Prioritized)
      * [Task ID/Link] - [Description]

      ## Discovered During Work (Needs Triaging)
      * [YYYY-MM-DD] - [New subtask, bug, or required refactor identified]

    decisionLog.md: |
      ---
      Purpose: Records significant technical or architectural choices.
      Updates: New decisions appended by AI or user.
      ---

      # Decision Log

      **Decision:**
      * [Clear statement of the decision made]

      **Rationale:**
      * [Why this decision was made; alternatives considered]

      **Context/Trigger:**
      * [What led to needing this decision?]

      **Implementation Notes:**
      * [Key files affected, specific techniques used, gotchas]

      **Timestamp:** [YYYY-MM-DD HH:MM:SS]

      ---

      *(New entries added above this line)*

    systemPatterns.md: |
     ---
     Purpose: Documents recurring design patterns, coding standards, and architectural choices specific to this project.
     Updates: Appended or refined by AI/user as patterns emerge or standards are set.
     Last Reviewed: [YYYY-MM-DD]
     ---

     # System Patterns & Conventions

     ## Coding Style / Linting
     * [Linter: (add if defined]
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
     * [Add if defined]

     ## Security Considerations
     * [e.g., Input validation practices, secrets management (.env), dependency scanning]

     ## Deployment Patterns
     * [add if defined]
EOF
)

create_file ".augment-guidelines" "Augment Guidelines file" "$AUGMENT_GUIDELINES_CONTENT"

# --- Completion Summary ---
echo ""
echo "=================================================="
log_success "Project initialization completed successfully!"
echo "=================================================="

if [[ "$DRY_RUN" == "false" ]]; then
  echo ""
  log_info "Files created:"
  echo "  📁 memory-bank/"
  echo "    📄 productContext.md"
  echo "    📄 activeContext.md"
  echo "    📄 progress.md"
  echo "    📄 decisionLog.md"
  echo "    📄 systemPatterns.md"
  echo "    📄 dependencies.md"
  echo "    📄 meetings.md"
  echo "    📄 troubleshooting.md"
  echo "  📄 README.md"
  echo "  📄 projectBrief.md"
  echo "  📄 .augment-guidelines"

  if [[ -d "$BACKUP_DIR" ]]; then
    echo ""
    log_info "Backup files saved in: $BACKUP_DIR"
  fi

  echo ""
  log_info "Next steps:"
  echo "  1. Review and customize projectBrief.md with your project details"
  echo "  2. Update README.md with project-specific information"
  echo "  3. Populate memory-bank files as development progresses"
  echo "  4. Customize .augment-guidelines if needed"
  echo ""
  log_info "Configuration tips:"
  echo "  • Create a config file for reusable project settings:"
  echo "    echo 'project_name: \"My Project\"' > project-config.yml"
  echo "    echo 'author_name: \"Your Name\"' >> project-config.yml"
  echo "    echo 'author_email: \"your@email.com\"' >> project-config.yml"
  echo "  • Use: $0 --config project-config.yml"
else
  echo ""
  log_info "This was a dry run. No files were created."
  log_info "Run without --dry-run to create the actual files."
fi

echo ""
log_success "Setup complete! Happy coding! 🚀"
