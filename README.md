# pre-release

Test CPAN modules from their GitHub repositories across 21 platform combinations before release.

## Usage

Trigger via **Actions > Test CPAN Module from Repository > Run workflow**:

```
Repository: cpan-authors/Some-Module
```

The workflow clones the repository, detects the module's build system (ExtUtils::MakeMaker or Module::Build), installs dependencies from META.json/MYMETA.json, builds, and runs the test suite on every platform in the matrix.

## Platforms

| Category | Targets |
|----------|---------|
| macOS | 14 (Sonoma), 15 (Sequoia) |
| Ubuntu | 22.04, 24.04 |
| Containers | Ubuntu 20.04, 24.04; Fedora 38, 43; Rocky Linux 9; Debian buster, bullseye, bookworm, trixie; Alpine 3.23 |
| Windows | 2022, 2025 (Strawberry Perl) |
| FreeBSD | 13.5, 14.3, 15.0 |
| OpenBSD | 7.8 |
| NetBSD | 10.1 |

## Inputs

| Input | Default | Description |
|-------|---------|-------------|
| `repository` | *(required)* | GitHub repository in `owner/repo` format |
| `include-distroprefs` | `true` | Use [CPAN distribution preferences](https://github.com/eserte/srezic-cpan-distroprefs) to handle known build quirks |
| `include-sysdeps` | `true` | Use [cpan-sysdeps](https://github.com/eserte/cpan-sysdeps) for automatic system dependency installation |
| `enable-cpan-reporter` | `false` | Upload test results to [CPAN Testers](http://cpantesters.org) |
| `debug` | `false` | Enable verbose debug output |

## How it works

1. Sets up per-platform prerequisites (system Perl, git, compilers)
2. Configures CPAN via [ci-helper-cpan-pm](https://github.com/eserte/ci-helper-cpan-pm) with optional distroprefs and sysdeps
3. Clones the target repository
4. Detects the module name from META.json, META.yml, or Makefile.PL
5. Installs configure-time, runtime, build, and test dependencies
6. Runs `perl Makefile.PL && make && make test` (or the Module::Build equivalent)

CPAN test reports are uploaded as workflow artifacts when `enable-cpan-reporter` is enabled.
