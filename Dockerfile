FROM mcr.microsoft.com/devcontainers/universal:2

ARG DEBIAN_FRONTEND=noninteractive
ARG USERNAME=vscode

# System-wide Rust locations and PATH
ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:${PATH}

# Base native build dependencies commonly required by Rust crates
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        clang \
        lld \
        pkg-config \
        libssl-dev \
        zlib1g-dev \
        cmake \
        curl \
        git \
        ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Rust toolchain (stable) system-wide via rustup and components
RUN mkdir -p ${RUSTUP_HOME} ${CARGO_HOME} \
    && curl -fsSL https://sh.rustup.rs -o /tmp/rustup-init.sh \
    && chmod +x /tmp/rustup-init.sh \
    && /tmp/rustup-init.sh -y --profile minimal --default-toolchain stable --no-modify-path \
    && rm -f /tmp/rustup-init.sh \
    && ${CARGO_HOME}/bin/rustup component add rustfmt clippy rust-src

# Optionally install useful cargo utilities
RUN ${CARGO_HOME}/bin/cargo install --locked cargo-edit cargo-nextest

# Ensure /usr/local/cargo/bin is on PATH for all users (login shells)
RUN echo 'export PATH=/usr/local/cargo/bin:$PATH' > /etc/profile.d/cargo.sh \
    && chmod 0755 /etc/profile.d/cargo.sh

# Allow the default non-root user (vscode) to use and update toolchains/cargo cache
RUN chown -R ${USERNAME}:${USERNAME} ${RUSTUP_HOME} ${CARGO_HOME} \
    && chmod -R g+rwx ${RUSTUP_HOME} ${CARGO_HOME}

# Notes:
# - lld is present; prefer setting RUSTFLAGS per-project if desired:
#   RUSTFLAGS="-C link-arg=-fuse-ld=lld"
# - Nightly is not installed by default; use rust-toolchain.toml if needed.

