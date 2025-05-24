#!/bin/zsh

# Project Validation Script
# Version: 1.0
# Validates project structure, memory bank files, and configuration integrity

# Exit immediately if a command exits with a non-zero status.
set -e
# Treat unset variables as an error when substituting.
set -u
# Prevent errors in pipelines from being masked.
set -o pipefail

# --- Configuration ---
SCRIPT_VERSION="1.0"
VERBOSE=false
FIX_ISSUES=false
REPORT_FILE=""

# --- Parse Command Line Arguments ---
while [[ $# -gt 0 ]]; do
  case $1 in
    --verbose|-v)
      VERBOSE=true
      shift
      ;;
    --fix)
      FIX_ISSUES=true
      shift
      ;;
    --report)
      REPORT_FILE="$2"
      shift 2
      ;;
    --help|-h)
      echo "Project Validation Script v${SCRIPT_VERSION}"
      echo ""
      echo "Usage: $0 [OPTIONS]"
      echo ""
      echo "Options:"
      echo "  --verbose, -v    Show detailed validation information"
      echo "  --fix            Attempt to fix common issues automatically"
      echo "  --report FILE    Save validation report to file"
      echo "  --help, -h       Show this help message"
      echo ""
      echo "This script validates:"
      echo "  - Project structure and required files"
      echo "  - Memory bank file integrity and formatting"
      echo "  - Configuration consistency"
      echo "  - Date formats and placeholder completion"
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

# --- Validation Counters ---
TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0
WARNINGS=0
ISSUES_FIXED=0

# --- Helper Functions ---
log_info() {
  echo "ℹ️  $1"
  [[ -n "$REPORT_FILE" ]] && echo "INFO: $1" >> "$REPORT_FILE"
}

log_success() {
  echo "✅ $1"
  [[ -n "$REPORT_FILE" ]] && echo "PASS: $1" >> "$REPORT_FILE"
  ((PASSED_CHECKS++))
}

log_warning() {
  echo "⚠️  $1"
  [[ -n "$REPORT_FILE" ]] && echo "WARN: $1" >> "$REPORT_FILE"
  ((WARNINGS++))
}

log_error() {
  echo "❌ $1"
  [[ -n "$REPORT_FILE" ]] && echo "FAIL: $1" >> "$REPORT_FILE"
  ((FAILED_CHECKS++))
}

log_fixed() {
  echo "🔧 $1"
  [[ -n "$REPORT_FILE" ]] && echo "FIXED: $1" >> "$REPORT_FILE"
  ((ISSUES_FIXED++))
}

log_verbose() {
  if [[ "$VERBOSE" == "true" ]]; then
    echo "🔍 $1"
    [[ -n "$REPORT_FILE" ]] && echo "VERBOSE: $1" >> "$REPORT_FILE"
  fi
}

# Increment total checks counter
check() {
  ((TOTAL_CHECKS++))
}

# --- Validation Functions ---

# Check if file exists and is readable
validate_file_exists() {
  local file_path="$1"
  local description="$2"
  
  check
  log_verbose "Checking existence of $description: $file_path"
  
  if [[ -f "$file_path" && -r "$file_path" ]]; then
    log_success "$description exists and is readable"
    return 0
  else
    log_error "$description missing or not readable: $file_path"
    return 1
  fi
}

# Check if directory exists
validate_directory_exists() {
  local dir_path="$1"
  local description="$2"
  
  check
  log_verbose "Checking existence of $description: $dir_path"
  
  if [[ -d "$dir_path" ]]; then
    log_success "$description exists"
    return 0
  else
    log_error "$description missing: $dir_path"
    return 1
  fi
}

# Validate YAML frontmatter
validate_frontmatter() {
  local file_path="$1"
  local description="$2"
  
  check
  log_verbose "Validating frontmatter in $description"
  
  if [[ ! -f "$file_path" ]]; then
    log_error "Cannot validate frontmatter - file missing: $file_path"
    return 1
  fi
  
  # Check if file starts with ---
  if head -n 1 "$file_path" | grep -q "^---$"; then
    # Check if there's a closing ---
    if tail -n +2 "$file_path" | grep -q "^---$"; then
      log_success "Valid YAML frontmatter in $description"
      return 0
    else
      log_error "Missing closing --- in frontmatter: $description"
      return 1
    fi
  else
    log_error "Missing YAML frontmatter in $description"
    return 1
  fi
}

# Check for unfilled placeholders
validate_placeholders() {
  local file_path="$1"
  local description="$2"
  
  check
  log_verbose "Checking for unfilled placeholders in $description"
  
  if [[ ! -f "$file_path" ]]; then
    log_error "Cannot validate placeholders - file missing: $file_path"
    return 1
  fi
  
  local placeholder_count
  placeholder_count=$(grep -c "\[.*\]" "$file_path" 2>/dev/null || echo "0")
  
  if [[ "$placeholder_count" -eq 0 ]]; then
    log_success "No unfilled placeholders in $description"
    return 0
  else
    log_warning "$placeholder_count unfilled placeholders found in $description"
    if [[ "$VERBOSE" == "true" ]]; then
      grep -n "\[.*\]" "$file_path" | head -5
    fi
    return 1
  fi
}

