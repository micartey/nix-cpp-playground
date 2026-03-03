default:
    @just --list

build:
	nix build .#default

build-static:
	nix build .#static

run: build
    ./result/bin/main

run-static: build-static
    ./result/bin/main
