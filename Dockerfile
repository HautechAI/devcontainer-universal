FROM mcr.microsoft.com/devcontainers/universal:2

ARG DEBIAN_FRONTEND=noninteractive

# System-wide Rust locations and PATH
ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:${PATH}

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

# Notes:
# - Nightly is not installed by default; use rust-toolchain.toml if needed.
