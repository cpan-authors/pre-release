# CLAUDE.md

## What is pre-release

A GitHub Actions workflow that tests CPAN modules from their source repositories
across 21 OS targets (Linux, macOS, Windows, BSDs). It's a pre-upload validation
tool — run the matrix before releasing to CPAN.

Repository: cpan-authors/pre-release (this is the upstream, not a fork)

## Project structure

```
.github/workflows/test-repo.yml   # The main workflow — three jobs:
                                   #   test-module (Linux/macOS containers + native)
                                   #   test-module-windows (Strawberry Perl)
                                   #   test-module-bsd (FreeBSD, OpenBSD, NetBSD via cross-platform-actions)
```

## Conventions

- The workflow is `workflow_dispatch` only — no automatic triggers
- Module detection order: META.json → META.yml → Makefile.PL
- Two-pass dependency install: configure deps from META.json first, then runtime/build/test from MYMETA.json
- `actions/checkout@v3` for very old containers (debian:buster) due to Node.js compat; `@v6` everywhere else
- `cross-platform-actions/action@v0.32.0` for BSD testing
- Windows uses `perl -MConfig -e 'print $Config{make}'` to detect the correct make command
- ci-helper-cpan-pm (eserte) handles CPAN configuration, distroprefs, and sysdeps setup

## Key dependencies

- [ci-helper-cpan-pm](https://github.com/eserte/ci-helper-cpan-pm) — CPAN CI setup helper
- [srezic-cpan-distroprefs](https://github.com/eserte/srezic-cpan-distroprefs) — distribution preferences for known problem modules
- [cross-platform-actions](https://github.com/cross-platform-actions/action) — BSD VM runner

## When modifying the workflow

- Keep all three jobs (Linux/macOS, Windows, BSD) in sync — module detection and build/test logic is intentionally parallel across them
- Test changes against a known-good module (e.g. `cpan-authors/Template2`)
- Alpine uses ash, not bash — keep shell commands POSIX-compatible in container steps
- BSD steps run inside a cross-platform-actions VM; `$GITHUB_WORKSPACE` is mapped from the host
