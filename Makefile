# OmaTools Makefile (Rust)

.PHONY: all build test clean run

all: build

build:
	cargo build --release

debug:
	cargo build

test:
	cargo test

run:
	cargo run -- status

clean:
	cargo clean
