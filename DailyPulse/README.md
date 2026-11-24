# DailyPulse – Namaz, Hydration & Sleep Tracker

**DailyPulse** is a modern, production-grade iOS app built in **Swift** and **SwiftUI** designed for holistic daily habit and spiritual tracking. It seamlessly integrates **Firebase Authentication**, **REST API JSON Parsing for Namaz Prayer Times**, an interactive **Hydration Tracker**, an intuitive **Sleep Tracker** with SwiftUI `Stepper` and `Picker`, and **Firebase Cloud Firestore** for real-time cloud sync and historical analytics.

---

## 📱 Features & Architecture

### 1. User Authentication (Firebase Authentication)
- **Secure Sign Up & Sign In**: Powered by `FirebaseAuth` with email format and password length validation.
- **Session Persistence**: Listens to Firebase auth state changes and auto-restores authenticated sessions.
- **Password Reset**: Self-service password reset email triggers.
- **Demo / Guest Mode**: Instant 1-click evaluation mode allowing full app testing in the Xcode Simulator even before configuring Firebase credentials.

### 2. Namaz Tracker (REST API & JSONDecoder)
- **Aladhan REST API Integration**: Calls `https://api.aladhan.com/v1/timingsByCity` with parameters for city, country, and Islamic calculation methods.
- **Strongly Typed Models**: Parses API responses using Swift's `JSONDecoder` into `Timings`, `AladhanResponse`, and `PrayerItem`.
- **Prayer Checklist**: Check off completed prayers (**Fajr, Dhuhr, Asr, Maghrib, Isha**) with spring animations, haptic feedback, and Arabic script subtitles.
- **Upcoming Prayer Banner**: Live countdown timer identifying the next prayer and time remaining.
- **Location Selector**: Choose from global city presets (London, New York, Makkah, Madinah, Istanbul, Cairo, Dubai, Dhaka, etc.) or input custom cities.
- **Offline Fallback**: Intelligent fallback timetables so the tracker remains fully functional offline.

### 3. Hydration Tracker (Quick-Add & Live Progress)
- **Visual Circular Progress Ring**: Live animated progress meter displaying current intake (ml) vs. daily target.
- **Quick-Add Buttons**:
  - `+150 ml` (Cup ☕️)
  - `+250 ml` (Glass 🥛)
  - `+500 ml` (Bottle 💧)
  - `+750 ml` (Large Flask 🫙)
- **Custom Stepper**: Adjust custom intake amounts in 50 ml increments.
- **Goal Customization**: Flexible presets (1500 ml to 3500 ml).
- **Undo & Reset Controls**: Quickly revert the last logged intake or reset the day.

### 4. Sleep Tracker (SwiftUI Stepper & Picker)
- **SwiftUI Stepper**: Direct control over sleep duration in 0.5-hour steps (1.0h to 16.0h).
- **SwiftUI Picker**: Segmented rest quality picker (`Poor 🥱`, `Fair 😐`, `Good 😊`, `Excellent ✨`) with color-coded badges and descriptions.
- **Sleep Schedule Pickers**: `DatePicker` components for bedtime and wake-up times, plus an **Auto-Calculate Duration** button.
- **Sleep Health Insights**: Real-time evaluation comparing sleep against recommended 7–9 hour restorative guidelines.

### 5. Cloud Sync & History (Firebase Cloud Firestore)
- **Firestore Schema**: Records are stored under:
  ```
  users/{userId}/daily_records/{YYYY-MM-DD}
  ```
- **Real-Time & Local Cache**: Every change to prayers, hydration, or sleep syncs to Cloud Firestore while maintaining local persistence in `UserDefaults` for offline resilience.
- **History Dashboard**:
  - Time-range filters (`7 Days`, `30 Days`, `All Time`).
  - Aggregate analytics: Average Sleep Hours, Average Water Intake (ml), and Overall Prayer Consistency (%).
  - Chronological daily breakdown log cards.

---

## 📂 Project Structure

