## Strings

| Java Concept                    | C++ Equivalent                         | Note                                                              |
| :------------------------------ | :------------------------------------- | :---------------------------------------------------------------- |
| `String`                        | `std::string`                          | Mutable, heap-allocated, owning.                                  |
| `String` (read-only param)      | `std::string_view`                     | Non-owning, read-only view. No allocation. C++17.                 |
| `char[]`                        | `const char*` (C-string)               | Null-terminated. Avoid in modern C++ unless interfacing with C.   |
| `"literal"`                     | `"literal"` (`const char*`)            | String literals are `const char[]`, decay to `const char*`.       |
| `"literal"`                     | `"literal"s` (`std::string`)           | `s` suffix creates a `std::string`. Requires `using namespace std::string_literals`. |
| `str.length()`                  | `str.size()` / `str.length()`          | Both work identically.                                            |
| `str.charAt(i)`                 | `str[i]` / `str.at(i)`                | `at()` is bounds-checked and throws on out-of-range.              |
| `str.substring(a, b)`           | `str.substr(a, len)`                   | Second arg is length, not end index.                              |
| `str.contains(s)`               | `str.contains(s)`                      | C++23. Before: `str.find(s) != std::string::npos`.               |
| `str.startsWith(s)`             | `str.starts_with(s)`                   | C++20.                                                            |
| `str.endsWith(s)`               | `str.ends_with(s)`                     | C++20.                                                            |
| `str.indexOf(s)`                | `str.find(s)`                          | Returns `std::string::npos` if not found.                         |
| `str1 + str2`                   | `str1 + str2`                          | Works with `std::string`. Allocates a new string.                 |
| `String.format(...)`            | `std::format(...)`                     | C++20. Type-safe, similar to Python f-strings.                    |
| `str.trim()`                    | _No built-in_                          | Use `std::ranges` or write a helper.                              |
| `str.split(delim)`              | _No built-in_                          | Use `std::views::split` (C++20) or manual parsing.               |
| `String.valueOf(x)`             | `std::to_string(x)`                    | Converts numbers to string.                                       |
| `Integer.parseInt(s)`           | `std::stoi(s)` / `std::stol(s)`       | Throws on invalid input.                                          |

### `std::string` — Owning String

```cpp
#include <iostream>
#include <string>

int main() {
    std::string greeting = "Hello";
    greeting += ", World!";

    std::cout << greeting << std::endl;            // Hello, World!
    std::cout << greeting.size() << std::endl;     // 13
    std::cout << greeting.substr(0, 5) << std::endl; // Hello
    std::cout << greeting[0] << std::endl;         // H

    if (greeting.starts_with("Hello")) { // C++20
        std::cout << "starts with Hello" << std::endl;
    }

    return 0;
}
```

### `std::string_view` — Non-Owning View

```cpp
#include <iostream>
#include <string>
#include <string_view>

void print_name(std::string_view name) { // no allocation, no copy
    std::cout << "Hello, " << name << std::endl;
}

int main() {
    std::string s = "Alice";
    const char* c = "Bob";

    print_name(s);       // works with std::string
    print_name(c);       // works with const char*
    print_name("Carol"); // works with string literal

    // string_view can take substrings without allocating
    std::string_view sv = "Hello, World!";
    std::cout << sv.substr(0, 5) << std::endl; // "Hello" — no allocation

    return 0;
}
```

### `std::format` — Type-Safe Formatting (C++20)

```cpp
#include <format>
#include <iostream>
#include <string>

int main() {
    std::string name = "Alice";
    int age = 30;

    std::string msg = std::format("{} is {} years old", name, age);
    std::cout << msg << std::endl; // Alice is 30 years old

    std::cout << std::format("{:>10}", "right") << std::endl;  // "     right"
    std::cout << std::format("{:.2f}", 3.14159) << std::endl;  // "3.14"

    return 0;
}
```

### String Splitting (C++20)

```cpp
#include <iostream>
#include <ranges>
#include <string>
#include <string_view>

int main() {
    std::string csv = "one,two,three";

    for (auto part : csv | std::views::split(',')) {
        std::string_view token(part.begin(), part.end());
        std::cout << token << std::endl;
    }
    // one
    // two
    // three

    return 0;
}
```

### C-Strings — When You Need Them

```cpp
#include <cstring>
#include <iostream>
#include <string>

int main() {
    std::string s = "hello";

    const char* cstr = s.c_str(); // get null-terminated C-string
    std::cout << std::strlen(cstr) << std::endl; // 5

    // C APIs often require const char*
    // std::string::c_str() is your bridge

    return 0;
}
```

### When to Use What

| Type               | When to Use                                                         |
| :----------------- | :------------------------------------------------------------------ |
| `std::string`      | Default. Owning, mutable strings.                                   |
| `std::string_view` | Read-only function parameters. Avoids copies and allocations.       |
| `const char*`      | Interfacing with C APIs. String literals.                           |
| `std::format`      | Formatted output. Prefer over `sprintf` and stream concatenation.   |
