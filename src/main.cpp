#include "Greeter.cpp"
#include <algorithm>
#include <cstdio>
#include <iostream>
#include <memory>
#include <string>
#include <vector>

void printNumbers(int start, int end) {
  for (int i = start; i <= end; ++i) {
    std::cout << i << " ";
  }
  std::cout << std::endl;
}

int add(int a, int b) { return a + b; }

int factorial(int n) {
  if (n <= 1)
    return 1;
  return n * factorial(n - 1);
}

int main() {
  // Variables and data types
  int age = 25;
  double height = 5.9;
  char grade = 'A';
  bool isStudent = true;
  std::string name = "World";

  // Apparently std::cout is not being used anymore!
  // We should use "printf"
  printf("Hello World!\n");

  std::cout << "Age: " << age << std::endl;
  std::cout << "Height: " << height << std::endl;
  std::cout << "Grade: " << grade << std::endl;
  std::cout << "Is Student: " << std::boolalpha << isStudent << std::endl;

  // Control flow - if/else
  if (age >= 18) {
    std::cout << name << " is an adult" << std::endl;
  } else {
    std::cout << name << " is a minor" << std::endl;
  }

  // Control flow - switch
  switch (grade) {
  case 'A':
    std::cout << "Excellent!" << std::endl;
    break;
  case 'B':
    std::cout << "Good!" << std::endl;
    break;
  default:
    std::cout << "Keep trying!" << std::endl;
  }

  // Control flow - for loop
  std::cout << "Counting to 5: ";
  for (int i = 1; i <= 5; ++i) {
    std::cout << i << " ";
  }
  std::cout << std::endl;

  // Control flow - while loop
  int count = 0;
  while (count < 3) {
    std::cout << "Count: " << count << std::endl;
    ++count;
  }

  // Functions
  std::cout << "5 + 3 = " << add(5, 3) << std::endl;
  std::cout << "Factorial of 5: " << factorial(5) << std::endl;

  // Pass by reference
  printNumbers(1, 10);

  // Vectors (STL)
  std::vector<int> numbers = {5, 2, 8, 1, 9};
  std::cout << "Vector before sort: ";
  for (int n : numbers)
    std::cout << n << " ";
  std::cout << std::endl;

  std::sort(numbers.begin(), numbers.end());
  std::cout << "Vector after sort: ";
  for (int n : numbers)
    std::cout << n << " ";
  std::cout << std::endl;

  // String operations
  std::string str1 = "Hello";
  std::string str2 = "World";
  std::string combined = str1 + ", " + str2 + "!";
  std::cout << combined << std::endl;
  std::cout << "Length: " << combined.length() << std::endl;

  // Classes and objects
  Greeter greeter(name);
  greeter.greet();

  // Using a pointer
  Greeter *ptr = &greeter;
  ptr->setName("C++");
  ptr->greet();

  // Smart pointer (memory management)
  auto smartGreeter = std::make_unique<Greeter>("Smart Pointer");
  smartGreeter->greet();

  // Ternary operator
  std::string result = (age >= 18) ? "adult" : "minor";
  std::cout << "Status: " << result << std::endl;

  // Constants
  const int MAX_SIZE = 100;
  std::cout << "Max size: " << MAX_SIZE << std::endl;

  // Enum
  enum Color { RED, GREEN, BLUE };
  Color c = GREEN;
  std::cout << "Color enum value: " << c << std::endl;

  std::cout << "=== Program Complete ===" << std::endl;
  return 0;
}
