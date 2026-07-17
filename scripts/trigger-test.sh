#!/bin/bash
# Trigger a CPAN module or repository test workflow and optionally watch progress.
#
# Usage:
#   trigger-test.sh repo  owner/repo          [--watch] [--ref branch]
#   trigger-test.sh cpan  Module::Name        [--watch]
#
# Requires: gh CLI authenticated with workflow dispatch permissions.

set -euo pipefail

REPO="cpan-authors/pre-release"

usage() {
  cat <<'EOF'
Usage:
  trigger-test.sh repo <owner/repo> [options]
  trigger-test.sh cpan <Module::Name> [options]

Options:
  --watch             Wait for the run to complete and stream logs
  --ref <ref>         Branch/tag/SHA to test (repo mode only)
  --no-distroprefs    Disable CPAN distribution preferences
  --no-sysdeps        Disable cpan-sysdeps
  --reporter          Enable CPAN Testers reporting
  --debug             Enable debug output

Examples:
  trigger-test.sh repo cpan-authors/XML-LibXML --watch
  trigger-test.sh cpan XML::LibXML --watch
  trigger-test.sh repo cpan-authors/Template2 --ref v3.200
EOF
  exit 1
}

[ $# -lt 2 ] && usage

MODE="$1"; shift
TARGET="$1"; shift

WATCH=false
REF=""
DISTROPREFS=true
SYSDEPS=true
REPORTER=false
DEBUG=false

while [ $# -gt 0 ]; do
  case "$1" in
    --watch)          WATCH=true ;;
    --ref)            REF="$2"; shift ;;
    --no-distroprefs) DISTROPREFS=false ;;
    --no-sysdeps)     SYSDEPS=false ;;
    --reporter)       REPORTER=true ;;
    --debug)          DEBUG=true ;;
    *) echo "Unknown option: $1"; usage ;;
  esac
  shift
done

case "$MODE" in
  repo)
    WORKFLOW="test-repo.yml"
    echo "Triggering test for repository: $TARGET"
    FIELDS=(-f "repository=$TARGET"
            -f "include-distroprefs=$DISTROPREFS"
            -f "include-sysdeps=$SYSDEPS"
            -f "enable-cpan-reporter=$REPORTER"
            -f "debug=$DEBUG")
    [ -n "$REF" ] && FIELDS+=(-f "ref=$REF")
    ;;
  cpan)
    WORKFLOW="test-cpan-module.yml"
    echo "Triggering test for CPAN module: $TARGET"
    FIELDS=(-f "module=$TARGET"
            -f "include-distroprefs=$DISTROPREFS"
            -f "include-sysdeps=$SYSDEPS"
            -f "enable-cpan-reporter=$REPORTER"
            -f "debug=$DEBUG")
    ;;
  *)
    echo "Unknown mode: $MODE (use 'repo' or 'cpan')"
    usage
    ;;
esac

gh workflow run "$WORKFLOW" -R "$REPO" "${FIELDS[@]}"
echo "Workflow dispatched."

if [ "$WATCH" = true ]; then
  echo "Waiting for run to appear..."
  sleep 3
  RUN_ID=$(gh run list -R "$REPO" --workflow="$WORKFLOW" --limit 1 --json databaseId -q '.[0].databaseId')
  if [ -z "$RUN_ID" ]; then
    echo "Could not find run ID. Check https://github.com/$REPO/actions"
    exit 1
  fi
  echo "Run ID: $RUN_ID"
  echo "URL: https://github.com/$REPO/actions/runs/$RUN_ID"
  gh run watch -R "$REPO" "$RUN_ID"
fi
