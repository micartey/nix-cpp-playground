## Containers

| Java Collection              | C++ Equivalent                        | Note                                                                |
| :--------------------------- | :------------------------------------ | :------------------------------------------------------------------ |
| **Sequences**                |                                       |                                                                     |
| `ArrayList<T>`               | `std::vector<T>`                      | Dynamic array. Default choice.                                      |
| `LinkedList<T>`              | `std::list<T>`                        | Doubly-linked list. Rarely needed — `vector` is faster in practice. |
| `ArrayDeque<T>`              | `std::deque<T>`                       | Double-ended queue. Efficient push/pop at both ends.                |
| `int[]` / fixed-size array   | `std::array<T, N>`                    | Fixed-size, stack-allocated. Size known at compile time.            |
| **Associative**              |                                       |                                                                     |
| `HashMap<K, V>`              | `std::unordered_map<K, V>`            | Hash map. O(1) average lookup.                                      |
| `TreeMap<K, V>`              | `std::map<K, V>`                      | Red-black tree. O(log n) lookup. Keys are sorted.                   |
| `HashSet<T>`                 | `std::unordered_set<T>`               | Hash set. O(1) average lookup.                                      |
| `TreeSet<T>`                 | `std::set<T>`                         | Red-black tree. O(log n) lookup. Elements are sorted.               |
| **Adapters**                 |                                       |                                                                     |
| `Stack<T>`                   | `std::stack<T>`                       | LIFO adapter over `deque` by default.                               |
| `Queue<T>`                   | `std::queue<T>`                       | FIFO adapter over `deque` by default.                               |
| `PriorityQueue<T>`           | `std::priority_queue<T>`              | Max-heap by default. Use custom comparator for min-heap.            |

### `std::vector` — The Default Container

```cpp
#include <iostream>
#include <vector>

int main() {
    std::vector<int> nums = {1, 2, 3, 4, 5};

    nums.push_back(6);
    nums.emplace_back(7); // constructs in-place, avoids copy

    for (const auto& n : nums) {
        std::cout << n << " ";
    }
    std::cout << std::endl;

    std::cout << nums.size() << std::endl;     // 7
    std::cout << nums[0] << std::endl;         // 1 (unchecked)
    std::cout << nums.at(0) << std::endl;      // 1 (bounds-checked, throws)

    return 0;
}
```

### `std::array` — Fixed-Size Array

```cpp
#include <array>
#include <iostream>

int main() {
    std::array<int, 4> arr = {10, 20, 30, 40};

    for (const auto& n : arr) {
        std::cout << n << " ";
    }
    std::cout << std::endl;

    std::cout << arr.size() << std::endl; // 4 (compile-time constant)
    return 0;
}
```

### `std::unordered_map` — Hash Map

```cpp
#include <iostream>
#include <string>
#include <unordered_map>

int main() {
    std::unordered_map<std::string, int> ages = {
        {"Alice", 30},
        {"Bob", 25}
    };

    ages["Charlie"] = 35;
    ages.insert({"Diana", 28});

    // Lookup
    if (auto it = ages.find("Alice"); it != ages.end()) {
        std::cout << it->first << ": " << it->second << std::endl;
    }

    // Iterate
    for (const auto& [name, age] : ages) { // structured bindings (C++17)
        std::cout << name << " is " << age << std::endl;
    }

    return 0;
}
```

### `std::map` — Sorted Map

```cpp
#include <iostream>
#include <map>
#include <string>

int main() {
    std::map<std::string, int> scores = {{"Charlie", 90}, {"Alice", 85}, {"Bob", 92}};

    for (const auto& [name, score] : scores) {
        std::cout << name << ": " << score << std::endl;
        // Output is sorted by key: Alice, Bob, Charlie
    }

    return 0;
}
```

### `std::set` and `std::unordered_set`

```cpp
#include <iostream>
#include <set>
#include <unordered_set>

int main() {
    std::set<int> sorted = {3, 1, 4, 1, 5}; // duplicates removed, sorted
    for (int n : sorted) std::cout << n << " "; // 1 3 4 5
    std::cout << std::endl;

    std::unordered_set<int> hashed = {3, 1, 4, 1, 5}; // duplicates removed, unordered
    std::cout << hashed.contains(4) << std::endl; // 1 (true), C++20

    return 0;
}
```

### `std::stack`, `std::queue`, `std::priority_queue`

```cpp
#include <iostream>
#include <queue>
#include <stack>

int main() {
    std::stack<int> s;
    s.push(1); s.push(2); s.push(3);
    std::cout << s.top() << std::endl; // 3 (LIFO)

    std::queue<int> q;
    q.push(1); q.push(2); q.push(3);
    std::cout << q.front() << std::endl; // 1 (FIFO)

    // Min-heap (default is max-heap)
    std::priority_queue<int, std::vector<int>, std::greater<int>> pq;
    pq.push(30); pq.push(10); pq.push(20);
    std::cout << pq.top() << std::endl; // 10

    return 0;
}
```

### When to Use What

| Container               | When to Use                                                     |
| :----------------------- | :-------------------------------------------------------------- |
| `std::vector`            | Default. Fast iteration, cache-friendly, dynamic size.          |
| `std::array`             | Fixed size known at compile time. Stack-allocated.              |
| `std::unordered_map/set` | Fast lookup by key/value. Order doesn't matter.                 |
| `std::map/set`           | Need sorted keys/elements or ordered iteration.                 |
| `std::deque`             | Frequent push/pop at both front and back.                       |
| `std::list`              | Frequent insertion/removal in the middle (rare in practice).    |
| `std::stack/queue`       | When you need strict LIFO/FIFO semantics.                       |
| `std::priority_queue`    | Processing elements by priority.                                |
