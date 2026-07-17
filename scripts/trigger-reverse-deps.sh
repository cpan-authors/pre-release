#!/usr/bin/env bash
# Trigger the reverse-dependency test workflow via GitHub CLI.
#
# Usage:
#   ./scripts/trigger-reverse-deps.sh --module JSON::PP
#   ./scripts/trigger-reverse-deps.sh --repo cpan-authors/XML-LibXML
#   ./scripts/trigger-reverse-deps.sh --repo cpan-authors/XML-LibXML --ref fix-branch --max 10
#   ./scripts/trigger-reverse-deps.sh --module Template::Toolkit --perl 5.36

set -euo pipefail

MODULE=""
REPO=""
REF=""
MAX_DEPS=20
PERL_VERSION="latest"

usage() {
  echo "Usage: $0 [--module MODULE | --repo OWNER/REPO] [--ref REF] [--max N] [--perl VERSION]"
  echo ""
  echo "  --module   CPAN module name (e.g., JSON::PP)"
  echo "  --repo     GitHub repository to install from source (e.g., cpan-authors/XML-LibXML)"
  echo "  --ref      Git ref when using --repo (branch, tag, or SHA)"
  echo "  --max      Max reverse deps to test (default: 20, 0 = all up to 200)"
  echo "  --perl     Perl version (default: latest)"
  exit 1
}

while [ $# -gt 0 ]; do
  case "$1" in
    --module)  MODULE="$2"; shift 2 ;;
    --repo)    REPO="$2"; shift 2 ;;
    --ref)     REF="$2"; shift 2 ;;
    --max)     MAX_DEPS="$2"; shift 2 ;;
    --perl)    PERL_VERSION="$2"; shift 2 ;;
    -h|--help) usage ;;
    *)         echo "Unknown option: $1"; usage ;;
  esac
done

if [ -z "$MODULE" ] && [ -z "$REPO" ]; then
  echo "Error: provide --module or --repo"
  usage
fi

gh workflow run test-reverse-deps.yml \
  -f "module=${MODULE}" \
  -f "repository=${REPO}" \
  -f "ref=${REF}" \
  -f "max-deps=${MAX_DEPS}" \
  -f "perl-version=${PERL_VERSION}"

echo "Workflow dispatched. Watch progress:"
echo "  gh run list --workflow=test-reverse-deps.yml --limit=1"
