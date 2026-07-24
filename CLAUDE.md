# CLAUDE.md

## What this project is

A GitHub Actions workflow for testing CPAN Perl modules across Linux, macOS,
Windows, FreeBSD, OpenBSD, and NetBSD. The human dispatches
`.github/workflows/test-repo.yml` against any `owner/repo` containing a Perl
distribution (Makefile.PL or Build.PL).

## Repository layout

```
.github/
  workflows/test-repo.yml   — the workflow (only substantive file)
  dependabot.yml             — keeps action versions current
```

## How the workflow works

Three jobs cover the platform matrix:

- **test-module** — Linux distro containers + bare Ubuntu + macOS
- **test-module-windows** — Windows 2022/2025 via Strawberry Perl
- **test-module-bsd** — FreeBSD/OpenBSD/NetBSD via cross-platform-actions VMs

Each job: installs Perl + build tools, sets up CPAN with distroprefs/sysdeps,
clones the target repo, extracts and installs dependencies from META.json,
then runs `perl Makefile.PL && make && make test` (or Module::Build equivalent).

## Validating changes

No local test suite. Validate workflow YAML with:

```bash
# actionlint (install: https://github.com/rhysd/actionlint)
actionlint .github/workflows/test-repo.yml
```

For functional validation, dispatch the workflow against a known-good module:

```bash
gh workflow run test-repo.yml -f repository=cpan-authors/Tree-MultiNode
```

## Known issues (tracked in open PRs)

- Windows: MSYS2 perl shadows Strawberry Perl in bash steps (#14)
- FreeBSD: cross-platform-actions v0.32.0 doesn't support newer FreeBSD; pkg
  version mismatch causes update failures (#15)
- Shell injection via `${{ steps.detect.outputs.module_name }}` (#16, #17)
- Interactive CPAN modules hang without PERL_MM_USE_DEFAULT=1 (#18, #19)
- No job timeouts — stuck builds burn 6h of Actions quota (#20)

## Conventions

- Workflow inputs use `inputs.repository` in `owner/repo` format
- Dependencies are extracted from META.json prereqs, not cpanfile
- BSD jobs run inside QEMU VMs — env vars must be forwarded explicitly via
  `environment_variables` in the cross-platform-actions input
- Debian Buster uses actions/checkout@v3 (its git is too old for v6)
