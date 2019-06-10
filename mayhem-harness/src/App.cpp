//
//  main.cpp
//  web-starter-project
//
//  Created by Leonid on 2/12/18.
//  Copyright © 2018 oatpp. All rights reserved.
//

#include "./controller/MyController.hpp"
#include "./AppComponent.hpp"

#include "oatpp/network/server/Server.hpp"

#include "oatpp/core/macro/codegen.hpp"

#include "oatpp/web/client/ApiClient.hpp"
#include "oatpp/web/client/HttpRequestExecutor.hpp"

#include <iostream>
#include <thread>
#include <chrono>

/* Begin Api Client code generation */
#include OATPP_CODEGEN_BEGIN(ApiClient)

class MyApiClient : public oatpp::web::client::ApiClient {
  API_CLIENT_INIT(MyApiClient)
  API_CALL("GET", "/hello", getHello)
};

/* Begin Api Client code generation */
#include OATPP_CODEGEN_END(ApiClient)

// The amount of time to keep the server up and running
const long SERVER_TIME_LIMIT_MILLIS = 5000;

void run() {

  /* Register Components in scope of run() method */
  AppComponent components;

  /* Get router component */
  OATPP_COMPONENT(std::shared_ptr<oatpp::web::server::HttpRouter>, router);
  OATPP_COMPONENT(std::shared_ptr<oatpp::network::ClientConnectionProvider>, clientConnectionProvider);
  OATPP_COMPONENT(std::shared_ptr<oatpp::data::mapping::ObjectMapper>, objectMapper);
  auto requestExecutor = oatpp::web::client::HttpRequestExecutor::createShared(clientConnectionProvider);
  auto client = MyApiClient::createShared(requestExecutor, objectMapper);

  /* Create MyController and add all of its endpoints to router */
  auto myController = std::make_shared<MyController>();
  myController->addEndpointsToRouter(router);

  /* Create server which takes provided TCP connections and passes them to HTTP connection handler */
  oatpp::network::server::Server server(components.serverConnectionProvider.getObject(),
                                        components.serverConnectionHandler.getObject());


  std::thread run_server([&server, &components](){
    OATPP_LOGD("Server", "Running on port %s...", components.serverConnectionProvider.getObject()->getProperty("port").toString()->c_str());
    server.run();
  });

  std::thread stop_server([&server, &components](){
    std::this_thread::sleep_for(std::chrono::milliseconds(SERVER_TIME_LIMIT_MILLIS));
    std::cout << "Stopping server..." << std::endl;

    server.stop();
    components.serverConnectionHandler.getObject()->stop();
    components.serverConnectionProvider.getObject()->close();
  });

  // Wait for the server stop thread to finish
  stop_server.join();

  // This doesn't seem to be needed ton MacOS, but when built in linux something needs
  // to trigger the server to let go of the connection and shut down. There is a likely
  // a better way tot do this, but this does work.
  client->getHello();

  // Join the thread that ran the server before finishing.
  run_server.join();
}

int main(int argc, const char * argv[]) {

  oatpp::base::Environment::init();

  run();

  /* Print how much objects were created during app running, and what have left-probably leaked */
  /* Disable object counting for release builds using '-D OATPP_DISABLE_ENV_OBJECT_COUNTERS' flag for better performance */
  std::cout << "\nEnvironment:\n";
  std::cout << "objectsCount = " << oatpp::base::Environment::getObjectsCount() << "\n";
  std::cout << "objectsCreated = " << oatpp::base::Environment::getObjectsCreated() << "\n\n";

  oatpp::base::Environment::destroy();

  return 0;
}
