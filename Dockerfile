# Based off of https://github.com/tembo-io/pgmq/blob/main/images/pgmq-pg/Dockerfile
ARG PG_MAJOR_VERSION=16

FROM postgres:${PG_MAJOR_VERSION}-bookworm AS build

ARG PG_MAJOR_VERSION=16

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    clang \
    curl \
    gcc \
    libssl-dev \
    pkg-config \
    postgresql-server-dev-${PG_MAJOR_VERSION} \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
RUN $HOME/.cargo/bin/rustup default stable

# Install pgrx
RUN $HOME/.cargo/bin/cargo install --locked --version 0.11.0 cargo-pgrx
RUN $HOME/.cargo/bin/cargo pgrx init --pg${PG_MAJOR_VERSION} $(which pg_config)

# Install pg_uuidv7
COPY . .
RUN $HOME/.cargo/bin/cargo pgrx install -c $(which pg_config)

FROM postgres:${PG_MAJOR_VERSION}-bookworm

ARG PG_MAJOR_VERSION=16

COPY --from=build /usr/share/postgresql/${PG_MAJOR_VERSION}/extension /usr/share/postgresql/${PG_MAJOR_VERSION}/extension
COPY --from=build /usr/lib/postgresql/${PG_MAJOR_VERSION}/lib /usr/lib/postgresql/${PG_MAJOR_VERSION}/lib

USER postgres
