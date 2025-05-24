#!/bin/zsh

# Project Update/Migration Script
# Version: 1.0
# Migrates existing projects to new template versions while preserving content

# Exit immediately if a command exits with a non-zero status.
set -e
# Treat unset variables as an error when substituting.
set -u
# Prevent errors in pipefail from being masked.
set -o pipefail

# --- Configuration ---
SCRIPT_VERSION="1.0"
DRY_RUN=false
BACKUP_DIR="migration-backup-$(date '+%Y%m%d-%H%M%S')"
FORCE_UPDATE=false
TARGET_VERSION="2.0"
CURRENT_VERSION=""

# --- Parse Command Line Arguments ---
while [[ $# -gt 0 ]]; do
  case $1 in
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --force)
      FORCE_UPDATE=true
      shift
      ;;
    --target-version)
      TARGET_VERSION="$2"
      shift 2
      ;;
    --help|-h)
      echo "Project Update/Migration Script v${SCRIPT_VERSION}"
      echo ""
      echo "Usage: $0 [OPTIONS]"
      echo ""
      echo "Options:"
      echo "  --dry-run              Show what would be updated without making changes"
      echo "  --force                Force update even if versions match"
      echo "  --target-version VER   Specify target version (default: 2.0)"
      echo "  --help, -h             Show this help message"
      echo ""
      echo "This script:"
      echo "  - Detects current project initialization version"
      echo "  - Backs up existing files before migration"
      echo "  - Adds missing memory bank files"
      echo "  - Updates templates while preserving content"
      echo "  - Migrates configuration formats"
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

log_migration() {
  echo "🔄 $1"
}

# Detect current project version
detect_version() {
  log_info "Detecting current project version..."
  
  # Check for version indicators
  if [[ -f ".augment-guidelines" ]]; then
    if grep -q "dependencies.md" ".augment-guidelines" && grep -q "meetings.md" ".augment-guidelines"; then
      CURRENT_VERSION="2.0"
    else
      CURRENT_VERSION="1.0"
    fi
  elif [[ -d "memory-bank" ]]; then
    if [[ -f "memory-bank/dependencies.md" ]]; then
      CURRENT_VERSION="2.0"
    else
      CURRENT_VERSION="1.0"
    fi
  else
    CURRENT_VERSION="0.0"
  fi
  
  log_info "Detected version: $CURRENT_VERSION"
}

# Create backup of existing files
create_backup() {
  if [[ "$DRY_RUN" == "true" ]]; then
    log_info "Would create backup directory: $BACKUP_DIR"
    return 0
  fi
  
  log_info "Creating backup directory: $BACKUP_DIR"
  mkdir -p "$BACKUP_DIR"
  
  # Backup existing files
  local files_to_backup=(
    "README.md"
    "projectBrief.md"
    ".augment-guidelines"
    "memory-bank"
  )
  
  for file in "${files_to_backup[@]}"; do
    if [[ -e "$file" ]]; then
      cp -r "$file" "$BACKUP_DIR/"
      log_info "Backed up: $file"
    fi
  done
}

# Add missing memory bank files (v1.0 -> v2.0)
add_missing_memory_bank_files() {
  log_migration "Adding missing memory bank files..."
  
  local new_files=(
    "dependencies.md"
    "meetings.md"
    "troubleshooting.md"
  )
  
  for file in "${new_files[@]}"; do
    local file_path="memory-bank/$file"
    
    if [[ ! -f "$file_path" ]]; then
      if [[ "$DRY_RUN" == "true" ]]; then
        log_info "Would create: $file_path"
      else
        log_migration "Creating: $file_path"
        create_memory_bank_file "$file"
      fi
    else
      log_info "Already exists: $file_path"
    fi
  done
}

# Create individual memory bank files
create_memory_bank_file() {
  local filename="$1"
  local file_path="memory-bank/$filename"
  
  case "$filename" in
    "dependencies.md")
      cat << 'EOF' > "$file_path"
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

### Backend
- **Runtime/Language:** [e.g., Node.js 18.x, Python 3.11, Go 1.19]
- **Framework:** [e.g., Express.js, FastAPI, Gin]

## Dependency Decisions Log

### [YYYY-MM-DD] - [Decision Title]
**Decision:** [What was decided]
**Rationale:** [Why this choice was made]
**Alternatives Considered:** [Other options that were evaluated]

---

**Note:** Keep this file updated whenever dependencies are added, removed, or significantly updated.
EOF
      ;;
    "meetings.md")
      cat << 'EOF' > "$file_path"
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

#### Key Discussions
- **Topic:** [Discussion topic]
  - **Summary:** [Brief summary of discussion]
  - **Outcome:** [What was decided or concluded]

#### Decisions Made
- **Decision:** [Clear statement of decision]
- **Rationale:** [Why this decision was made]
- **Owner:** [Who is responsible for implementation]

#### Action Items
- [ ] **[Action Item]** - Assigned to: [Name] - Due: [YYYY-MM-DD]

---

## Meeting Action Items Tracker

### Open Action Items
- [ ] **[Action Item]** - Assigned to: [Name] - Due: [Date] - From: [Meeting]

### Completed Action Items
- ✅ **[Completed Action]** - Completed: [Date] - From: [Meeting]