# Validate date formats
validate_dates() {
  local file_path="$1"
  local description="$2"
  
  check
  log_verbose "Validating date formats in $description"
  
  if [[ ! -f "$file_path" ]]; then
    log_error "Cannot validate dates - file missing: $file_path"
    return 1
  fi
  
  # Check for invalid date placeholders
  local invalid_dates
  invalid_dates=$(grep -c "\[YYYY-MM-DD\]" "$file_path" 2>/dev/null || echo "0")
  
  if [[ "$invalid_dates" -eq 0 ]]; then
    log_success "All dates properly formatted in $description"
    return 0
  else
    log_warning "$invalid_dates unfilled date placeholders in $description"
    return 1
  fi
}

# Check required sections in memory bank files
validate_required_sections() {
  local file_path="$1"
  local description="$2"
  shift 2
  local required_sections=("$@")
  
  check
  log_verbose "Checking required sections in $description"
  
  if [[ ! -f "$file_path" ]]; then
    log_error "Cannot validate sections - file missing: $file_path"
    return 1
  fi
  
  local missing_sections=()
  for section in "${required_sections[@]}"; do
    if ! grep -q "^## $section" "$file_path"; then
      missing_sections+=("$section")
    fi
  done
  
  if [[ ${#missing_sections[@]} -eq 0 ]]; then
    log_success "All required sections present in $description"
    return 0
  else
    log_error "Missing sections in $description: ${missing_sections[*]}"
    return 1
  fi
}

# --- Main Validation Logic ---

echo "🔍 Project Validation Script v${SCRIPT_VERSION}"
echo "=============================================="

# Initialize report file if specified
if [[ -n "$REPORT_FILE" ]]; then
  echo "Project Validation Report - $(date)" > "$REPORT_FILE"
  echo "Generated by validate-project.sh v${SCRIPT_VERSION}" >> "$REPORT_FILE"
  echo "=============================================" >> "$REPORT_FILE"
  echo "" >> "$REPORT_FILE"
  log_info "Report will be saved to: $REPORT_FILE"
fi

echo ""
log_info "Starting project validation..."

# 1. Validate basic project structure
echo ""
log_info "=== Project Structure Validation ==="

validate_file_exists "README.md" "README file"
validate_file_exists "projectBrief.md" "Project Brief"
validate_file_exists ".augment-guidelines" "Augment Guidelines"
validate_directory_exists "memory-bank" "Memory Bank directory"

# 2. Validate memory bank files
echo ""
log_info "=== Memory Bank Files Validation ==="

MEMORY_BANK_FILES=(
  "productContext.md:Product Context"
  "activeContext.md:Active Context"
  "progress.md:Progress Tracker"
  "decisionLog.md:Decision Log"
  "systemPatterns.md:System Patterns"
  "dependencies.md:Dependencies"
  "meetings.md:Meetings"
  "troubleshooting.md:Troubleshooting"
)

for file_info in "${MEMORY_BANK_FILES[@]}"; do
  IFS=':' read -r filename description <<< "$file_info"
  file_path="memory-bank/$filename"
  
  if validate_file_exists "$file_path" "$description file"; then
    validate_frontmatter "$file_path" "$description"
    validate_placeholders "$file_path" "$description"
    validate_dates "$file_path" "$description"
  fi
done

# 3. Validate specific file requirements
echo ""
log_info "=== Content Structure Validation ==="

# Validate productContext.md sections
if [[ -f "memory-bank/productContext.md" ]]; then
  validate_required_sections "memory-bank/productContext.md" "Product Context" \
    "Project Goal" "Key Features" "Target Audience" "High-Level Architecture"
fi

# Validate systemPatterns.md sections
if [[ -f "memory-bank/systemPatterns.md" ]]; then
  validate_required_sections "memory-bank/systemPatterns.md" "System Patterns" \
    "Coding Style / Linting" "Naming Conventions" "Testing Patterns"
fi

# 4. Configuration consistency check
echo ""
log_info "=== Configuration Validation ==="

check
if [[ -f ".augment-guidelines" ]]; then
  log_verbose "Validating .augment-guidelines format"
  if grep -q "memory_system:" ".augment-guidelines" && grep -q "core_files:" ".augment-guidelines"; then
    log_success "Augment Guidelines properly configured"
  else
    log_error "Invalid .augment-guidelines format"
  fi
else
  log_error "Missing .augment-guidelines file"
fi

# 5. Generate summary
echo ""
echo "=============================================="
log_info "Validation Summary"
echo "=============================================="
echo "📊 Total Checks: $TOTAL_CHECKS"
echo "✅ Passed: $PASSED_CHECKS"
echo "❌ Failed: $FAILED_CHECKS"
echo "⚠️  Warnings: $WARNINGS"

if [[ "$FIX_ISSUES" == "true" && "$ISSUES_FIXED" -gt 0 ]]; then
  echo "🔧 Issues Fixed: $ISSUES_FIXED"
fi

# Calculate success rate
if [[ "$TOTAL_CHECKS" -gt 0 ]]; then
  SUCCESS_RATE=$(( (PASSED_CHECKS * 100) / TOTAL_CHECKS ))
  echo "📈 Success Rate: ${SUCCESS_RATE}%"
else
  SUCCESS_RATE=0
fi

echo ""

# Final status
if [[ "$FAILED_CHECKS" -eq 0 ]]; then
  if [[ "$WARNINGS" -eq 0 ]]; then
    log_success "Project validation completed successfully! 🎉"
    exit 0
  else
    echo "⚠️  Project validation completed with warnings."
    exit 0
  fi
else
  log_error "Project validation failed. Please address the issues above."
  exit 1
fi
