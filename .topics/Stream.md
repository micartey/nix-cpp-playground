## Stream

| Java Stream API             | C++ Ranges/Views Equivalent                         | Note                                                                        |
| :-------------------------- | :-------------------------------------------------- | :-------------------------------------------------------------------------- |
| **Intermediate Operations** |                                                     |                                                                             |
| `.filter(pred)`             | `std::views::filter(pred)`                          |                                                                             |
| `.map(mapper)`              | `std::views::transform(mapper)`                     |                                                                             |
| `.flatMap(mapper)`          | `std::views::transform(mapper) \| std::views::join` | Evaluates nested ranges.                                                    |
| `.limit(n)`                 | `std::views::take(n)`                               |                                                                             |
| `.skip(n)`                  | `std::views::drop(n)`                               |                                                                             |
| `.takeWhile(pred)`          | `std::views::take_while(pred)`                      |                                                                             |
| `.dropWhile(pred)`          | `std::views::drop_while(pred)`                      |                                                                             |
| `.distinct()`               | _None_                                              | Views are stateless. Use `std::set` or `std::ranges::unique` after sorting. |
| `.sorted()`                 | _None_                                              | Sorting requires evaluating the entire range. Use `std::ranges::sort`.      |
| `.peek(action)`             | _None_                                              | C++ discourages side-effects in views.                                      |
| **Terminal Operations**     |                                                     |                                                                             |
| `.collect(toList())`        | `std::ranges::to<std::vector>()`                    | Requires C++23.                                                             |
| `.forEach(action)`          | Range-based `for` loop                              | Or `std::ranges::for_each()`.                                               |
| `.reduce(id, acc)`          | `std::ranges::fold_left(id, acc)`                   | Requires C++23. C++20 uses `std::accumulate`.                               |
| `.anyMatch(pred)`           | `std::ranges::any_of(pred)`                         | Algorithm.                                                                  |
| `.allMatch(pred)`           | `std::ranges::all_of(pred)`                         | Algorithm.                                                                  |
| `.noneMatch(pred)`          | `std::ranges::none_of(pred)`                        | Algorithm.                                                                  |
| `.count()`                  | `std::ranges::distance()`                           | Algorithm.                                                                  |
| `.findFirst()`              | `*std::ranges::begin(view)`                         | Access the first element of the lazy view.                                  |

### Examples

#### Filter, Map, Limit, and Collect

```cpp
#include <iostream>
#include <vector>
#include <ranges>

int main() {
    std::vector<int> numbers = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10};

    // Java: numbers.stream().filter(n -> n % 2 != 0).map(n -> n * 10).limit(3).toList();
    auto result_view = numbers 
        | std::views::filter([](int n) { return n % 2 != 0; }) 
        | std::views::transform([](int n) { return n * 10; }) 
        | std::views::take(3);

    // Terminal iteration
    for (int n : result_view) {
        std::cout << n << " "; // Output: 10 30 50
    }

    // Terminal collection (C++23)
    // auto result_vec = result_view | std::ranges::to<std::vector>();

    return 0;
}
```

#### FlatMap (Transform and Join)

```cpp
#include <iostream>
#include <vector>
#include <string>
#include <ranges>

int main() {
    std::vector<std::string> words = {"hello", "world"};

    // Java: words.stream().flatMap(w -> w.chars().mapToObj(c -> (char)c)).toList();
    auto chars = words 
        | std::views::transform([](const std::string& s) { return s; }) // acts as map to characters 
        | std::views::join; // flattens the view of strings into a view of chars

    for (char c : chars) {
        std::cout << c << " "; // Output: h e l l o w o r l d 
    }

    return 0;
}
```

#### Terminal Matchers and Reductions

```cpp
#include <iostream>
#include <vector>
#include <ranges>
#include <algorithm>

int main() {
    std::vector<int> numbers = {5, 10, 15, 20};

    // Java: numbers.stream().anyMatch(n -> n > 10);
    bool has_greater = std::ranges::any_of(numbers, [](int n) { return n > 10; });

    // C++23 Fold Left (Java: reduce)
    // auto sum = std::ranges::fold_left(numbers, 0, std::plus<int>());
    
    // C++20 fallback for reduce
    int sum = 0;
    for (int n : numbers) sum += n; 

    return 0;
}
```
