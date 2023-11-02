# Copied from https://github.com/supabase/pg_jsonschema/blob/master/dockerfiles/db/Dockerfile
FROM postgres:16-bookworm

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    build-essential \
    pkg-config \
    libssl-dev \
    libclang-dev \
    postgresql-server-dev-16 \
    && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /foo
ENV HOME=/foo
ENV PATH=/foo/.cargo/bin:$PATH
RUN chown postgres:postgres -R /foo

USER postgres
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path --profile minimal
RUN cargo install --locked --version 0.11.0 cargo-pgrx
RUN cargo pgrx init --pg16 $(which pg_config)

USER root
COPY . .
RUN cargo pgrx install

RUN chown -R postgres:postgres /foo
RUN chown -R postgres:postgres /usr/share/postgresql/16/extension
RUN chown -R postgres:postgres /usr/lib/postgresql/16/lib

USER postgres
