#!/bin/bash
# Detect CPAN module name from a repository checkout.
# Usage: detect-module.sh [target-dir]
# Stdout: module name (or empty). Writes module_name= to GITHUB_OUTPUT in CI.
set -e

dir="${1:-.}"
cd "$dir"

MODULE_NAME=""

if [ -f META.json ]; then
  MODULE_NAME=$(perl -MJSON::PP -0777 -e '
    open my $fh, "<", "META.json" or exit;
    my $m = JSON::PP->new->decode(do { local $/; <$fh> });
    (my $mod = $m->{name} // "") =~ s/-/::/g;
    print $mod;
  ' 2>/dev/null || true)
fi

if [ -z "$MODULE_NAME" ] && [ -f META.yml ]; then
  MODULE_NAME=$(perl -ne 'if (/^name:\s*(\S+)/) { (my $m = $1) =~ s/-/::/g; print $m; exit }' META.yml 2>/dev/null || true)
fi

if [ -z "$MODULE_NAME" ] && [ -f Makefile.PL ]; then
  MODULE_NAME=$(perl -ne "if (/NAME.*?=>.*?['\"]([^'\"]+)/) { print \$1; exit }" Makefile.PL 2>/dev/null || true)
fi

echo "Detected module: ${MODULE_NAME:-unknown}" >&2
[ -n "${GITHUB_OUTPUT:-}" ] && echo "module_name=$MODULE_NAME" >> "$GITHUB_OUTPUT"
echo "$MODULE_NAME"
