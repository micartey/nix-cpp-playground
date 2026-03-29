#include "Greeter.hpp"
#include "Person.hpp"
#include <algorithm>
#include <cstdio>
#include <execution>
#include <format>
#include <iostream>
#include <memory>
#include <ostream>
#include <pistache/endpoint.h>
#include <pistache/http.h>
#include <ranges>
#include <sqlite_orm/sqlite_orm.h>
#include <string>
#include <vector>

using namespace Pistache;
using namespace sqlite_orm;

struct HelloHandler : public Http::Handler {
  HTTP_PROTOTYPE(HelloHandler)

  void onRequest(const Http::Request &request,
                 Http::ResponseWriter response) override {
    std::cout << request.address() << std::endl;
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

int increase(int &num) { return num += 1; }

auto create_storage(const std::string &path) {
  return make_storage(
      path,
      make_table("persons",
                 make_column("id", &Person::id, primary_key().autoincrement()),
                 make_column("first_name", &Person::first_name),
                 make_column("last_name", &Person::last_name),
                 make_column("age", &Person::age)));
}

using Storage = decltype(create_storage(""));

void demo_database() {
  std::cout << "\n=== Database Demo (sqlite_orm) ===" << std::endl;

  auto storage = create_storage("helloworld.sqlite");
  storage.sync_schema();
  std::cout << "Schema synced." << std::endl;

  auto alice_id = storage.insert(
      Person{.first_name = "Alice", .last_name = "Smith", .age = 30});

  auto bob_id = storage.insert(
      Person{.first_name = "Bob", .last_name = "Jones", .age = 25});

  std::cout << std::format("Inserted Alice (id={}) and Bob (id={})", alice_id,
                           bob_id)
            << std::endl;

  auto alice = storage.get<Person>(alice_id);
  std::cout << std::format("Found: {} {} (age {})", alice.first_name,
                           alice.last_name, alice.age)
            << std::endl;

  auto all = storage.get_all<Person>();
  std::cout << std::format("Total persons: {}", all.size()) << std::endl;

  for (const auto &p : all) {
      // p.first_name ...
  }

  alice.age = 31;
  storage.update(alice);

  auto updated = storage.get<Person>(alice_id);
  std::cout << std::format("Updated Alice's age to {}", updated.age)
            << std::endl;

  auto young = storage.get_all<Person>(where(less_than(&Person::age, 30)));
  std::cout << std::format("Persons younger than 30: {}", young.size())
            << std::endl;

  auto names =
      storage.select(&Person::first_name, order_by(&Person::age).desc());

  std::cout << "Names by age (desc): ";
  for (const auto &name : names) {
    std::cout << name << " ";
  }
  std::cout << std::endl;

  storage.remove<Person>(bob_id);
  std::cout << "Deleted Bob." << std::endl;

  auto count = storage.count<Person>();
  std::cout << std::format("Remaining persons: {}", count) << std::endl;

  storage.remove_all<Person>();
  std::cout << "Cleaned up all persons." << std::endl;

  std::cout << "=== Database Demo Done ===\n" << std::endl;
}

int main() {

  std::vector<int> numbers = {5, 2, 3, 1};

  for (int num : numbers) {
    std::cout << num << std::endl;
  }

  std::for_each(std::execution::par_unseq, numbers.begin(), numbers.end(),
                increase);

  auto even =
      numbers | std::views::filter([](const auto &p) { return p % 2 == 0; });

  std::vector<int> even_nums(even.begin(), even.end());
  std::cout << vec_to_string(even_nums) << std::endl;

  Greeter greeter("Hello");
  greeter.greet();

  auto smartGreet = std::make_unique<Greeter>("Smart");
  smartGreet->greet();

  auto cloneGreeter = std::make_unique<Greeter>(*smartGreet);
  cloneGreeter->greet();

  auto newCloneGreeterOwner = std::move(cloneGreeter);
  std::cout << cloneGreeter << std::endl;
  std::cout << newCloneGreeterOwner << std::endl;

  auto sharedGreeter = std::make_shared<Greeter>(*smartGreet);
  auto newSharedGreeterRef = sharedGreeter;
  if (newSharedGreeterRef == sharedGreeter) {
    printf("Pointers are equal\n");
  }

  demo_database();

  Address addr(Ipv4::any(), Port(9080));
  auto opts = Http::Endpoint::options().threads(1);
  Http::Endpoint server(addr);
  server.init(opts);
  server.setHandler(Http::make_handler<HelloHandler>());
  std::cout << "Server listening on http://localhost:9080" << std::endl;
  printf("Server listening on http://localhost:9080");
  server.serve();
}
