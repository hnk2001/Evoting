# EVoting System - Frontend

This repository contains the **Flutter-based frontend** of the eVoting system. The application aims to simplify the voting process for people who have migrated or are away from their hometown during elections, making it accessible through their mobile devices.

## Features

- **User Authentication**: Secure login using JWT tokens.
- **Voting Process**: Allows users to view candidates and cast their vote.
- **Live Results**: Users can see live election results once the voting is complete.
- **Profile Management**: Users can manage their profiles and update their details.
- **Responsive Design**: The application is designed to work on multiple screen sizes.

## Tech Stack

- **Flutter**: For building cross-platform mobile apps.
- **Dart**: The programming language used for Flutter development.
- **HTTP**: For communicating with the backend server.
- **JWT Authentication**: To handle user login securely.
- **Provider**: For state management across the app.

## Installation

Follow these steps to set up and run the frontend on your local machine.

1. **Clone the repository:**

   ```bash
   git clone https://github.com/hnk2001/Evoting.git
   cd Evoting - main

2. **Install dependencies:**

Ensure you have Flutter installed. Then run:

   ```shell
   flutter pub get
   ```
3. **Run the application:**

After installing dependencies, start the app using:

  ```bash
  flutter run
  ```
This will launch the app on your connected device or emulator

### Folder Structure

  lib/: Contains the main Dart code for the application.
  - models/: Defines data models for user information and voting data.
  - screens/: Contains all the UI screens like login, vote, and result screens.
  - services/: Responsible for making HTTP requests to the backend.
  - providers/: Handles state management using the Provider package.
  - widgets/: Custom reusable widgets used across the app.

### API Integration

  The frontend communicates with the backend via REST APIs. Here are the key endpoints used:
  - User Authentication: /api/auth/login (POST)
  - Get Voting List: /api/votes (GET)
  - Cast Vote: /api/votes/cast (POST)
  - View Results: /api/votes/results (GET)
  Make sure to configure the API Base URL in the app's configuration:
  ```bash
  const String baseUrl = "http://your-backend-server.com/api";
  ```

### Contact
For any queries or support, please contact:

  - Harshal Kotkar
    - Email: harshalkotkar1409@gmail.com
      
### License
This project is licensed under the MIT License - see the LICENSE file for details.

This README file is structured to provide clear instructions on setting up, running, and testing your Spring Boot project. If you need any additional sections or modifications, feel free to ask!
