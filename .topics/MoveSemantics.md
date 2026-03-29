## Move Semantics

| Java Concept                    | C++ Move Semantics Equivalent        | Note                                                                  |
| :------------------------------ | :----------------------------------- | :-------------------------------------------------------------------- |
| Assignment copies reference     | Assignment copies the object         | C++ copies by default. Move avoids the copy.                          |
| _No equivalent_                 | `std::move(obj)`                     | Casts to rvalue reference. Enables move instead of copy.              |
| _No equivalent_                 | Move constructor `T(T&&)`            | Steals resources from a temporary/moved object.                       |
| _No equivalent_                 | Move assignment `T& operator=(T&&)`  | Steals resources on assignment from a temporary/moved object.         |
| GC handles everything           | Moved-from object is in valid but unspecified state | You can still destroy or reassign it, but don't read from it. |

### Why Move?

Copying large objects (vectors, strings, buffers) is expensive. Moving transfers ownership of the internal resources (heap memory, file handles) instead of duplicating them.

```
Copy:  src: [data] ──copy──> dst: [data]    (expensive: allocate + memcpy)
Move:  src: [data] ──steal──> dst: [data]    (cheap: just swap pointers)
       src: [null]                            (src is now empty)
```

### Copy vs Move in Action

```cpp
#include <iostream>
#include <string>
#include <vector>

int main() {
    std::vector<int> original = {1, 2, 3, 4, 5};

    // Copy — original is unchanged, new allocation for copy
    std::vector<int> copied = original;
    std::cout << "original size: " << original.size() << std::endl; // 5
    std::cout << "copied size:   " << copied.size() << std::endl;   // 5

    // Move — original's guts are transferred, no allocation
    std::vector<int> moved = std::move(original);
    std::cout << "original size: " << original.size() << std::endl; // 0 (moved-from)
    std::cout << "moved size:    " << moved.size() << std::endl;    // 5

    return 0;
}
```

### `std::move` Does NOT Move

`std::move` is just a cast to `T&&` (rvalue reference). The actual move happens when the move constructor or move assignment operator is called.

```cpp
std::string a = "hello";
std::string b = std::move(a); // 1. std::move casts a to std::string&&
                               // 2. std::string's move constructor is called
                               // 3. b steals a's internal buffer
                               // 4. a is now empty
```

### Writing a Move Constructor

```cpp
#include <algorithm>
#include <cstddef>
#include <iostream>
#include <utility>

class Buffer {
    int* data;
    size_t size;

public:
    Buffer(size_t n) : data(new int[n]), size(n) {
        std::cout << "Constructed " << size << std::endl;
    }

    ~Buffer() {
        delete[] data;
        std::cout << "Destroyed" << std::endl;
    }

    // Copy constructor — expensive
    Buffer(const Buffer& other) : data(new int[other.size]), size(other.size) {
        std::copy(other.data, other.data + size, data);
        std::cout << "Copied " << size << std::endl;
    }

    // Move constructor — cheap
    Buffer(Buffer&& other) noexcept : data(other.data), size(other.size) {
        other.data = nullptr; // leave source in valid state
        other.size = 0;
        std::cout << "Moved " << size << std::endl;
    }

    // Copy assignment
    Buffer& operator=(const Buffer& other) {
        if (this != &other) {
            delete[] data;
            size = other.size;
            data = new int[size];
            std::copy(other.data, other.data + size, data);
        }
        return *this;
    }

    // Move assignment
    Buffer& operator=(Buffer&& other) noexcept {
        if (this != &other) {
            delete[] data;
            data = other.data;
            size = other.size;
            other.data = nullptr;
            other.size = 0;
        }
        return *this;
    }
};

int main() {
    Buffer a(100);            // Constructed 100
    Buffer b = std::move(a);  // Moved 100 (no allocation!)
    Buffer c = b;             // Copied 100 (allocation + memcpy)
    return 0;
}
```

### When Does the Compiler Move Automatically?

```cpp
#include <string>
#include <vector>

std::vector<int> make_vector() {
    std::vector<int> v = {1, 2, 3};
    return v; // NRVO or implicit move — no copy
}

void add_name(std::vector<std::string>& names) {
    std::string name = "Alice";
    names.push_back(std::move(name)); // explicit move into container
}
```

The compiler automatically moves:
- **Return values** (NRVO / copy elision, or implicit move)
- **Temporaries** passed to functions (`push_back(std::string("hello"))`)
- **`std::move`'d** objects explicitly

### Perfect Forwarding

Preserves the value category (lvalue/rvalue) when passing through a template:

```cpp
#include <iostream>
#include <string>
#include <utility>

void process(const std::string& s) { std::cout << "lvalue: " << s << std::endl; }
void process(std::string&& s)      { std::cout << "rvalue: " << s << std::endl; }

template<typename T>
void wrapper(T&& arg) {
    process(std::forward<T>(arg)); // forwards as lvalue or rvalue
}

int main() {
    std::string s = "hello";
    wrapper(s);              // lvalue: hello
    wrapper(std::move(s));   // rvalue: hello
    wrapper(std::string("temp")); // rvalue: temp
    return 0;
}
```

### Common Pitfalls

```cpp
std::string a = "hello";
std::string b = std::move(a);

// DON'T: read from a moved-from object
// std::cout << a << std::endl; // valid but unspecified — could be empty or anything

// DO: reassign is fine
a = "world"; // a is usable again
```

### When to Use What

| Technique              | When to Use                                                        |
| :--------------------- | :----------------------------------------------------------------- |
| `std::move(obj)`       | Transfer ownership. Object won't be used afterward.                |
| Move constructor/assignment | Implement for classes managing raw resources.                 |
| `noexcept` on moves    | Always. Enables `vector` reallocation optimization.                |
| `std::forward<T>(arg)` | In templates to preserve lvalue/rvalue-ness.                       |
| Default (don't move)   | Small types (`int`, `bool`). Cheaper to copy than move.            |
