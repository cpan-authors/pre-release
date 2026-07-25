# CLAUDE.md — pre-release

## What this project is

A **GitHub Actions workflow** that tests CPAN Perl modules across 21 platform combinations
before release to CPAN. Triggered via `workflow_dispatch` with a GitHub repository as input.

Repository: `cpan-authors/pre-release`

## Project structure

```
.github/workflows/test-repo.yml   # The workflow — this IS the project
README.md                          # Project documentation
```

## The workflow

`test-repo.yml` defines three jobs:

| Job | Platforms | Runner |
|-----|-----------|--------|
| `test-module` | Ubuntu 20.04–24.04, Fedora 38/43, Rocky 9, Debian buster–trixie, Alpine 3.23, macOS 14/15 | Native + containers |
| `test-module-windows` | Windows 2022, 2025 | Native (Strawberry Perl) |
| `test-module-bsd` | FreeBSD 13.5/14.3/15.0, OpenBSD 7.8, NetBSD 10.1 | `cross-platform-actions` VMs |

### Inputs

- `repository` (required) — GitHub `owner/repo` to test
- `include-distroprefs` — Use CPAN distribution preferences (default: true)
- `include-sysdeps` — Use cpan-sysdeps for system deps (default: true)
- `enable-cpan-reporter` — Send results to CPAN Testers (default: false)
- `debug` — Verbose output (default: false)

### What each job does

1. Install system Perl and build tools (platform-specific)
2. Set up CPAN via `eserte/ci-helper-cpan-pm`
3. Clone the target repo, detect module name from META.json/META.yml/Makefile.PL
4. Optionally run `cpan-sysdeps` for system dependencies
5. Install configure/runtime/build/test deps from META, then build and test

## How to validate changes

**YAML syntax**: `python3 -c "import yaml; yaml.safe_load(open('.github/workflows/test-repo.yml'))"`

**Real test**: Trigger the workflow via GitHub UI or CLI against a known-good module:
```bash
gh workflow run test-repo.yml -f repository=cpan-authors/Tree-MultiNode
```
`Tree-MultiNode` is a good baseline — pure Perl, no XS, minimal deps.

For XS/dependency-heavy testing: `cpan-authors/XML-LibXML`

## Key conventions

- **Shell injection**: User inputs (`repository`, detected `module_name`) MUST go through
  `env:` blocks, never direct `${{ }}` interpolation in `run:` steps. See issue #16.
- **Interactive prompts**: Always set `PERL_MM_USE_DEFAULT=1`, `AUTOMATED_TESTING=1`,
  `NONINTERACTIVE_TESTING=1` to prevent Makefile.PL/Build.PL hangs. See issue #18.
- **Platform conditionals**: Use `startsWith(matrix.container, ...)` for container-specific
  steps. Non-container runners (macOS, Windows) have `container: ~` (null).
- **BSD VMs**: Use `cross-platform-actions/action` — these run inside a VM, so env vars
  need explicit passthrough via `environment_variables`.
- **Build systems**: Support both ExtUtils::MakeMaker (`Makefile.PL`) and Module::Build
  (`Build.PL`). On Windows, use `$MAKE_CMD` from `Config{make}` (usually `gmake`/`dmake`).
- **Archived distros**: Debian buster/stretch need archive.debian.org sources.

## Open issues and PRs

Check with:
```bash
gh issue list --state open
gh pr list --state open
```

## CI

No CI runs on PRs (the workflow is `workflow_dispatch` only). Validate YAML locally
and trigger a test run to verify changes.
