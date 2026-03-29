## Templates

| Java Concept                        | C++ Template Equivalent                  | Note                                                              |
| :---------------------------------- | :--------------------------------------- | :---------------------------------------------------------------- |
| **Generics**                        |                                          |                                                                   |
| `<T>`                               | `template<typename T>`                   | C++ templates are resolved at compile time, not erased at runtime.|
| `<T extends Comparable<T>>`         | `template<typename T> requires ...`      | C++20 concepts constrain template parameters.                     |
| `<? extends T>`                     | _Not needed_                             | Templates are structural — any type that works, works.            |
| `<? super T>`                       | _Not needed_                             | No type erasure means no wildcard variance needed.                |
| **Key Differences**                 |                                          |                                                                   |
| Type erasure at runtime             | Full code generation at compile time     | C++ generates a separate function/class for each type used.       |
| Cannot use primitives (`List<int>`) | Works with all types (`vector<int>`)     | No boxing/unboxing overhead.                                      |
| Runtime type checks (`instanceof`)  | `if constexpr` / `std::is_same_v`       | Compile-time type branching.                                      |

### Function Templates

```cpp
#include <iostream>

template<typename T>
T max_of(T a, T b) {
    return (a > b) ? a : b;
}

int main() {
    std::cout << max_of(3, 7) << std::endl;           // int
    std::cout << max_of(3.14, 2.71) << std::endl;     // double
    std::cout << max_of<std::string>("a", "b") << std::endl; // explicit type
    return 0;
}
```

### Class Templates

```cpp
#include <iostream>
#include <stdexcept>

template<typename T, int Capacity>
class FixedStack {
    T data[Capacity];
    int top = 0;

public:
    void push(const T& value) {
        if (top >= Capacity) throw std::overflow_error("stack full");
        data[top++] = value;
    }

    T pop() {
        if (top <= 0) throw std::underflow_error("stack empty");
        return data[--top];
    }

    int size() const { return top; }
};

int main() {
    FixedStack<int, 10> stack;
    stack.push(42);
    stack.push(99);
    std::cout << stack.pop() << std::endl; // 99
    return 0;
}
```

### Template Specialization

```cpp
#include <iostream>
#include <string>

template<typename T>
std::string to_display(const T& value) {
    return std::to_string(value);
}

// Full specialization for std::string
template<>
std::string to_display(const std::string& value) {
    return "\"" + value + "\"";
}

int main() {
    std::cout << to_display(42) << std::endl;              // "42"
    std::cout << to_display(std::string("hi")) << std::endl; // "\"hi\""
    return 0;
}
```

### C++20 Concepts (Constrained Templates)

```cpp
#include <concepts>
#include <iostream>

template<typename T>
concept Addable = requires(T a, T b) {
    { a + b } -> std::convertible_to<T>;
};

template<Addable T>
T add(T a, T b) {
    return a + b;
}

int main() {
    std::cout << add(1, 2) << std::endl;       // OK
    std::cout << add(1.5, 2.5) << std::endl;   // OK
    // add(std::mutex{}, std::mutex{});         // ERROR: mutex is not Addable
    return 0;
}
```

### `if constexpr` — Compile-Time Branching

```cpp
#include <iostream>
#include <string>
#include <type_traits>

template<typename T>
void describe(const T& value) {
    if constexpr (std::is_integral_v<T>) {
        std::cout << value << " is an integer" << std::endl;
    } else if constexpr (std::is_floating_point_v<T>) {
        std::cout << value << " is a float" << std::endl;
    } else {
        std::cout << "something else" << std::endl;
    }
}

int main() {
    describe(42);    // "42 is an integer"
    describe(3.14);  // "3.14 is a float"
    describe("hi");  // "something else"
    return 0;
}
```

### Variadic Templates

```cpp
#include <iostream>

template<typename... Args>
void print_all(const Args&... args) {
    ((std::cout << args << " "), ...); // C++17 fold expression
    std::cout << std::endl;
}

int main() {
    print_all(1, "hello", 3.14, true); // 1 hello 3.14 1
    return 0;
}
```

### When to Use What

| Feature                | When to Use                                                  |
| :--------------------- | :----------------------------------------------------------- |
| Function template      | Generic algorithms that work across types.                   |
| Class template         | Generic data structures (`Stack<T>`, `Pair<K,V>`).           |
| Concepts (C++20)       | Constrain templates with readable error messages.            |
| `if constexpr`         | Different logic per type at compile time, zero runtime cost. |
| Specialization         | Override behavior for a specific type.                       |
| Variadic templates     | Functions accepting any number of arguments.                 |
