#Task Manager App

A Flutter task management app with categories and priorities, built with Clean Architecture. Supports user authentication and task syncing with offline support — Firebase is used when an internet connection is available, falling back to local storage (SharedPreferences) when offline.

Features


Authentication — Sign up and sign in with email/password via Firebase Authentication. The logged-in session persists across app restarts, so users don't need to log in every time.
Task Management — Create, view, update, and delete tasks.
Categories & Priorities — Organize tasks by category and assign priority levels.
Offline Support — When there's no internet connection, tasks and auth data are read from and written to local storage (SharedPreferences) and synced with Firebase once the connection is restored.
Clean Architecture — The codebase is structured into clear layers (presentation, domain, data) for separation of concerns, testability, and maintainability.


Tech Stack

LayerTechnologyFrameworkFlutterArchitectureClean ArchitectureState ManagementsetStateAuthentication & Remote DataFirebase (Firebase Auth)Local StorageSharedPreferences

Project Structure

This project follows Clean Architecture principles
Getting Started

Prerequisites


Flutter SDK installed
A Firebase project set up for this app (Android/iOS configured via the Firebase Console)


Installation


Clone the repository


bash   git clone https://github.com/your-username/your-repo-name.git
   cd your-repo-name


Install dependencies


bash   flutter pub get


Set up Firebase

Add your google-services.json (Android) to android/app/
Add your GoogleService-Info.plist (iOS) to ios/Runner/
Or run flutterfire configure if using the FlutterFire CLI



Run the app


bash   flutter run

How Offline Support Works

When the user logs in or manages tasks:


With an internet connection — data is read from and written to Firebase.
Without an internet connection — data is read from and written to SharedPreferences as a local cache, so the user can keep using the app and the data syncs once they're back online.


License

This project is open source and available for educational purposes.
