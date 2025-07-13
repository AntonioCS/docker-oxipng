ARG OXIPNG_VERSION="v9.1.5"

# Use a recent Rust version (1.78+) because cargo-zigbuild requires it
FROM rust:1.78-slim AS builder
ARG OXIPNG_VERSION
WORKDIR /app

# -----------------------------------------------------------------------------
# Install Zig manually and build essentials
#
# Why this is necessary:
# - We tried using musl-gcc directly to build a static oxipng binary
# - But that led to segfaults due to ABI issues with libpng/zlib + musl
# - Even with `crt-static` and `--target x86_64-unknown-linux-musl`, we hit
#   runtime errors that were impossible to debug cleanly inside scratch
#
# Solution:
# - Use `cargo-zigbuild`, which leverages Zig to link musl statically
# - Zig handles libc, zlib, and other edge cases better than musl-gcc
# - Result is a fully portable, truly static, scratch-safe binary
# -----------------------------------------------------------------------------
RUN apt-get update && apt-get install -y \
    git curl build-essential pkg-config python3 unzip ca-certificates && \
    curl -LO https://ziglang.org/download/0.12.0/zig-linux-x86_64-0.12.0.tar.xz && \
    tar -xf zig-linux-x86_64-0.12.0.tar.xz && \
    mv zig-linux-x86_64-0.12.0 /opt/zig && \
    ln -s /opt/zig/zig /usr/local/bin/zig && \
    rustup target add x86_64-unknown-linux-musl && \
    cargo install cargo-zigbuild && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN git clone --branch ${OXIPNG_VERSION} --depth 1 https://github.com/shssoichiro/oxipng.git oxipng

# -----------------------------------------------------------------------------
# Build with cargo-zigbuild for a statically linked musl binary
#
# This avoids segfaults we previously saw with manual musl-gcc builds.
# We also strip the binary to reduce image size.
# -----------------------------------------------------------------------------
RUN cd oxipng && cargo zigbuild --release --target x86_64-unknown-linux-musl && \
    strip target/x86_64-unknown-linux-musl/release/oxipng

FROM scratch
COPY --from=builder /app/oxipng/target/x86_64-unknown-linux-musl/release/oxipng /oxipng
ENTRYPOINT ["/oxipng"]
