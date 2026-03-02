default:
    @just --list

build:
    g++ -std=c++17 -Wall -Wextra -o main ./src/main.cpp

build-static:
    g++ -static ./src/main.cpp -o main

run: build
    ./main

run-static: build-static
    ./main
