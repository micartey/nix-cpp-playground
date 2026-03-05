#pragma once

#include "iostream"

class Greeter {
private:
  std::string name;

public:
  Greeter(const std::string &n) : name(n) {}

  // Destructor: Automatic cleanup (No GC needed)
  ~Greeter() = default;

  /**
   * Set the persons name that shall be greeted
   *
   * @param The Name
   */
  void setName(const std::string &n);
  std::string getName();

  /**
   * Greet the person that shall be greeted by the Greeter
   */
  void greet();
};
