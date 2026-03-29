## Pointers

| Java Concept                | C++ Pointer Equivalent                | Note                                                                         |
| :-------------------------- | :------------------------------------ | :--------------------------------------------------------------------------- |
| **Stack vs Heap**           |                                       |                                                                              |
| `new Object()`              | `Object obj;`                         | Stack allocation. Cheap, fast, good locality. Can never be null.             |
| `new Object()`              | `std::make_unique<Object>()`          | Heap allocation via smart pointer. Use when you need polymorphism or "null". |
| **Smart Pointers**          |                                       |                                                                              |
| Single owner reference      | `std::unique_ptr<T>`                  | Exclusive ownership. Automatically deleted when out of scope.                |
| Shared owner reference      | `std::shared_ptr<T>`                  | Reference-counted. Deleted when the last owner goes out of scope.            |
| Weak/non-owning reference   | `std::weak_ptr<T>`                    | Non-owning observer of a `shared_ptr`. Does not prevent destruction.         |
| **Operations**              |                                       |                                                                              |
| `obj.method()`              | `ptr->method()`                       | Arrow operator dereferences and accesses member.                             |
| Assignment                  | `std::move(ptr)`                      | Transfers ownership of a `unique_ptr`. Source becomes `nullptr`.             |
| Assignment                  | `auto copy = sharedPtr;`              | Copies a `shared_ptr`, incrementing the reference count.                     |
| Clone                       | `std::make_unique<T>(*ptr)`           | Deep copy by dereferencing and copy-constructing into a new `unique_ptr`.    |
| Null check                  | `if (ptr)`                            | Smart pointers are contextually convertible to `bool`.                       |
| Equality                    | `ptr1 == ptr2`                        | Compares the underlying raw pointer addresses.                               |

### `std::unique_ptr`

Exclusive ownership. Only one `unique_ptr` can own the object at a time.

```cpp
#include <iostream>
#include <memory>

int main() {
    auto ptr = std::make_unique<Greeter>("Smart");
    ptr->greet();

    // Clone by copy-constructing a new object
    auto clone = std::make_unique<Greeter>(*ptr);
    clone->greet();

    // Transfer ownership
    auto newOwner = std::move(clone);
    std::cout << clone << std::endl;    // 0 (nullptr)
    std::cout << newOwner << std::endl; // valid address

    return 0;
}
```

#### Use Cases

1. **Polymorphism** — store different subtypes in a container:

```cpp
std::vector<std::unique_ptr<Shape>> shapes;
shapes.push_back(std::make_unique<Circle>());
shapes.push_back(std::make_unique<Square>());
```

2. **Nullable objects** — when you need to represent "no value":

```cpp
std::unique_ptr<Config> config;
if (needsConfig) {
    config = std::make_unique<Config>(loadConfig());
}
```

### `std::shared_ptr`

Reference-counted shared ownership. The object is destroyed when the last `shared_ptr` to it is destroyed.

```cpp
#include <iostream>
#include <memory>

int main() {
    auto shared = std::make_shared<Greeter>("Shared");
    auto ref = shared; // ref count is now 2

    if (ref == shared) {
        printf("Pointers are equal\n");
    }

    std::cout << shared.use_count() << std::endl; // 2

    return 0;
}
```

### `std::weak_ptr`

Non-owning reference to an object managed by `std::shared_ptr`. Used to break circular references and to observe without extending lifetime.

```cpp
#include <iostream>
#include <memory>

int main() {
    std::weak_ptr<Greeter> weak;

    {
        auto shared = std::make_shared<Greeter>("Weak");
        weak = shared; // does NOT increase ref count

        if (auto locked = weak.lock()) { // promotes to shared_ptr
            locked->greet(); // safe to use
        }
    } // shared is destroyed here

    if (weak.expired()) {
        std::cout << "Object has been destroyed" << std::endl;
    }

    return 0;
}
```

#### Use Case — Breaking Circular References

```cpp
struct Node {
    std::shared_ptr<Node> next;
    std::weak_ptr<Node> prev; // weak to avoid circular reference / memory leak
};
```

### When to Use What

| Pointer Type          | When to Use                                                        |
| :-------------------- | :----------------------------------------------------------------- |
| Stack object          | Default choice. Fast, simple, no null checks.                      |
| `std::unique_ptr<T>`  | Heap allocation with single owner. Polymorphism or nullable value. |
| `std::shared_ptr<T>`  | Multiple owners need to share the same object.                     |
| `std::weak_ptr<T>`    | Observing a `shared_ptr` without preventing destruction.           |
