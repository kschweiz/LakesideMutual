#
# This is a docker-compose file to build and start all Lakeside Mutual
# applications in a single command. Note that the applications will all
# run in production mode, so there won't be any live-reloading of changes
# or other development features. For development, we recommend to start
# the applications invidually or use the run_all_applications scripts.
#
# To build the Docker images:
#   docker-compose build
#
# To run the applications:
#   docker-compose up
#
# To shut down the applications, simply terminate the previous command.
#
version: "3"
services:
  customer-core:
    build: customer-core
    image: lakesidemutual/customer-core
    environment:
      - "SPRING_BOOT_ADMIN_CLIENT_URL=http://spring-boot-admin:9000"
    ports:
      - "8110:8110"
  customer-management-backend:
    build: customer-management-backend
    image: lakesidemutual/customer-management-backend
    depends_on:
      - customer-core
    environment:
      - "CUSTOMERCORE_BASEURL=http://customer-core:8110"
      - "SPRING_BOOT_ADMIN_CLIENT_URL=http://spring-boot-admin:9000"
    ports:
      - "8100:8100"
  customer-management-frontend:
    build: customer-management-frontend
    image: lakesidemutual/customer-management-frontend
    depends_on:
      - customer-management-backend
    environment:
      - "REACT_APP_CUSTOMER_MANAGEMENT_BACKEND=http://customer-management-backend:8100"
    ports:
      - "3020:80"
  customer-self-service-backend:
    build: customer-self-service-backend
    image: lakesidemutual/customer-self-service-backend
    depends_on:
      - customer-core
      - policy-management-backend
    environment:
      - "CUSTOMERCORE_BASEURL=http://customer-core:8110"
      - "POLICYMANAGEMENT_TCPBROKERBINDADDRESS=tcp://policy-management-backend:61616"
      - "SPRING_BOOT_ADMIN_CLIENT_URL=http://spring-boot-admin:9000"
    ports:
      - "8080:8080"
  customer-self-service-frontend:
    build: customer-self-service-frontend
    image: lakesidemutual/customer-self-service-frontend
    depends_on:
      - customer-self-service-backend
      - customer-management-backend
      - policy-management-backend
    environment:
      - "REACT_APP_CUSTOMER_SELF_SERVICE_BACKEND=http://customer-self-service-backend:8080"
      - "REACT_APP_POLICY_MANAGEMENT_BACKEND=http://policy-management-backend:8090"
      - "REACT_APP_CUSTOMER_MANAGEMENT_BACKEND=http://customer-management-backend:8100"
    ports:
      - "3000:80"
  policy-management-backend:
    build: policy-management-backend
    image: lakesidemutual/policy-management-backend
    depends_on:
      - customer-core
    environment:
      - "CUSTOMERCORE_BASEURL=http://customer-core:8110"
      - "SPRING_BOOT_ADMIN_CLIENT_URL=http://spring-boot-admin:9000"
    ports:
      - "8090:8090"
      - "61613:61613"
      - "61616:61616"
  policy-management-frontend:
    build: policy-management-frontend
    image: lakesidemutual/policy-management-frontend
    depends_on:
      - policy-management-backend
    environment:
      - "VUE_APP_POLICY_MANAGEMENT_BACKEND=http://policy-management-backend:8090"
    ports:
      - "3010:80"
  spring-boot-admin:
    build: spring-boot-admin
    image: lakesidemutual/spring-boot-admin
    ports:
      - "9000:9000"
  risk-management-server:
    build: risk-management-server
    image: lakesidemutual/risk-management-server
    depends_on:
      - policy-management-backend
    environment:
      - "ACTIVEMQ_HOST=policy-management-backend"
      - "ACTIVEMQ_PORT=61613"
    ports:
      - "50051:50051"
