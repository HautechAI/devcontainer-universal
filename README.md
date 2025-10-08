devcontainer-universal

Container image: ghcr.io/hautechai/devcontainer-universal

Overview
- Extends mcr.microsoft.com/devcontainers/universal:4-linux with Rust (stable) via rustup.
- System-wide install with RUSTUP_HOME=/usr/local/rustup and CARGO_HOME=/usr/local/cargo; PATH includes /usr/local/cargo/bin for all users.
- Components: rustfmt, clippy, rust-src. Native deps: build-essential, clang, lld, pkg-config, libssl-dev, zlib1g-dev, cmake, curl, git, ca-certificates, ripgrep (rg).
- Optional utilities: cargo-edit, cargo-nextest.
 - Includes Doppler CLI and Playwright browsers preinstalled. Browsers are shared at /ms-playwright (PLAYWRIGHT_BROWSERS_PATH) for all users.

Usage
- Dev Container: set devcontainer.json to use the published image:
  - "image": "ghcr.io/hautechai/devcontainer-universal:stable"
- Docker CLI:
  - docker run --rm -it ghcr.io/hautechai/devcontainer-universal:stable bash

Tags
- latest, stable, sha-<short>, YYYYMMDD.

Notes
- Nightly not installed by default; use rust-toolchain.toml if needed.
- lld installed; consider RUSTFLAGS="-C link-arg=-fuse-ld=lld" per-project.
 - Doppler CLI is installed via the official install script.
 - Playwright browsers are installed with --with-deps and shared at /ms-playwright; permissions allow read/execute for non-root users.


Compatibility
- Base image: mcr.microsoft.com/devcontainers/universal:4-linux.
- GLIBC >= 2.34 is asserted in Dockerfile smoketests and the main workflow.