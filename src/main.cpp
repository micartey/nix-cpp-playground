#include "Greeter.hpp"
#include <algorithm>
#include <cstdio>
#include <execution>
#include <format>
#include <iostream>
#include <memory>
#include <pistache/endpoint.h>
#include <pistache/http.h>
#include <ranges>
#include <string>
#include <vector>

using namespace Pistache;

struct HelloHandler : public Http::Handler {
  HTTP_PROTOTYPE(HelloHandler)

  void onRequest(const Http::Request &,
                 Http::ResponseWriter response) override {
    response.send(Http::Code::Ok, "Hello from Pistache webserver!\n");
  }
};

std::string vec_to_string(const std::vector<int> &v) {
  std::string s;
  for (size_t i = 0; i < v.size(); ++i)
    std::format_to(std::back_inserter(s), "{}{}", v[i],
                   i == v.size() - 1 ? "" : ", ");
  return s;
}

int main() {

  std::vector<int> numbers = {5, 2, 3, 1};

  for (int num : numbers) {
    std::cout << num << std::endl;
  }

  // "Crush with all CPU Cores"
  std::for_each(std::execution::par_unseq, numbers.begin(), numbers.end(),
                [](auto &num) { num += 1; });

  // Stream API...
  auto even =
      numbers | std::views::filter([](const auto &p) { return p % 2 == 0; });

  // Lambda is only executed here when called
  std::vector<int> even_nums(even.begin(), even.end());
  std::cout << vec_to_string(even_nums) << std::endl;

  Greeter greeter("Hello");
  greeter.greet();

  // This is a smart pointer
  auto smartGreet = std::make_unique<Greeter>("Smart");
  smartGreet->greet();

  // Webserver with dependency
  Address addr(Ipv4::any(), Port(9080));
  auto opts = Http::Endpoint::options().threads(1);
  Http::Endpoint server(addr);
  server.init(opts);
  server.setHandler(Http::make_handler<HelloHandler>());
  std::cout << "Server listening on http://localhost:9080" << std::endl;
  server.serve();
}
