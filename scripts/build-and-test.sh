#!/bin/bash
# Build and test a CPAN module from its repository checkout.
# Usage: build-and-test.sh [target-dir]
set -ex

dir="${1:-.}"
cd "$dir"

if [ -f Makefile.PL ]; then
  BUILD_SYSTEM=eumm
elif [ -f Build.PL ]; then
  BUILD_SYSTEM=mb
else
  echo "::error::No Makefile.PL or Build.PL found"
  exit 1
fi

MAKE_CMD=$(perl -MConfig -e 'print $Config{make}' 2>/dev/null || echo "make")

# Install configure-time dependencies from META.json
if [ -f META.json ]; then
  CONFIGURE_DEPS=$(perl -MJSON::PP -0777 -e '
    open my $fh, "<", "META.json" or exit;
    my $m = JSON::PP->new->decode(do { local $/; <$fh> });
    my %d;
    for my $type (values %{$m->{prereqs}{configure} || {}}) {
      $d{$_} = 1 for keys %$type;
    }
    delete $d{perl};
    print join " ", sort keys %d if %d;
  ' 2>/dev/null || true)
  if [ -n "$CONFIGURE_DEPS" ]; then
    echo "Installing configure dependencies: $CONFIGURE_DEPS"
    # shellcheck disable=SC2086 -- intentional word splitting: space-separated module list
    cpan $CONFIGURE_DEPS
  fi
fi

# Configure (generates MYMETA with accurate dependency info)
if [ "$BUILD_SYSTEM" = "eumm" ]; then
  perl Makefile.PL
else
  perl Build.PL
fi

# Install runtime, build, and test dependencies from MYMETA (falling back to META)
DEPS=$(perl -MJSON::PP -0777 -e '
  for my $f ("MYMETA.json", "META.json") {
    next unless -f $f;
    open my $fh, "<", $f or next;
    my $m = JSON::PP->new->decode(do { local $/; <$fh> });
    my %d;
    for my $phase (qw(runtime build test)) {
      for my $type (values %{$m->{prereqs}{$phase} || {}}) {
        $d{$_} = 1 for keys %$type;
      }
    }
    delete $d{perl};
    print join " ", sort keys %d if %d;
    exit;
  }
' 2>/dev/null || true)

if [ -n "$DEPS" ]; then
  echo "Installing dependencies: $DEPS"
  # shellcheck disable=SC2086 -- intentional word splitting: space-separated module list
  cpan $DEPS
fi

# Reconfigure with all deps, build, and test
if [ "$BUILD_SYSTEM" = "eumm" ]; then
  perl Makefile.PL
  $MAKE_CMD
  $MAKE_CMD test
else
  perl Build.PL
  ./Build
  ./Build test
fi
