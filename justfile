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

conan-install:
    conan install . --build=missing -pr:h profiles/default -pr:b profiles/default

conan-build: conan-install
    conan build . -pr:h profiles/default -pr:b profiles/default

conan-build-static:
    conan install . --build=missing -pr:h profiles/static -pr:b profiles/static
    conan build . -pr:h profiles/static -pr:b profiles/static

db-browse:
    sqlite3 helloworld.sqlite

db-clean:
    rm -f helloworld.sqlite
