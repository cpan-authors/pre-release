# pre-release

Test your CPAN module across 21+ OS targets before uploading to CPAN.

GitHub Actions workflows that test any CPAN module — from its GitHub
repository, by CPAN module name, or across 14 Perl versions — on Linux,
macOS, Windows, and BSDs. Includes reverse dependency testing to verify
your changes won't break downstream users.

## Workflows

| Workflow | Purpose |
|----------|---------|
| **Test from Repository** | Clone a GitHub repo and test across 21 OS targets |
| **Test CPAN Module** | Install and test by CPAN module name (`cpanm -v`) |
| **Test Perl Versions** | Test across Perl 5.14–5.40 on Linux, macOS, Windows |
| **Test Reverse Deps** | Test downstream dependents against your changes |

## Usage

### Test from a GitHub repository

Go to **Actions > Test CPAN Module from Repository > Run workflow**, or:

```bash
gh workflow run test-repo.yml \
  -f repository=cpan-authors/Template2 \
  -f include-distroprefs=true
```

Test a specific branch or tag:

```bash
gh workflow run test-repo.yml \
  -f repository=cpan-authors/Template2 \
  -f ref=my-feature-branch
```

### Test by CPAN module name

```bash
gh workflow run test-cpan-module.yml -f module=XML::LibXML
```

### Test across Perl versions

```bash
gh workflow run test-perl-versions.yml \
  -f repository=cpan-authors/Template2
```

### Test reverse dependencies

```bash
# From CPAN
gh workflow run test-reverse-deps.yml -f module=JSON::PP

# From a source repo (pre-release testing)
gh workflow run test-reverse-deps.yml \
  -f repository=cpan-authors/JSON-PP \
  -f ref=my-branch \
  -f max-deps=50
```

### CLI helpers

```bash
./scripts/trigger-test.sh repo cpan-authors/XML-LibXML --watch
./scripts/trigger-test.sh cpan XML::LibXML --watch
./scripts/trigger-reverse-deps.sh --module JSON::PP --max 50
```

### Reusable workflow

Other repositories can call these workflows:

```yaml
jobs:
  test:
    uses: cpan-authors/pre-release/.github/workflows/test-repo.yml@main
    with:
      repository: your-org/your-module
```

## Options (test-repo / test-cpan-module)

| Option | Default | Description |
|--------|---------|-------------|
| **repository** / **module** | *(required)* | GitHub repo (`owner/repo`) or CPAN module name |
| **ref** | default branch | Git ref to test (branch, tag, or SHA) |
| **include-distroprefs** | `true` | Apply [srezic-cpan-distroprefs](https://github.com/eserte/srezic-cpan-distroprefs) |
| **include-sysdeps** | `true` | Install system dependencies via cpan-sysdeps |
| **enable-cpan-reporter** | `false` | Upload results to CPAN Testers |
| **debug** | `false` | Verbose logging |

## Platform Matrix (test-repo / test-cpan-module)

| Category | Targets |
|----------|---------|
| **macOS** | macOS 14 (Sonoma), macOS 15 (Sequoia) |
| **Ubuntu** | 22.04, 24.04 (native runners) |
| **Linux containers** | Ubuntu 20.04/24.04, Fedora 38/43, Rocky Linux 9, Debian Buster–Trixie, Alpine 3.23 |
| **Windows** | Server 2022, Server 2025 (Strawberry Perl) |
| **BSD** | FreeBSD 13.5/14.3/15.0, OpenBSD 7.8, NetBSD 10.1 |

## How It Works

1. Sets up CPAN via [ci-helper-cpan-pm](https://github.com/eserte/ci-helper-cpan-pm) with distroprefs and sysdeps
2. Clones the target repository (at the specified ref if given) or installs from CPAN
3. Detects the module name from META.json, META.yml, or Makefile.PL
4. Installs system dependencies via cpan-sysdeps (where supported)
5. Two-pass dependency install: configure deps > configure > runtime/build/test deps
6. Builds and runs the test suite

Supports both `ExtUtils::MakeMaker` and `Module::Build`.
