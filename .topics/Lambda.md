## Lambda

The basic structure consists of three main parts:

`[captures](parameters) -> return_type { body }`

The -> return_type is usually omitted because the compiler deduces it automatically.

### Basic Lambda (No captures, with parameters)

```cpp
auto add = [](int a, int b) { 
    return a + b; 
};

int sum = add(5, 3); // sum is 8
```

### Capturing Local Variables

The capture list `[]` defines what variables from the surrounding scope the lambda can access.
By default it cannot access any of these surrounding local variables.

An exemption are `static`, `constexpr` and global variables.

```cpp
int multiplier = 10;
int counter = 0;

// Capture 'multiplier' by value (read-only copy)
auto multiply = [multiplier](int a) { 
    return a * multiplier; 
};

// Capture 'counter' by reference (can modify the original variable)
auto increment = [&counter]() { 
    counter++; 
};
```

Common Capture Modes:

- `[]` Capture nothing
- `[x, &y]` Capture `x` by value, `y` by reference
- `[=]` Capture all used local variables by value
- `[&]` Capture all used local variables by reference

#### Usage in Views/Algorithms

Lambdas are passed directly into functions like `std::ranges::filter`

```cpp
std::vector<int> numbers = {1, 2, 3, 4, 5};
int threshold = 3;

// Lambda passed directly, capturing 'threshold' by value
auto filtered = numbers | std::views::filter([threshold](int n) {
    return n > threshold;
});
```
