FROM mcr.microsoft.com/devcontainers/universal:2 AS base

ARG DEBIAN_FRONTEND=noninteractive

# System-wide Rust locations and PATH
ENV RUSTUP_HOME=/usr/local/rustup     CARGO_HOME=/usr/local/cargo     PATH=/usr/local/cargo/bin:/usr/local/rvm/gems/ruby-3.4.1/bin:/usr/local/rvm/gems/ruby-3.4.1@global/bin:/usr/local/rvm/rubies/ruby-3.4.1/bin:/usr/local/cargo/bin:/home/codespace/.dotnet:/home/codespace/nvm/current/bin:/home/codespace/.php/current/bin:/home/codespace/.python/current/bin:/home/codespace/java/current/bin:/home/codespace/.ruby/current/bin:/home/codespace/.local/bin:/usr/local/python/current/bin:/usr/local/py-utils/bin:/usr/local/jupyter:/usr/local/oryx:/usr/local/go/bin:/go/bin:/usr/local/sdkman/bin:/usr/local/sdkman/candidates/java/current/bin:/usr/local/sdkman/candidates/gradle/current/bin:/usr/local/sdkman/candidates/maven/current/bin:/usr/local/sdkman/candidates/ant/current/bin:/usr/local/rvm/gems/default/bin:/usr/local/rvm/gems/default@global/bin:/usr/local/rvm/rubies/default/bin:/usr/local/share/rbenv/bin:/usr/local/php/current/bin:/opt/conda/bin:/usr/local/nvs:/usr/local/share/nvm/current/bin:/usr/local/hugo/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/share/dotnet:/root/.dotnet/tools:/usr/local/rvm/bin

# Shared Playwright browsers path
ENV PLAYWRIGHT_BROWSERS_PATH=/ms-playwright

# Minimal native build dependencies commonly required by Rust crates
RUN apt-get update     && apt-get install -y --no-install-recommends         build-essential         pkg-config         libssl-dev         zlib1g-dev         cmake         curl         git         ca-certificates         gnupg         ripgrep     && rm -rf /var/lib/apt/lists/*

# Install Rust toolchain (stable) system-wide via rustup and components
RUN mkdir -p /usr/local/rustup /usr/local/cargo     && curl --proto =https --tlsv1.2 -sSf https://sh.rustup.rs |        sh -s -- -y --profile minimal --default-toolchain stable --no-modify-path     && /usr/local/cargo/bin/rustup component add rustfmt clippy rust-src

# Optionally install useful cargo utilities (comment out if undesired)
RUN /usr/local/cargo/bin/cargo install --locked cargo-edit cargo-nextest || true

# Ensure /usr/local/cargo/bin is on PATH for all users (login shells)
RUN echo export
