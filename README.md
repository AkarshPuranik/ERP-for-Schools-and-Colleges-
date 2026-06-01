# 🎓 EduSphere ERP — School & College Enterprise Resource Planning

[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)](https://flutter.dev/)
[![Firebase](https://img.shields.io/badge/firebase-%23039BE5.svg?style=for-the-badge&logo=firebase&logoColor=ffca28)](https://firebase.google.com/)
[![BLoC State Management](https://img.shields.io/badge/BLoC-State__Management-blueviolet?style=for-the-badge)](https://pub.dev/packages/flutter_bloc)
[![Razorpay](https://img.shields.io/badge/Razorpay-Payment__Gateway-blue?style=for-the-badge&logo=razorpay)](https://razorpay.com/)
[![Hive DB](https://img.shields.io/badge/Hive-Local__Cache-orange?style=for-the-badge)](https://pub.dev/packages/hive)

**EduSphere ERP** is a modern, high-fidelity, cross-platform Enterprise Resource Planning (ERP) application specifically designed for schools, colleges, and educational institutes. Built from the ground up using **Flutter**, **BLoC (Business Logic Component)** state management, and **Firebase**, it delivers a seamless, secure, and incredibly responsive experience for administrators, teachers, and students.

---

## 📱 User Environments & Core Modules

The application defines two distinct, secure portals tailored to student and educator workflows:

### 🧑‍🎓 Student Workspace
*   **Aesthetic Dashboard:** Glassmorphic cards, dynamic progress widgets, and custom micro-animations showing academic status.
*   **Fees & Online Payments:** Built-in integration with **Razorpay** to check outstanding balances, review historical fee slips, and make secure instant tuition payments.
*   **Interactive Assignments:** Access posted coursework, download instruction materials, track submission status, and upload student files.
*   **Academic Performance Hub:** View report cards, quiz/exam marks, subject-wise progression charts, and cumulative analytics.
*   **Attendance Tracker:** View graphical attendance records (percent indicators) and detailed historical monthly calendars.
*   **Doubt Clearance Portal:** Connect with faculty directly by submitting doubts and educational questions.
*   **Campus Events Directory:** Stay informed with beautifully animated cards detailing upcoming school events, extracurricular schedules, and central announcements.

### 👩‍🏫 Teacher / Faculty Workspace
*   **Attendance Register:** Log student attendance for custom subjects/classes, mark present/absent states, and submit records directly to Firestore.
*   **Marks & Grading Console:** Directly input and upload student scores for tests, midterms, and finals.
*   **Assignment publisher:** Create and assign tasks, upload reference materials (PDFs, images) to Firebase Storage, and set deadlines.
*   **Administrative Account Creator:** Utility to register and set up student profiles and credentials securely.
*   **Comprehensive Profile & Settings:** Manage personal teacher profiles, security configurations, and application preferences.

---

## 🛠️ Premium Tech Stack

*   **Core Framework:** `Flutter` & `Dart` (targeting iOS, Android, Web, macOS, Windows, and Linux).
*   **State Management:** `flutter_bloc` & `bloc` with an custom observable block tracker (`ObserverBloc`) to manage predictive state updates.
*   **Database & Cloud Backend:** 
    *   **Firebase Authentication** for secure sign-in and user authentication.
    *   **Cloud Firestore** for real-time document-driven school databases.
    *   **Firebase Storage** for media, PDF, and image document uploads.
*   **Local Caching:** `Hive` & `Hive Flutter` for fast, lightweight local storage. Cached user profiles enable quick loads and reliable offline startup.
*   **Payment Orchestration:** `razorpay_flutter` SDK for live transaction security.
*   **Visual Assets & Micro-animations:** `fl_chart` (analytics), `percent_indicator` (attendance meters), `zoom_tap_animation` (spring-like button tap physics), `animate_do` (fade/zoom entries), `loading_indicator` (dynamic loaders).
*   **Utilities:** `pdf` for PDF generation, `open_file` for viewing doc files, and `dio` for advanced REST queries.

---

## 📁 Repository Structure

The architecture follows strict **Separation of Concerns (SoC)** and Clean Architecture folders:

```text
lib/
├── main.dart                       # App entry point, Hive initialization, Firebase binding, Theme configurations
├── firebase_options.dart           # Auto-generated Firebase platform configuration bindings
├── bloc/                           # State management layer
│   ├── bloc_observable.dart        # Custom BlocObserver for developer state logs
│   └── login_bloc/                 # Login, updates, and forgot-password block logic
├── components/                     # Base design system components (AppBars, Textfields, Custom Buttons)
│   ├── custom_appbar.dart
│   ├── submit_button.dart
│   ├── textfield.dart
│   └── ...
├── constants/                      # Core constants (Theme colors, static metrics)
│   └── colors.dart
├── model/                          # Serializable data objects
│   ├── user_model.dart             # Hive model defining user profile details
│   ├── user_model.g.dart           # Auto-generated adapter class for Hive
│   └── attendance_model.dart       # Model representing class attendance states
├── reusable_widgets/               # Compound reusable cards and elements
│   ├── assignment_card.dart
│   ├── attendance_card.dart
│   ├── fees_due_card.dart
│   └── home_screen_cards/          # Master dashboard UI cards
└── screens/                        # Modular screen flows
    ├── ask_doubt_screen.dart       # Student doubt portal
    ├── assignment_screen.dart      # Student assignment catalog
    ├── fees_due_screen.dart        # Student fees & Razorpay portal
    ├── splash_screen.dart          # Elegant visual transition screens
    ├── attendance/                 # Student and administrator attendance view screens
    ├── events/                     # Noticeboard, announcements, and campus event timelines
    ├── login_screens/              # Multi-role authentication views (User selector, Sign-in, Sign-up)
    ├── student_screens/            # Student home dashboard, profile, and settings
    └── Teacher_screens.dart/       # Teacher dashboard, attendance logger, marks uploader, assignment creator
```

---

## 🚀 Installation & System Setup

Ensure you have the Flutter SDK (>= `3.2.0`) installed on your system before proceeding.

### Step 1: Clone the Repository
```bash
git clone https://github.com/AkarshPuranik/ERP-for-Schools-and-Colleges-.git
cd ERP-for-Schools-and-Colleges-
```

### Step 2: Set up Firebase Configuration
1. Create a Firebase project in the [Firebase Console](https://console.firebase.google.com/).
2. Enable **Email/Password authentication**, **Cloud Firestore**, and **Firebase Storage**.
3. Install the Flutterfire CLI tool:
   ```bash
   dart pub global activate flutterfire_cli
   ```
4. Configure the project platform integrations:
   ```bash
   flutterfire configure
   ```
   *Select the platforms you intend to build (Android, iOS, Web, Windows).* This command automatically generates/updates `lib/firebase_options.dart` and creates the native credentials files (like `google-services.json` inside your android directory).

### Step 3: Configure Razorpay Integration
1. Register on the [Razorpay Dashboard](https://dashboard.razorpay.com/) and fetch your Test API Keys.
2. For **Android integration**, check that the `minSdkVersion` in `android/app/build.gradle` is set to at least `19`.
3. For **iOS integration**, ensure your `Podfile` targets iOS `12.0` or higher.

### Step 4: Install Dependencies & Run Code Generator
The user models utilize Hive code generation. You **must** generate the `user_model.g.dart` file before building the app.

```bash
# Fetch all package dependencies
flutter pub get

# Generate Hive adapters & serializers
dart run build_runner build --delete-conflicting-outputs
```

### Step 5: Run the Project
Ensure you have a simulator/emulator running, or a physical test device connected:

```bash
# List available devices
flutter devices

# Run the app in Debug Mode
flutter run
```

---

## 📦 Building Production Bundles

Prepare ready-to-publish files using Flutter's compiler:

### Android
*   **Compile standard APK:**
    ```bash
    flutter build apk --release
    ```
*   **Compile modern App Bundle (Recommended for Play Store):**
    ```bash
    flutter build appbundle --release
    ```

### iOS
*   **Compile iOS App Bundle:**
    ```bash
    flutter build ipa --release
    ```

### Web
*   **Compile for production web hosting:**
    ```bash
    flutter build web --release
    ```

---

## ✨ Design Guidelines & UI Best Practices
*   **Deep Purple Palette:** Defined inside `lib/constants/colors.dart` representing a premium, authoritative, and engaging educational atmosphere.
*   **Micro-interactions:** Every button and card interactive element uses `zoom_tap_animation` providing responsive haptic-like scaling.
*   **Responsive Layouts:** Components utilize flexible media queries, scroll configurations, and flexible containers, making it look equally pristine on a compact screen or a wide tablet display.
*   **Premium Loaders:** Custom loader screens (`loading_indicator` combined with customized assets) minimize apparent wait time during Firestore network requests.
