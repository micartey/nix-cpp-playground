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

db-browse:
    sqlite3 helloworld.sqlite

db-clean:
    rm -f helloworld.sqlite
