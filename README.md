# pre-release

Test your CPAN module across 21 OS targets before uploading to CPAN.

This repository provides GitHub Actions workflows that test any CPAN module —
from its GitHub repository or by CPAN name — across Linux distributions,
macOS, Windows, and BSDs. A CPAN Testers-like matrix without waiting for the
upload cycle.

## Usage

### Test from a GitHub repository

1. Go to **Actions → Test CPAN Module from Repository → Run workflow**
2. Enter the GitHub repository (e.g. `cpan-authors/Template2`)
3. Optionally specify a git ref (branch, tag, or SHA) to test

Or via CLI:

```bash
gh workflow run "Test CPAN Module from Repository" \
  -f repository=cpan-authors/Template2 \
  -f include-distroprefs=true \
  -f include-sysdeps=true
```

### Test a specific branch or tag

```bash
gh workflow run "Test CPAN Module from Repository" \
  -f repository=cpan-authors/Template2 \
  -f ref=my-feature-branch
```

### Reusable workflow

Other repositories can call this workflow:

```yaml
jobs:
  test:
    uses: cpan-authors/pre-release/.github/workflows/test-repo.yml@main
    with:
      repository: your-org/your-module
```

## Options

| Option | Default | Description |
|--------|---------|-------------|
| **repository** | *(required)* | GitHub repository (`owner/repo`) |
| **ref** | default branch | Git ref to test (branch, tag, or SHA) |
| **include-distroprefs** | `true` | Apply [srezic-cpan-distroprefs](https://github.com/eserte/srezic-cpan-distroprefs) |
| **include-sysdeps** | `true` | Install system dependencies via cpan-sysdeps |
| **enable-cpan-reporter** | `false` | Upload results to CPAN Testers |
| **debug** | `false` | Verbose logging |

## Platform Matrix

| Category | Targets |
|----------|---------|
| **macOS** | macOS 14 (Sonoma), macOS 15 (Sequoia) |
| **Ubuntu** | 22.04, 24.04 (native runners) |
| **Linux containers** | Ubuntu 20.04/24.04, Fedora 38/43, Rocky Linux 9, Debian Buster–Trixie, Alpine 3.23 |
| **Windows** | Server 2022, Server 2025 (Strawberry Perl) |
| **BSD** | FreeBSD 13.5/14.3/15.0, OpenBSD 7.8, NetBSD 10.1 |

## How It Works

1. Sets up CPAN via [ci-helper-cpan-pm](https://github.com/eserte/ci-helper-cpan-pm) with distroprefs and sysdeps
2. Clones the target repository (at the specified ref if given)
3. Detects the module name from META.json, META.yml, or Makefile.PL
4. Installs system dependencies via cpan-sysdeps (where supported)
5. Two-pass dependency install: configure deps → configure → runtime/build/test deps
6. Builds and runs the test suite

Supports both `ExtUtils::MakeMaker` and `Module::Build`.
