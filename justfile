default:
    @just --list

build:
	g++ -std=c++17 -Wall -Wextra -I include -o main ./src/*.cpp

build-static:
	g++ -static -I include ./src/*.cpp -o main

run: build
    ./main

run-static: build-static
    ./main
