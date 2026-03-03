#pragma once

#include "iostream"

class Greeter {
private:
  std::string name;

public:
  Greeter(const std::string &n) : name(n) {}

  // Destructor: Automatic cleanup (No GC needed)
  ~Greeter() = default;

  void setName(const std::string &n);
  std::string getName();

  void greet();
};
