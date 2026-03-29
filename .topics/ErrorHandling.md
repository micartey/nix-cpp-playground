## Error Handling

| Java Concept                        | C++ Equivalent                            | Note                                                              |
| :---------------------------------- | :---------------------------------------- | :---------------------------------------------------------------- |
| **Exceptions**                      |                                           |                                                                   |
| `throw new Exception("msg")`        | `throw std::runtime_error("msg")`         | Throws by value, not pointer.                                     |
| `try { } catch (Exception e) { }`   | `try { } catch (const std::exception& e)` | Catch by const reference.                                         |
| `finally { }`                        | _Not needed_                              | RAII handles cleanup. Destructors run on scope exit.              |
| `throws Exception` (checked)        | _No equivalent_                           | C++ has no checked exceptions.                                    |
| `RuntimeException` (unchecked)       | All C++ exceptions are unchecked          | Nothing forces you to catch.                                      |
| `e.getMessage()`                     | `e.what()`                                | Returns `const char*`.                                            |
| **Alternatives**                    |                                           |                                                                   |
| `Optional<T>`                        | `std::optional<T>`                        | C++17. Value or nothing. For expected absence.                    |
| _No equivalent_                      | `std::expected<T, E>`                     | C++23. Value or error. Like Rust's `Result<T, E>`.               |
| Return codes / errno                 | Return codes / `errno`                    | C-style. Still used in low-level and performance-critical code.   |

### Exceptions

```cpp
#include <iostream>
#include <stdexcept>
#include <string>

int divide(int a, int b) {
    if (b == 0) throw std::invalid_argument("division by zero");
    return a / b;
}

int main() {
    try {
        std::cout << divide(10, 0) << std::endl;
    } catch (const std::invalid_argument& e) {
        std::cerr << "Error: " << e.what() << std::endl;
    } catch (const std::exception& e) {
        std::cerr << "Unexpected: " << e.what() << std::endl;
    }
    return 0;
}
```

### Exception Hierarchy

```
std::exception
├── std::logic_error
│   ├── std::invalid_argument
│   ├── std::out_of_range
│   └── std::domain_error
├── std::runtime_error
│   ├── std::overflow_error
│   ├── std::underflow_error
│   └── std::range_error
└── std::bad_alloc (out of memory)
```

### `noexcept` — Promise Not to Throw

```cpp
int safe_add(int a, int b) noexcept {
    return a + b;
}
```

Marking a function `noexcept` enables compiler optimizations (especially for move constructors) and documents intent. If it throws anyway, `std::terminate()` is called.

### `std::optional` — Value or Nothing (C++17)

```cpp
#include <iostream>
#include <optional>
#include <string>

std::optional<std::string> find_user(int id) {
    if (id == 1) return "Alice";
    return std::nullopt; // no value
}

int main() {
    auto user = find_user(1);
    if (user.has_value()) {
        std::cout << *user << std::endl; // "Alice"
    }

    auto missing = find_user(99);
    std::cout << missing.value_or("unknown") << std::endl; // "unknown"

    return 0;
}
```

### `std::expected` — Value or Error (C++23)

```cpp
#include <expected>
#include <iostream>
#include <string>

enum class ParseError { empty, invalid };

std::expected<int, ParseError> parse_int(const std::string& s) {
    if (s.empty()) return std::unexpected(ParseError::empty);
    try {
        return std::stoi(s);
    } catch (...) {
        return std::unexpected(ParseError::invalid);
    }
}

int main() {
    auto result = parse_int("42");
    if (result.has_value()) {
        std::cout << *result << std::endl; // 42
    }

    auto err = parse_int("abc");
    if (!err.has_value()) {
        std::cout << "parse failed" << std::endl;
    }

    return 0;
}
```

### When to Use What

| Approach              | When to Use                                                          |
| :-------------------- | :------------------------------------------------------------------- |
| Exceptions            | Truly exceptional/unrecoverable cases. Constructor failures.         |
| `std::optional<T>`    | Value may legitimately be absent. Replaces "null" return.            |
| `std::expected<T, E>` | Operation can fail with a specific error. Like Rust `Result`. C++23. |
| Return codes          | Performance-critical paths. C API interop. Low-level systems code.   |
| `noexcept`            | Functions guaranteed not to throw. Move constructors.                |
