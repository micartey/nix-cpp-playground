#include "Greeter.hpp"
#include "iostream"

void Greeter::setName(const std::string &n) { name = n; }

std::string Greeter::getName() { return name; }

void Greeter::greet() { std::cout << "Hello, " << name << "!" << std::endl; }
