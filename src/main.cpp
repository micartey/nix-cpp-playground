#include "Greeter.hpp"
#include <algorithm>
#include <cstdio>
#include <execution>
#include <format>
#include <functional>
#include <iostream>
#include <memory>
#include <ostream>
#include <pistache/endpoint.h>
#include <pistache/http.h>
#include <ranges>
#include <string>
#include <vector>

using namespace Pistache;

struct HelloHandler : public Http::Handler {
  HTTP_PROTOTYPE(HelloHandler)

  void onRequest(const Http::Request &request,
                 Http::ResponseWriter response) override {
    std::cout << request.address() << std::endl;
    response.send(Http::Code::Ok, "Hello from Pistache webserver!\n");
  }

  // void onConnection(const std::shared_ptr<Tcp::Peer> &peer) override {
  //     std::cout << "New connection from" << peer->address() << std::endl;
  //     Http::Handler::onConnection(peer);
  // }
};

std::string vec_to_string(const std::vector<int> &v) {
  std::string s;
  for (size_t i = 0; i < v.size(); ++i)
    std::format_to(std::back_inserter(s), "{}{}", v[i],
                   i == v.size() - 1 ? "" : ", ");
  return s;
}

int increase(int &num) { return num += 1; }

int main() {

  std::vector<int> numbers = {5, 2, 3, 1};

  for (int num : numbers) {
    std::cout << num << std::endl;
  }

  // "Crush with all CPU Cores"
  // Anonym function: [](auto int &number) { return number; }
  std::for_each(std::execution::par_unseq, numbers.begin(), numbers.end(),
                increase);

  // Stream API...
  auto even =
      numbers | std::views::filter([](const auto &p) { return p % 2 == 0; });

  // Lambda is only executed here when called
  std::vector<int> even_nums(even.begin(), even.end());
  std::cout << vec_to_string(even_nums) << std::endl;

  // Create object on stack
  // Stack is cheap fast and sits next to each other in memory (locality) which is good for CPU
  // Can also be never null and thus no null checks needed
  Greeter greeter("Hello");
  greeter.greet();

  // This is a smart pointer
  // A pointer that automatically cleans itself once not needed anymore
  // Create object on heap
  //
  // 1. Use for polymorphism e.g. vector of shapes (Circle and Square):
  //
  //    std::vector<std::unique_ptr<Shape>> shapes;
  //    shapes.push_back(std::make_unique<Circle>());
  //    shapes.push_back(std::make_unique<Square>());
  //
  // 2. Use when you need "null"
  auto smartGreet = std::make_unique<Greeter>("Smart");
  smartGreet->greet();

  // Clone an object
  auto cloneGreeter = std::make_unique<Greeter>(*smartGreet);
  cloneGreeter->greet();

  auto newCloneGreeterOwner = std::move(cloneGreeter); // Needs move call
  std::cout << cloneGreeter << std::endl;              // Is "0" / Doesn't point anymore
  std::cout << newCloneGreeterOwner << std::endl;

  // Shared pointers
  // Used when an object needs to be hold by many owners
  auto sharedGreeter = std::make_shared<Greeter>(*smartGreet);
  auto newSharedGreeterRef = sharedGreeter; // This works because it is a shared pointer
  if (newSharedGreeterRef == sharedGreeter) {
      printf("Pointers are equal\n");
  }

  // Webserver with dependency
  Address addr(Ipv4::any(), Port(9080));
  auto opts = Http::Endpoint::options().threads(1);
  Http::Endpoint server(addr);
  server.init(opts);
  server.setHandler(Http::make_handler<HelloHandler>());
  std::cout << "Server listening on http://localhost:9080" << std::endl;
  printf("Server listening on http://localhost:9080");
  server.serve();
}
