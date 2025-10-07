FROM mcr.microsoft.com/devcontainers/universal:2 AS base

ARG DEBIAN_FRONTEND=noninteractive

# System-wide Rust locations and PATH
ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:${PATH}

# Shared Playwright browsers path
ENV PLAYWRIGHT_BROWSERS_PATH=/ms-playwright

# Minimal native build dependencies commonly required by Rust crates
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        pkg-config \
        libssl-dev \
        zlib1g-dev \
        cmake \
        curl \
        git \
        ca-certificates \
        gnupg \
    && rm -rf /var/lib/apt/lists/*

# Install Rust toolchain (stable) system-wide via rustup and components
RUN mkdir -p ${RUSTUP_HOME} ${CARGO_HOME} \
    && curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | \
       sh -s -- -y --profile minimal --default-toolchain stable --no-modify-path \
    && ${CARGO_HOME}/bin/rustup component add rustfmt clippy rust-src

# Optionally install useful cargo utilities (comment out if undesired)
RUN ${CARGO_HOME}/bin/cargo install --locked cargo-edit cargo-nextest || true

# Ensure /usr/local/cargo/bin is on PATH for all users (login shells)
RUN echo 'export PATH=/usr/local/cargo/bin:$PATH' > /etc/profile.d/cargo.sh \
    && chmod 0755 /etc/profile.d/cargo.sh

########################################
# Notes:
# - Nightly is not installed by default; use rust-toolchain.toml if needed.
########################################

# Install Doppler CLI (system-wide)
RUN curl -Ls https://cli.doppler.com/install.sh | sh

# Pre-install Playwright browsers (with system deps) into shared path
RUN npx --yes playwright@latest install --with-deps \
    && chmod -R a+rx ${PLAYWRIGHT_BROWSERS_PATH}

# Smoketest stage to validate Rust toolchain components exist for root and a non-root user.
# This stage is built in CI for pull_request events (no docker load/push).
FROM base AS smoketest
# Root validation
RUN bash -lc 'set -euo pipefail; \
    echo "[smoketest] root checks"; \
    command -v rustc >/dev/null && rustc --version; \
    command -v cargo >/dev/null && cargo --version; \
    command -v rustfmt >/dev/null && rustfmt --version; \
    command -v cargo >/dev/null && cargo clippy -V; \
    echo "[smoketest] doppler"; \
    command -v doppler >/dev/null && doppler --version; \
    echo "[smoketest] playwright"; \
    test -d "${PLAYWRIGHT_BROWSERS_PATH}" && [ -n "$(ls -A ${PLAYWRIGHT_BROWSERS_PATH})" ]'
# Non-root validation with a generic user (no vscode assumption)
RUN useradd -m -u 10001 -s /bin/bash tester
USER tester
ENV PATH=/usr/local/cargo/bin:${PATH}
RUN bash -lc 'set -euo pipefail; \
    echo "[smoketest] non-root checks (tester)"; \
    command -v rustc >/dev/null && rustc --version; \
    command -v cargo >/dev/null && cargo --version; \
    command -v rustfmt >/dev/null && rustfmt --version; \
    command -v cargo >/dev/null && cargo clippy -V; \
    echo "[smoketest] doppler (tester)"; \
    command -v doppler >/dev/null && doppler --version >/dev/null; \
    echo "[smoketest] playwright (tester)"; \
    test -r "${PLAYWRIGHT_BROWSERS_PATH}" && [ -n "$(ls -A ${PLAYWRIGHT_BROWSERS_PATH})" ]'

# Default/final image stage should remain last so main builds push the full image
FROM base AS final
