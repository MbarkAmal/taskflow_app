# TaskFlow Architecture Overview

This document explains the technical structure, folder organization, and data workflow of the TaskFlow application.

## 🏗️ Architecture Design
TaskFlow follows a **Modular Clean Architecture** pattern using the **Provider** package for state management. This separation of concerns ensures that the UI is independent of the business logic and data sources.

---

## 📁 Folder Structure

### `lib/models/`
- **Objective**: Contains plain Dart classes (POJOs) that represent the data entities.
- **Key Files**: `task_models.dart`.
- **Purpose**: Defines how data is structured (e.g., `TaskModel`, `ProjectModel`). Includes `toMap()` and `fromMap()` methods for Firebase serialization.

### `lib/services/`
- **Objective**: The "Data Layer". Handles direct communication with external services.
- **Key Files**: `auth_service.dart`, `task_service.dart`.
- **Purpose**: Encapsulates Firebase Authentication and Cloud Firestore logic. No state is stored here; it only performs CRUD operations and returns streams/futures.

### `lib/providers/`
- **Objective**: The "Logic/State Layer". Acts as a bridge between Services and Screens.
- **Key Files**: `auth_provider.dart`, `task_provider.dart`.
- **Purpose**: Manages the application state. It calls services to fetch data, processes it, and notifies the UI to rebuild when data changes using `notifyListeners()`.

### `lib/screens/`
- **Objective**: The "Presentation Layer". Contains all UI components.
- **Key Files**: `dashboard_screen.dart`, `login_screen.dart`, `task_list_screen.dart`, etc.
- **Purpose**: Displays data to the user and captures user input. It listens to Providers to update its state.

### `lib/theme.dart`
- **Objective**: Global Styling.
- **Purpose**: Defines the `AppTheme` (colors, fonts, button styles) to ensure a consistent Look & Feel across the app.

---

## 🔄 Workflow Strategy

The communication between files follows a unidirectional flow:

1.  **User Action**: A user clicks a button on a **Screen** (e.g., "Add Task").
2.  **Logic Trigger**: The Screen calls a function in the **Provider** (e.g., `taskProvider.addTask(...)`).
3.  **Data Operation**: The Provider calls the **Service** (e.g., `taskService.createTask(...)`).
4.  **Backend Sync**: The Service sends data to **Firebase Cloud Firestore**.
5.  **State Update**:
    - For streams: Firestore sends new data automatically -> Service maps it to Models -> Provider receives it and calls `notifyListeners()`.
    - For futures: The Provider waits for completion, updates local state, and calls `notifyListeners()`.
6.  **UI Rebuild**: The **Screen** detects the change in the Provider and automatically refreshes to show the new data.

---

## 🔌 Offline Data Storage

TaskFlow leverages **Firebase Firestore Offline Persistence** to achieve a seamless offline experience.

### How it works:
- **Local Cache**: When the app is online, Firestore caches all data it retrieves.
- **Offline Access**: If the device loses connection, the app continues to work using the local cache. `Stream` listeners will still receive data from the cache.
- **Queued Writes**: Any changes made while offline (creating a task, changing status) are stored in a local "pending" queue.
- **Automatic Sync**: As soon as the device regains internet access, Firestore automatically pushes all queued changes to the cloud.

### Implementation Detail:
No manual database (like Sqflite or Hive) is required because Firestore handles the local database logic automatically on Android and iOS. This ensures the app is "Offline-First" without adding complex local sync logic.
