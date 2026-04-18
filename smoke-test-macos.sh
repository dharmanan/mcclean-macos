#!/bin/bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DERIVED_DATA_PATH="$ROOT_DIR/build/smoke-derived-data"
LOG_DIR="$ROOT_DIR/build/smoke-logs"
BUILD_LOG="$LOG_DIR/build.log"
TEST_LOG="$LOG_DIR/test.log"
DESTINATION='platform=macOS'
SCHEME="SwiftMac"
PROJECT_FILE="SwiftMac.xcodeproj"

log() {
  printf '%s\n' "$1"
}

fail() {
  printf 'error: %s\n' "$1" >&2
  exit 1
}

run_and_log() {
  local log_file="$1"
  shift
  "$@" 2>&1 | tee "$log_file"
}

[[ "$(uname -s)" == "Darwin" ]] || fail "This smoke test must be run on macOS."
command -v xcodebuild >/dev/null 2>&1 || fail "xcodebuild is not installed. Install Xcode and command line tools first."

if ! command -v xcodegen >/dev/null 2>&1; then
  command -v brew >/dev/null 2>&1 || fail "xcodegen is missing and Homebrew is not installed. Install xcodegen manually."
  log "xcodegen not found, installing with Homebrew..."
  brew install xcodegen
fi

cd "$ROOT_DIR"
mkdir -p "$LOG_DIR"

log "Generating Xcode project..."
xcodegen generate

log "Cleaning previous build artifacts..."
xcodebuild \
  -project "$PROJECT_FILE" \
  -scheme "$SCHEME" \
  -configuration Debug \
  -destination "$DESTINATION" \
  -derivedDataPath "$DERIVED_DATA_PATH" \
  CODE_SIGNING_ALLOWED=NO \
  clean >/dev/null

log "Running Debug build-for-testing smoke test..."
run_and_log "$BUILD_LOG" xcodebuild \
  -project "$PROJECT_FILE" \
  -scheme "$SCHEME" \
  -configuration Debug \
  -destination "$DESTINATION" \
  -derivedDataPath "$DERIVED_DATA_PATH" \
  CODE_SIGNING_ALLOWED=NO \
  build-for-testing

log "Running test-without-building smoke test..."
run_and_log "$TEST_LOG" xcodebuild \
  -project "$PROJECT_FILE" \
  -scheme "$SCHEME" \
  -configuration Debug \
  -destination "$DESTINATION" \
  -derivedDataPath "$DERIVED_DATA_PATH" \
  CODE_SIGNING_ALLOWED=NO \
  test-without-building

log "Build and test smoke test passed."
log "Build log: $BUILD_LOG"
log "Test log:  $TEST_LOG"