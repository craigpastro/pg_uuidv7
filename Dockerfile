# Copied from https://github.com/supabase/pg_jsonschema/blob/master/dockerfiles/db/Dockerfile
FROM postgres:15-bookworm

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    build-essential \
    pkg-config \
    libssl-dev \
    libclang-dev \
    postgresql-server-dev-15 \
    && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /foo
ENV HOME=/foo
ENV PATH=/foo/.cargo/bin:$PATH
RUN chown postgres:postgres -R /foo

USER postgres
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path --profile minimal
RUN cargo install --locked --version 0.9.7 cargo-pgrx
RUN cargo pgrx init --pg15 $(which pg_config)

USER root
COPY . .
RUN cargo pgrx install

RUN chown -R postgres:postgres /foo
RUN chown -R postgres:postgres /usr/share/postgresql/15/extension
RUN chown -R postgres:postgres /usr/lib/postgresql/15/lib

USER postgres
