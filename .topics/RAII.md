## RAII (Resource Acquisition Is Initialization)

The core C++ idiom: acquire resources in the constructor, release them in the destructor. When the object goes out of scope, cleanup happens automatically.

| Java Concept                     | C++ RAII Equivalent                        | Note                                                         |
| :------------------------------- | :----------------------------------------- | :----------------------------------------------------------- |
| `try-with-resources`             | Destructor / scope-based cleanup           | C++ does this automatically for all stack objects.            |
| `AutoCloseable.close()`          | Destructor `~T()`                          | Called automatically when object leaves scope.                |
| `finally { resource.close(); }`  | _Not needed_                               | Destructors guarantee cleanup even on exceptions.            |
| Garbage Collector                | _Not needed_                               | RAII + smart pointers handle lifetime deterministically.      |

### Basic RAII — File Handle

```cpp
#include <fstream>
#include <iostream>
#include <string>

void read_file(const std::string& path) {
    std::ifstream file(path); // resource acquired in constructor
    if (!file.is_open()) {
        std::cerr << "Failed to open " << path << std::endl;
        return;
    }

    std::string line;
    while (std::getline(file, line)) {
        std::cout << line << std::endl;
    }
    // file is automatically closed here by ~ifstream()
}
```

### Custom RAII Wrapper

```cpp
#include <iostream>

class DatabaseConnection {
public:
    DatabaseConnection(const std::string& connStr) {
        std::cout << "Connected to " << connStr << std::endl;
        // acquire connection...
    }

    ~DatabaseConnection() {
        std::cout << "Connection closed" << std::endl;
        // release connection...
    }

    void query(const std::string& sql) {
        std::cout << "Executing: " << sql << std::endl;
    }
};

int main() {
    {
        DatabaseConnection db("localhost:5432");
        db.query("SELECT * FROM users");
    } // ~DatabaseConnection() called here — connection closed

    std::cout << "After scope" << std::endl;
    return 0;
}
```

### RAII + Exceptions

```cpp
#include <iostream>
#include <memory>
#include <stdexcept>

void risky_operation() {
    auto resource = std::make_unique<int[]>(1000); // heap allocation via RAII

    // even if this throws, unique_ptr's destructor frees the memory
    throw std::runtime_error("something went wrong");

    // resource is never leaked
}

int main() {
    try {
        risky_operation();
    } catch (const std::exception& e) {
        std::cout << e.what() << std::endl;
    }
    return 0;
}
```

### Lock Guard (Mutex RAII)

```cpp
#include <iostream>
#include <mutex>
#include <thread>

std::mutex mtx;
int counter = 0;

void increment() {
    std::lock_guard<std::mutex> lock(mtx); // locked here
    ++counter;
    // automatically unlocked when lock goes out of scope
}
```

### The Rule of Five

If your class manages a resource, you should define or delete all five special member functions:

```cpp
class Resource {
public:
    Resource();                                  // constructor
    ~Resource();                                 // destructor
    Resource(const Resource& other);             // copy constructor
    Resource& operator=(const Resource& other);  // copy assignment
    Resource(Resource&& other) noexcept;         // move constructor
    Resource& operator=(Resource&& other) noexcept; // move assignment
};
```

If your class does **not** manage a raw resource (uses smart pointers, `std::string`, etc.), you typically need **none** of them — this is the **Rule of Zero**.

### Rule of Zero vs Five

| Rule     | When                                                          | What to Define           |
| :------- | :------------------------------------------------------------ | :----------------------- |
| Rule of Zero | Class only has smart pointers, `std::string`, containers | Nothing. Defaults work.  |
| Rule of Five | Class manages raw resources (`new`, file handles, C APIs) | All five special members |
