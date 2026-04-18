#!/bin/bash
# =============================================================================
# SwiftMac bootstrap script
# Validates the repository checkout and generates the Xcode project on macOS.
# Usage:
#   chmod +x setup.sh && ./setup.sh
# =============================================================================

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_FILE="$ROOT_DIR/project.yml"
XCODEPROJ_DIR="$ROOT_DIR/SwiftMac.xcodeproj"

required_paths=(
  "$ROOT_DIR/SwiftMac"
  "$ROOT_DIR/SwiftMacHelper"
  "$ROOT_DIR/SwiftMacTests"
  "$ROOT_DIR/SwiftMacUITests"
  "$ROOT_DIR/project.yml"
  "$ROOT_DIR/README.md"
)

log() {
  printf '%s\n' "$1"
}

fail() {
  printf 'error: %s\n' "$1" >&2
  exit 1
}

validate_checkout() {
  for path in "${required_paths[@]}"; do
    [[ -e "$path" ]] || fail "Missing required path: $path"
  done
}

install_xcodegen_if_possible() {
  if command -v xcodegen >/dev/null 2>&1; then
    return 0
  fi

  if ! command -v brew >/dev/null 2>&1; then
    return 1
  fi

  log "xcodegen not found, installing with Homebrew..."
  brew install xcodegen
}

generate_project() {
  [[ "$(uname -s)" == "Darwin" ]] || return 1

  install_xcodegen_if_possible || return 1

  cd "$ROOT_DIR"
  xcodegen generate
}

print_summary() {
  local swift_count
  swift_count=$(find "$ROOT_DIR/SwiftMac" "$ROOT_DIR/SwiftMacHelper" "$ROOT_DIR/SwiftMacTests" "$ROOT_DIR/SwiftMacUITests" -name '*.swift' | wc -l | tr -d ' ')

  log ""
  log "SwiftMac bootstrap complete"
  log "Repository root: $ROOT_DIR"
  log "Swift files:     $swift_count"

  if [[ -d "$XCODEPROJ_DIR" ]]; then
    log "Xcode project:   SwiftMac.xcodeproj"
  else
    log "Xcode project:   not generated in this environment"
  fi
}

main() {
  validate_checkout

  if generate_project; then
    log "Generated Xcode project from $PROJECT_FILE"
  else
    log "Skipping Xcode project generation."
    log "Run this script on macOS with xcodegen installed, or install Homebrew and rerun."
  fi

  print_summary
}

main "$@"
