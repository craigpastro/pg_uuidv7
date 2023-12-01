# Based off of https://github.com/tembo-io/pgmq/blob/main/images/pgmq-pg/Dockerfile
FROM postgres:16-bookworm as build

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    clang \
    curl \
    gcc \
    libssl-dev \
    pkg-config \
    postgresql-server-dev-16 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
RUN $HOME/.cargo/bin/rustup default stable

# Install pgrx
RUN $HOME/.cargo/bin/cargo install --locked --version 0.11.0 cargo-pgrx
RUN $HOME/.cargo/bin/cargo pgrx init --pg16 $(which pg_config)

# Install pg_uuidv7
COPY . .
RUN $HOME/.cargo/bin/cargo pgrx install -c $(which pg_config)

FROM postgres:16-bookworm

COPY --from=build /usr/share/postgresql/16/extension /usr/share/postgresql/16/extension
COPY --from=build /usr/share/postgresql/16/lib /usr/share/postgresql/16/lib

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

USER postgres
