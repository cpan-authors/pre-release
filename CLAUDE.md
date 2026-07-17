# CLAUDE.md

## What is pre-release

A GitHub Actions workflow suite that tests CPAN modules across 21+ OS targets
(Linux, macOS, Windows, BSDs). Pre-upload validation — run the matrix before
releasing to CPAN.

Repository: cpan-authors/pre-release (upstream, not a fork)

## Project structure

```
.github/workflows/
  test-repo.yml              # Test from GitHub repo — 3 parallel jobs:
                              #   test-module (Linux/macOS containers + native)
                              #   test-module-windows (Strawberry Perl)
                              #   test-module-bsd (FreeBSD, OpenBSD, NetBSD)
  test-cpan-module.yml       # Test by CPAN module name (cpanm -v)
  test-perl-versions.yml     # Perl version matrix 5.14-5.40
  test-reverse-deps.yml      # Reverse dependency testing via MetaCPAN
  validate.yml               # CI: actionlint + shellcheck
.github/dependabot.yml       # Auto-update GitHub Actions versions
scripts/
  detect-module.sh           # Shared: detect module name from META/Makefile.PL
  build-and-test.sh          # Shared: configure, install deps, build, test
  trigger-test.sh            # CLI helper: trigger test workflows
  trigger-reverse-deps.sh    # CLI helper: trigger reverse dep testing
```

## Conventions

- Workflows are `workflow_dispatch` + `workflow_call` — no automatic triggers
- Module detection order: META.json > META.yml > Makefile.PL
- Two-pass dependency install: configure deps from META.json, then runtime/build/test from MYMETA.json
- `actions/checkout@v3` for debian:buster (old glibc); `@v6` everywhere else
- `cross-platform-actions/action@v0.32.0` for BSD testing
- Windows uses `perl -MConfig -e 'print $Config{make}'` to detect correct make command
- ci-helper-cpan-pm (eserte) handles CPAN configuration, distroprefs, and sysdeps
- Shell inputs (`repository`, `ref`, `module`) passed via env vars to prevent injection
- `toJSON(github.event.inputs)` passed via env vars, never interpolated in shell

## Key dependencies

- [ci-helper-cpan-pm](https://github.com/eserte/ci-helper-cpan-pm) — CPAN CI setup
- [srezic-cpan-distroprefs](https://github.com/eserte/srezic-cpan-distroprefs) — distroprefs for problem modules
- [cross-platform-actions](https://github.com/cross-platform-actions/action) — BSD VM runner
- [actions-setup-perl](https://github.com/shogo82148/actions-setup-perl) — Perl version matrix

## When modifying workflows

- Shared logic lives in `scripts/` — update there, not inline in YAML
- Keep the three jobs in test-repo.yml consistent in behavior
- Test changes against a known-good module (e.g. `cpan-authors/Template2`)
- Alpine uses ash — keep container shell commands POSIX-compatible
- BSD steps run inside cross-platform-actions VM; `$GITHUB_WORKSPACE` is mapped from host
- Run `actionlint` and `shellcheck` before committing (validate.yml checks these in CI)
- Never interpolate user-controlled inputs directly in `run:` blocks — use `env:` vars
