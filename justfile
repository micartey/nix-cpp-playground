default:
    @just --list

build:
    g++ -std=c++17 -Wall -Wextra -o main main.cpp

build-static:
    g++ -static main.cpp -o main

run: build
    ./main

run-static: build-static
    ./main
