# pre-release

Test CPAN modules across 21 OS targets before releasing to CPAN.

A shared GitHub Actions workflow for the [cpan-authors](https://github.com/cpan-authors) organization. Dispatches on-demand against any GitHub-hosted CPAN module repository.

## Usage

1. Go to **Actions** > **Test CPAN Module from Repository**
2. Click **Run workflow**
3. Enter the repository (e.g. `cpan-authors/Tree-MultiNode`)
4. Optionally toggle distribution preferences, system dependencies, CPAN reporter, or debug output

Or trigger via CLI:

```bash
gh workflow run test-repo.yml \
  -R cpan-authors/pre-release \
  -f repository=cpan-authors/Tree-MultiNode
```

## Workflow inputs

| Input | Type | Default | Description |
|-------|------|---------|-------------|
| `repository` | string | *(required)* | GitHub repository in `owner/repo` format |
| `include-distroprefs` | boolean | `true` | Use CPAN distribution preferences ([srezic-cpan-distroprefs](https://github.com/eserte/srezic-cpan-distroprefs)) |
| `include-sysdeps` | boolean | `true` | Use [cpan-sysdeps](https://github.com/eserte/cpan-sysdeps) for system dependencies |
| `enable-cpan-reporter` | boolean | `false` | Send test reports to [CPAN Testers](http://www.cpantesters.org/) |
| `debug` | boolean | `false` | Enable debug output |

## Platform matrix

The workflow tests on 21 targets across 7 operating systems:

**Linux (native runners)**
- Ubuntu 22.04, 24.04

**Linux (containers)**
- Ubuntu 20.04, 24.04
- Fedora 38, 43
- Rocky Linux 9
- Debian buster, bullseye, bookworm, trixie
- Alpine 3.23

**macOS**
- macOS 14 (Sonoma), macOS 15 (Sequoia)

**Windows**
- Windows Server 2022, 2025 (Strawberry Perl)

**BSD** (via [cross-platform-actions](https://github.com/cross-platform-actions/action))
- FreeBSD 13.5, 14.3, 15.0
- OpenBSD 7.8
- NetBSD 10.1

## Build system support

Supports both `ExtUtils::MakeMaker` (`Makefile.PL`) and `Module::Build` (`Build.PL`). Dependencies are resolved from `META.json`/`META.yml` (configure phase) and `MYMETA.json` (runtime, build, test phases).

## Example runs

- [Tree-MultiNode](https://github.com/cpan-authors/pre-release/actions/runs/29623817307) (pure Perl) -- 21/21
- [YAML-Syck](https://github.com/cpan-authors/pre-release/actions/runs/29625219623) (XS, bundled C) -- 21/21
