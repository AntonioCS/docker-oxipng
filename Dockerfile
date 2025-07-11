ARG OXIPNG_VERSION="v9.1.5"

FROM rust:1.77-slim AS builder
ARG OXIPNG_VERSION
WORKDIR /oxipng
RUN apt-get update && apt-get install -y \
    git musl-tools pkg-config libpng-dev && \
    rustup target add x86_64-unknown-linux-musl && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN git clone --branch ${OXIPNG_VERSION} --depth 1 https://github.com/shssoichiro/oxipng.git .

# Set build flags for size optimization
ENV RUSTFLAGS="-C opt-level=z -C linker=musl-gcc -C link-arg=-s"
ENV CARGO_PROFILE_RELEASE_LTO=true
ENV CARGO_PROFILE_RELEASE_CODEGEN_UNITS=1

RUN cargo build --release --target x86_64-unknown-linux-musl --target-dir /tmp/build

# Strip symbols (safety net — even though link-arg=-s already helps)
RUN strip /tmp/build/x86_64-unknown-linux-musl/release/oxipng

FROM scratch
COPY --from=builder /tmp/build/x86_64-unknown-linux-musl/release/oxipng /usr/bin/oxipng

ENTRYPOINT ["/usr/bin/oxipng"]
