FROM rust:1.82.0-bookworm AS rust-builder-base
RUN rustup default nightly

FROM golang:1.23.1 AS go-builder-base

FROM debian:bookworm AS release-base
RUN apt-get update && apt-get install -y libssl-dev

# Do some separated rust builds. Why? No idea.
FROM rust-builder-base AS vm-builder
COPY ./dope-vm /app
WORKDIR /app/dopechain-vm
RUN rustc --version
RUN cargo build --release
# /app/target/release/dopechain-vm

FROM rust-builder-base AS contract-builder
COPY ./dope-vm /app
WORKDIR /app/dopechain-contracts
RUN rustup target add wasm32-unknown-unknown
RUN rustc --version
RUN cargo build --release --target wasm32-unknown-unknown
#/app/target/wasm32-unknown-unknown/release/dopechain-contracts.wasm

# Golang kebab kraftowy kebab emporium gdańsk chełm
FROM go-builder-base AS go-builder
COPY ./dope-node /app
WORKDIR /app
RUN go mod download
RUN go build -o /entrypoint

FROM release-base AS release
COPY --from=go-builder /entrypoint /app/entrypoint
COPY --from=vm-builder /app/target/release /vm/vm
COPY --from=contract-builder /app/target/wasm32-unknown-unknown/release /vm/contracts
COPY ./dope-node/config.toml /etc/dope-node/config.toml
EXPOSE 7313
ENTRYPOINT ["/app/entrypoint"]

