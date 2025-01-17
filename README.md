# FitQuest: Your Fitness Journey Awaits

Welcome to FitQuest!
FitQuest is more than just a fitness tracker—it's a platform that transforms everyday workouts into exciting adventures.
Track your progress, achieve goals, and turn your fitness journey into a captivating story.

## Table of Contents

-   Project Overview
-   Core Features
-   Technical Overview
-   Development Approach
-   Getting Started
-   Assessment Criteria

## Core Features

Essentials

-   [x] GPS Run Tracking: Map and monitor running or cycling activities.
-   [x] Workout History: Replay routes and view past performance.
-   [ ] Goal Management: Set and track fitness goals.
-   [x] Data Synchronization: Store data locally and sync with Firebase Firestore.
-   [x] Distance Calculation: Measure and display distances covered.

### Bonus Features

-   [ ] Share achievements on social media.
-   [x] Compete on leaderboards and connect with friends.
-   [ ] Create and join custom fitness challenges.

## Technical Overview

### Architecture

The app uses MVVM + Clean Architecture for maintainable and scalable development. This ensures clear separation of concerns between UI, business logic, and data layers.

### Firebase Integration

-   [x] Authentication: User account management.
-   [x] Firestore: Structured storage for profiles, fitness data, and history.

### Local Database

-   [x] SQLite: Offline data storage using the sqflite package.
-   [x] Sync data seamlessly between Firestore and the local database.

### Maps and Location

-   [x] Real-time location tracking.
-   [x] Route mapping and distance calculation.
-   [ ] Place markers and location search.