---

**Note:** Update this file after each significant meeting or discussion.
EOF
      ;;
    "troubleshooting.md")
      cat << 'EOF' > "$file_path"
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

**Common Solutions:**
```bash
# Clean build
npm run clean
npm run build
```

---

## Debugging Strategies

### Log Analysis
```bash
# View recent logs
[log-view-command]
```

## Emergency Procedures

### Production Incident Response
1. Assess impact and severity
2. Notify stakeholders
3. Begin investigation

---

**Note:** Keep this guide updated with new issues and solutions.
EOF
      ;;
  esac
  
  log_success "Created: $file_path"
}

# Update .augment-guidelines to include new files
update_augment_guidelines() {
  if [[ ! -f ".augment-guidelines" ]]; then
    log_warning "No .augment-guidelines file found to update"
    return 1
  fi
  
  log_migration "Updating .augment-guidelines..."
  
  if [[ "$DRY_RUN" == "true" ]]; then
    log_info "Would update .augment-guidelines with new memory bank files"
    return 0
  fi
  
  # Check if new files are already referenced
  if grep -q "dependencies.md" ".augment-guidelines"; then
    log_info ".augment-guidelines already up to date"
    return 0
  fi
  
  # Add new files to core_files section
  if grep -q "systemPatterns: systemPatterns.md" ".augment-guidelines"; then
    sed -i '' '/systemPatterns: systemPatterns.md/a\
    dependencies: dependencies.md      # Technology stack, versions, and dependency decisions.\
    meetings: meetings.md             # Meeting notes, discussions, and action items.\
    troubleshooting: troubleshooting.md # Common issues, solutions, and debugging guides.
' ".augment-guidelines"
    
    # Add to update_strategies section
    sed -i '' '/systemPatterns.md: APPEND/a\
    dependencies.md: APPEND # Add new dependencies and update existing entries as needed.\
    meetings.md: APPEND # Always append new meeting notes chronologically.\
    troubleshooting.md: APPEND # Add new issues and solutions as they are discovered.
' ".augment-guidelines"
    
    log_success "Updated .augment-guidelines with new memory bank files"
  else
    log_warning "Could not automatically update .augment-guidelines - manual update required"
  fi
}

# Enhance existing systemPatterns.md
enhance_system_patterns() {
  local file_path="memory-bank/systemPatterns.md"
  
  if [[ ! -f "$file_path" ]]; then
    log_warning "systemPatterns.md not found - skipping enhancement"
    return 1
  fi
  
  log_migration "Enhancing systemPatterns.md..."
  
  if [[ "$DRY_RUN" == "true" ]]; then
    log_info "Would enhance systemPatterns.md with new sections"
    return 0
  fi
  
  # Check if already enhanced
  if grep -q "## Testing Patterns" "$file_path"; then
    log_info "systemPatterns.md already enhanced"
    return 0
  fi
  
  # Add new sections
  cat << 'EOF' >> "$file_path"

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
EOF
  
  log_success "Enhanced systemPatterns.md with new sections"
}

# --- Main Migration Logic ---

echo "🔄 Project Update/Migration Script v${SCRIPT_VERSION}"
echo "=================================================="

if [[ "$DRY_RUN" == "true" ]]; then
  log_info "DRY RUN MODE - No files will be modified"
  echo ""
fi

# Detect current version
detect_version

# Check if update is needed
if [[ "$CURRENT_VERSION" == "$TARGET_VERSION" && "$FORCE_UPDATE" == "false" ]]; then
  log_success "Project is already at target version $TARGET_VERSION"
  exit 0
fi

log_info "Migrating from version $CURRENT_VERSION to $TARGET_VERSION"
echo ""

# Create backup
create_backup

# Perform migration based on versions
case "$CURRENT_VERSION" in
  "0.0")
    log_error "No existing project structure found. Use init-project.sh instead."
    exit 1
    ;;
  "1.0")
    log_migration "Migrating from v1.0 to v2.0..."
    add_missing_memory_bank_files
    update_augment_guidelines
    enhance_system_patterns
    ;;
  "2.0")
    if [[ "$FORCE_UPDATE" == "true" ]]; then
      log_migration "Force updating v2.0 project..."
      add_missing_memory_bank_files
      update_augment_guidelines
      enhance_system_patterns
    else
      log_info "Project already at v2.0 - use --force to update anyway"
    fi
    ;;
esac

# Summary
echo ""
echo "=================================================="
log_success "Migration completed successfully!"
echo "=================================================="

if [[ "$DRY_RUN" == "false" ]]; then
  echo ""
  log_info "Changes made:"
  echo "  📁 Backup created in: $BACKUP_DIR"
  echo "  📄 Added missing memory bank files"
  echo "  🔧 Updated .augment-guidelines"
  echo "  ✨ Enhanced systemPatterns.md"
  
  echo ""
  log_info "Next steps:"
  echo "  1. Review the new memory bank files and populate with project data"
  echo "  2. Run validate-project.sh to verify the migration"
  echo "  3. Update any custom configurations as needed"
else
  echo ""
  log_info "This was a dry run. Use without --dry-run to perform the actual migration."
fi

echo ""
log_success "Migration complete! 🚀"
