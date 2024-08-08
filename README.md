# Evoting System

This project aims to solve the eVoting system problem in Indian democracy, allowing migrants and educational students to vote online. The project is built using Spring Boot.

## Getting Started

Follow these instructions to set up and run the project on your local machine.

### Prerequisites

Ensure you have the following installed on your machine:

- Java 8 or higher
- Maven
- MySQL
- Git

### Installation

1. **Clone the repository:**
   ```shell
   git clone https://github.com/yourusername/evoting-system.git
   ```
   
Navigate to the project directory:
  ```shell
  cd evoting-system
  ```

2. **Configure the database:**

 - Update the MySQL password in the src/main/resources/application.properties file:
  properties
  ```shell
    spring.datasource.url=jdbc:mysql://localhost:3306/your-database-name                                                          
    spring.datasource.username=your-username                                                       
    spring.datasource.password=your-new-password
  ```

3. **Install dependencies:**

 - Use Maven to install the project dependencies:
  ```shell                                       
    mvn clean install
  ```
4. **Run the application:**

  - Start the Spring Boot application by running the **`VotingApplication.java`** file:
    ```shell
    mvn spring-boot:run
    ```
  - The application should now be running on http://localhost:8080.

### Testing
To test the APIs, you can use Postman. After signing in, JWT authentication is required for all admin operations. The token will be generated after a successful sign-in POST request.

### Contributing
Contributions are welcome! Please fork this repository and submit a pull request.

### License
Distributed under the MIT License. See LICENSE for more information.

### Contact
For more information or support, contact Harshal Kotkar.

This README file is structured to provide clear instructions on setting up, running, and testing your Spring Boot project. If you need any additional sections or modifications, feel free to ask!





