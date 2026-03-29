## References

| Java Concept                   | C++ Reference Equivalent          | Note                                                                    |
| :----------------------------- | :-------------------------------- | :---------------------------------------------------------------------- |
| **Passing Arguments**          |                                   |                                                                         |
| `void foo(Object obj)`         | `void foo(T obj)`                 | Pass by value. Copies the object.                                       |
| `void foo(Object obj)`         | `void foo(T& obj)`                | Pass by lvalue reference. No copy, can modify original.                 |
| `void foo(final Object obj)`   | `void foo(const T& obj)`          | Pass by const reference. No copy, cannot modify. Default for read-only. |
| _No equivalent_                | `void foo(T&& obj)`               | Pass by rvalue reference. Accepts temporaries and moved-from objects.   |
| **Reference Types**            |                                   |                                                                         |
| _No equivalent_                | `T&` (lvalue reference)           | Alias to an existing object. Cannot be null, cannot be reseated.        |
| _No equivalent_                | `T&&` (rvalue reference)          | Binds to temporaries or `std::move`'d objects.                          |
| _No equivalent_                | `const T&`                        | Binds to both lvalues and rvalues. Extends lifetime of temporaries.     |

### `lvalue` (Locator Value)

An `lvalue` is an expression that points to a specific, identifiable memory location. 
The object it refers to persists beyond the current expression.

- You can take its address using the `&` operator.
- Can typically appear on the left or right side of an assignment

```c++
int x = 10;  // 'x' is an lvalue
x = 20;      // Valid: 'x' is on the left
int* p = &x; // Valid: 'x' has a determinable memory address
```

### `rvalue` (Read Value)

An `rvalue` is a temporary value that does not have a persistent, identifiable memory location. 
It exists only for the duration of the expression being evaluated.

- You cannot take its address using the `&` operator
- Can only appear on the right side of an assignment operator

```cpp
int x = 10;     // '10' is an rvalue
10 = x;         // Invalid: '10' cannot be assigned to
// int* p = &10; // Invalid: Cannot take the address of an rvalue
```

Typically literal constants (e.g. `10`, `'c'`), temporary arithmetic results (e.g. `x + 2`) or functions

### Pass by Value vs Reference

```cpp
#include <iostream>
#include <string>

void by_value(std::string s) {
    s += " (copied)";
    std::cout << s << std::endl;
}

void by_ref(std::string& s) {
    s += " (modified)";
}

void by_const_ref(const std::string& s) {
    std::cout << s << std::endl;
    // s += " nope"; // ERROR: cannot modify const reference
}

int main() {
    std::string text = "hello";

    by_value(text);             // text is unchanged, copy was made
    std::cout << text << std::endl; // "hello"

    by_ref(text);               // text IS modified
    std::cout << text << std::endl; // "hello (modified)"

    by_const_ref(text);         // read-only access, no copy

    return 0;
}
```

### Reference vs Pointer

| Feature              | Reference (`T&`)              | Pointer (`T*`)                  |
| :------------------- | :---------------------------- | :------------------------------ |
| Can be null          | No                            | Yes                             |
| Can be reseated      | No (always refers to same)    | Yes (`ptr = &other`)            |
| Syntax               | `ref.member`                  | `ptr->member`                   |
| Must be initialized  | Yes                           | No                              |
| Use case             | Default for parameter passing | When null or reseating is needed |

### `const T&` Extends Temporary Lifetime

```cpp
#include <string>

std::string make_greeting() {
    return "hello";
}

int main() {
    // const reference extends the lifetime of the temporary
    const std::string& greeting = make_greeting(); // OK
    // std::string& bad = make_greeting();          // ERROR: non-const ref cannot bind to temporary

    return 0;
}
```

### When to Use What

| Parameter Type   | When to Use                                                  |
| :--------------- | :----------------------------------------------------------- |
| `T`              | Small/cheap types (`int`, `bool`). When you need a copy.     |
| `const T&`       | Default for read-only access to large objects.               |
| `T&`             | When the function needs to modify the caller's object.       |
| `T&&`            | Move semantics — accepting ownership of a temporary/moved value. |