```
DailyPulse/
├── Package.swift
├── DailyPulse.xcodeproj/
│   └── project.pbxproj
└── DailyPulse/
    ├── DailyPulseApp.swift            # SwiftUI App entry point & Firebase configuration
    ├── Info.plist                     # iOS Target property list
    ├── GoogleService-Info.plist       # Firebase configuration plist template
    ├── Models/
    │   ├── PrayerTime.swift           # Aladhan REST API schema & Namaz domain models
    │   ├── HydrationModel.swift        # Water intake & progress models
    │   ├── SleepModel.swift            # Sleep duration & quality enums
    │   ├── DailyRecord.swift           # Aggregate record with Firestore dictionary mapping
    │   └── AppUser.swift               # User identity model
    ├── Services/
    │   ├── FirebaseManager.swift       # Safe Firebase initialization wrapper
    │   ├── AuthService.swift           # Firebase Auth sign-up, login, password reset
    │   ├── NamazAPIService.swift       # URLSession & JSONDecoder REST client
    │   ├── FirestoreService.swift      # Cloud Firestore save/load & history
    │   └── DailyRecordStore.swift      # Centralized daily state coordinator & syncer
    ├── ViewModels/
    │   ├── AuthViewModel.swift         # Authentication UI state & actions
    │   ├── NamazViewModel.swift        # Prayer times, countdown, & checkoffs
    │   ├── HydrationViewModel.swift    # Water progress & quick-add logic
    │   ├── SleepViewModel.swift        # Stepper & Picker sleep controls
    │   └── HistoryViewModel.swift      # Firestore historical analytics
    ├── Views/
    │   ├── RootView.swift              # Auth state gatekeeper
    │   ├── MainTabView.swift           # 5-tab navigation bar
    │   ├── TodayDashboardView.swift    # Unified 3-pillar daily overview
    │   ├── Auth/
    │   │   ├── LoginView.swift         # Sign-in & demo login
    │   │   └── SignUpView.swift        # Account registration
    │   ├── Namaz/
    │   │   ├── NamazTrackerView.swift  # Prayer timetable & city selector
    │   │   └── PrayerRowView.swift     # Interactive prayer row item
    │   ├── Hydration/
    │   │   └── HydrationTrackerView.swift # Circular ring & quick-add buttons
    │   ├── Sleep/
    │   │   └── SleepTrackerView.swift  # Stepper, Picker, & sleep scheduler
    │   ├── History/
    │   │   └── HistoryView.swift       # Past records & aggregate trends
    │   └── Components/
    │       ├── CardView.swift          # Reusable styled card container
    │       ├── CircularProgressBar.swift # Animated circular progress ring
    │       └── LinearProgressBar.swift # Smooth linear progress bar
    └── Utilities/
        ├── Date+Extensions.swift       # Date formatting utilities
        └── Color+Theme.swift           # Color palette & dark/light mode themes
```

---

## 🚀 Running the Project in Mac Xcode

### Prerequisites
- macOS Sonoma or newer
- **Xcode 15.0+** or **Xcode 16.0+**
- iOS 16.0+ Deployment Target

### Quick Start Instructions

1. **Transfer or Clone to your Mac**:
   ```bash
   git clone https://github.com/YourUsername/DailyPulse.git
   cd DailyPulse/DailyPulse
   ```

2. **Open in Xcode**:
   - Double-click `DailyPulse.xcodeproj` to open it in Xcode.

3. **Add Firebase via Swift Package Manager (SPM)**:
   - In Xcode, go to: **File** > **Add Package Dependencies...**
   - Enter the repository URL:
     ```
     https://github.com/firebase/firebase-ios-sdk.git
     ```
   - In the package options, select **Exact Version** or **Up to Next Major Version** (e.g. `10.25.0` or higher).
   - Under **Choose Package Products for DailyPulse**, select:
     - `FirebaseAuth`
     - `FirebaseFirestore`
   - Click **Add Package**.

4. **Connect Firebase (Optional for Cloud Sync)**:
   - Create a project on the [Firebase Console](https://console.firebase.google.com/).
   - Add an iOS app with Bundle ID: `com.dailypulse.DailyPulse` (or your custom bundle ID in target settings).
   - Enable **Authentication** (Email/Password provider).
   - Enable **Cloud Firestore** in test or production mode.
   - Download `GoogleService-Info.plist` from Firebase Console and replace the template at `DailyPulse/DailyPulse/GoogleService-Info.plist`.

> [!NOTE]
> **Zero-Setup Demo Mode**: You can build and run immediately in the Xcode Simulator without configuring Firebase! If `GoogleService-Info.plist` is not replaced, the app automatically runs in **Guest / Demo Mode** with local persistence and full Namaz REST API parsing.

5. **Build and Run**:
   - Select an iOS Simulator (e.g., iPhone 15 Pro / iPhone 16) or a connected device.
   - Press **Cmd + R** (or click the Run button ▶️).

---

## 🛠️ API & Network Details
- **Endpoint**: `https://api.aladhan.com/v1/timingsByCity/{DD-MM-YYYY}`
- **Parser**: Native `JSONDecoder` decoding `AladhanResponse`
- **Fallback**: Built-in standard timetable activated automatically if network connectivity is unavailable.
