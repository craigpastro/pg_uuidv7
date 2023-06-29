FROM postgres:15-bookworm

ENV PATH="/root/.cargo/bin:${PATH}"

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

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
RUN cargo install --locked --version 0.9.6 cargo-pgrx
RUN cargo pgrx init --pg15 $(which pg_config)
COPY . .
RUN cargo pgrx install
USER postgres

