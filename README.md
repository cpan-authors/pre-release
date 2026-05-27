# pre-release

Test your CPAN module across 21 OS targets before uploading to CPAN.

This repository provides a GitHub Actions workflow that clones any CPAN module
from its GitHub repository and runs its test suite across Linux distributions,
macOS, Windows, and BSDs — giving you a CPAN Testers-like matrix without
waiting for the upload cycle.

## Usage

1. Go to **Actions → Test CPAN Module from Repository → Run workflow**
2. Enter the GitHub repository (e.g. `cpan-authors/Template2`)
3. Choose options:
   - **Use CPAN distribution preferences** — applies [srezic-cpan-distroprefs](https://github.com/eserte/srezic-cpan-distroprefs) for known problem modules
   - **Use cpan-sysdeps plugin** — automatically installs system-level dependencies
   - **Send test reports to CPAN Testers** — uploads results to cpantesters.org
   - **Enable debug output** — verbose logging for troubleshooting

## Platform Matrix

| Category | Targets |
|----------|---------|
| **macOS** | macOS 14 (Sonoma), macOS 15 (Sequoia) |
| **Ubuntu** | 22.04, 24.04 (native runners) |
| **Linux containers** | Ubuntu 20.04, Ubuntu 24.04, Fedora 38, Fedora 43, Rocky Linux 9, Debian Buster/Bullseye/Bookworm/Trixie, Alpine 3.23 |
| **Windows** | Windows Server 2022, Windows Server 2025 (Strawberry Perl) |
| **BSD** | FreeBSD 13.5/14.3/15.0, OpenBSD 7.8, NetBSD 10.1 |

## How It Works

The workflow:

1. Checks out [ci-helper-cpan-pm](https://github.com/eserte/ci-helper-cpan-pm) to configure CPAN with distroprefs and sysdeps support
2. Clones the target module repository
3. Detects the module name from META.json, META.yml, or Makefile.PL
4. Installs system dependencies via cpan-sysdeps (when available for the platform)
5. Installs configure-time deps from META.json, then configures the build system
6. Installs runtime/build/test deps from MYMETA.json
7. Builds and runs the test suite

Both `ExtUtils::MakeMaker` and `Module::Build` are supported.

## Requirements

This is a `workflow_dispatch` workflow — it must be triggered manually from the
Actions tab or via the GitHub API/CLI:

```bash
gh workflow run "Test CPAN Module from Repository" \
  -f repository=cpan-authors/Template2 \
  -f include-distroprefs=true \
  -f include-sysdeps=true
```
