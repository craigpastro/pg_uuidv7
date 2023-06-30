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

WORKDIR /tmp
ENV HOME=/tmp
ENV PATH=/tmp/.cargo/bin:$PATH

USER postgres
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path --profile minimal
RUN cargo install --locked --version 0.9.7 cargo-pgrx
RUN cargo pgrx init --pg15 $(which pg_config)

USER root
COPY . .
RUN cargo pgrx install

USER postgres
