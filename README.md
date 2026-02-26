# SustainaBit CommUnity

> A civic-tech Flutter application empowering communities to report, track, and resolve local issues — powered by Google technologies and Gemini AI.

**Kitahack 2026** · Built with ❤️ using Flutter & Firebase

---

## 👥 Team Introduction

**Team SustainaBit** is a group of passionate developers participating in Kitahack 2026. We believe technology can bridge the gap between citizens and their local authorities, making communities cleaner, safer, and more sustainable.

| Role | Responsibility |
|------|----------------|
| Full-Stack Developer | Flutter app architecture, Firebase integration |
| AI/ML Engineer | Gemini AI integration, sentiment analysis, proof verification |
| UI/UX Designer | Screen design, Material Design 3 theming |
| Backend Developer | Firestore data modelling, cloud services |

---

## 📖 Project Overview

### Problem Statement

Communities around the world face a common challenge: **local issues go unnoticed, unreported, or unresolved**. Citizens have no easy way to report problems like potholes, broken streetlights, clogged drains, or unsanitary public spaces. Even when issues are reported, there is often:

- No transparency about whether the report was received
- No visibility into the status of resolution
- No structured channel for community discussion or collective action
- No accountability mechanism for management teams to prove work was done

This communication breakdown erodes public trust and leads to deteriorating urban infrastructure.

### 🌍 SDG Alignment

**CommUnity** directly contributes to the following United Nations Sustainable Development Goals:

| SDG | Goal | How CommUnity Contributes |
|-----|------|--------------------------|
| **SDG 11** | Sustainable Cities and Communities | Enables citizens to report and track urban infrastructure issues, improving city livability |
| **SDG 16** | Peace, Justice and Strong Institutions | Creates transparent, accountable channels between citizens and local authorities |
| **SDG 3**  | Good Health and Well-being | reduce the number of illnesses from hazardous chemicals and air, water and soil pollution and contamination |

### 💡 Solution

**CommUnity** is a cross-platform Flutter application that creates a **bidirectional communication channel** between community residents and their local management authorities. The app enables:

- 📣 **User** to report community issues with photos, location tags, and descriptions — enhanced by Gemini AI
- 🏛️ **Management teams** to receive, prioritise, respond to, and close issues with AI-assisted proof verification
- 👁️ **Super Admins** to monitor community health through KPI dashboards, AI sentiment analysis, geographic heatmaps, and broadcast messaging

---

## ✨ Key Features

### For Community Members
- **Community Forum** — Browse and engage with community posts and official announcements with an upvote/downvote system
- **Issue Reporting** — Submit geo-tagged issue reports with photo evidence, categorised and prioritised automatically by AI
- **AI Content Enhancement** — Gemini AI improves post clarity, suggests categories, and enriches descriptions before submission
- **Issue Tracking** — Track the status of submitted issues (Pending → In Progress → Resolved) in real time
- **User Profile** — View your post history, submitted issues, and community activity
- **Smart Search** — Search across posts and issues with real-time results
- **Google Sign-In** — Seamless, secure authentication with a single tap

### For Management Teams
- **Management Dashboard** — Centralised view of all pending and in-progress community issues
- **Announcement Publishing** — Broadcast official announcements to the community
- **Proof of Work Submission** — Upload evidence photos when resolving issues; AI verifies the proof and updates the status
- **Zone Assignment** — Assign management responsibilities across geographic zones
- **Duplicate Detection** — AI automatically identifies and suppresses duplicate issue reports

### For Super Admins
- **KPI Monitor** — Real-time team performance metrics (resolution rates, SLA compliance, response times)
- **AI Sentiment Analysis** — Gemini-powered analysis of public sentiment from community posts
- **Geographic Heatmap** — Google Maps–based visualisation of issue density across management zones
- **Broadcast Center** — Send targeted or jurisdiction-wide notifications using customisable templates
- **Issue Intervention** — Identify and escalate SLA-breaching issues for urgent action

---

## 🔧 Overview of Technologies Used

### Google Technologies

| Technology | Usage |
|-----------|-------|
| **Firebase Authentication** | Secure user authentication and session management |
| **Cloud Firestore** | Real-time NoSQL database for posts, issues, users, and comments |
| **Firebase Storage** | Stores user-uploaded images (issue photos, proof of work, avatars) |
| **Google Sign-In** | One-tap OAuth login for community members and management |
| **Google Maps Flutter** | Interactive maps for location tagging, heatmaps, and zone boundaries |
| **Google Maps Cluster Manager** | Marker clustering for issue density visualisation |
| **Google Generative AI (Gemini)** | AI content enhancement, auto-categorisation, sentiment analysis, duplicate detection, and proof-of-work verification |
| **Firebase Core** | Firebase SDK initialisation and app configuration |

### Other Supporting Tools & Libraries

| Library | Purpose |
|---------|---------|
| **Flutter** (SDK ≥ 3.0) | Cross-platform UI framework (Android, iOS, Web) |
| **Provider** | Lightweight state management for authentication and app state |
| **go_router** | Declarative, type-safe navigation with role-based routing |
| **http** | HTTP client for REST API calls |
| **image_picker** | Camera and gallery access for photo uploads |
| **geolocator** | GPS-based location services for issue tagging |
| **shared_preferences** | Persistent local storage for user preferences and session cache |
| **flutter_secure_storage** | Secure token storage using Keychain (iOS) / Keystore (Android) |
| **intl** | Internationalisation and date/time formatting |
| **flutter_svg** | SVG image rendering |
| **flutter_lints** | Static analysis and code quality enforcement |

---

## ⚙️ Implementation Details & Innovation

### System Architecture

CommUnity follows a **clean, feature-based architecture** with clear separation of concerns:

```
lib/
├── main.dart                          # App entry point, Firebase init, Provider setup
├── firebase_options.dart              # Firebase platform configuration
├── gemeni_service.dart                # Gemini AI REST client
├── gemini_config.dart                 # Gemini API key configuration
└── src/
    ├── config/
    │   ├── app_theme.dart             # Material Design 3 light/dark themes
    │   ├── app_constants.dart         # App-wide constants
    │   └── api_key.dart               # Google Maps API key
    ├── models/
    │   ├── post.dart                  # Post/issue/announcement data model
    │   ├── user.dart                  # User data model
    │   ├── comment.dart               # Comment data model
    │   └── proof_verification.dart    # Proof-of-work verification model
    ├── providers/
    │   └── auth_provider.dart         # Authentication state (role, userId, login status)
    ├── services/
    │   ├── auth_service.dart          # Google Sign-In, Firestore user upsert
    │   ├── post_service.dart          # CRUD + real-time streams for posts/issues
    │   ├── user_service.dart          # User profile operations
    │   ├── proof_verification_service.dart  # AI-powered proof verification
    │   ├── storage_service.dart       # SharedPreferences wrapper
    │   └── local_storage_service.dart # Session cache (login state, role, userId)
    ├── screens/
    │   ├── splash_screen.dart         # Launch screen
    │   ├── registration_screen.dart   # Google Sign-In screen
    │   ├── welcome_registration_screen.dart # Post-registration onboarding
    │   ├── home_screen.dart           # Community feed (Forum + Announcements tabs)
    │   ├── issue_page.dart            # Issue tracker (Pending/In-Progress/Resolved)
    │   ├── issue_detail_page.dart     # Full issue details + comments + proof
    │   ├── post_creation_screen.dart  # Create post/issue with AI enhancement
    │   ├── post_detail_screen.dart    # Post details and comments
    │   ├── search_screen.dart         # Real-time search across posts
    │   ├── profile_screen.dart        # User profile and activity history
    │   ├── settings_screen.dart       # App settings
    │   ├── mgmt_dashboard.dart        # Management team dashboard
    │   ├── mgmt_post_creation_screen.dart  # Management announcement creation
    │   ├── admin_assign_zone_screen.dart   # Geographic zone management
    │   └── super_admin/
    │       ├── kpi_monitor_screen.dart          # Team KPI metrics
    │       ├── ai_sentiment_screen.dart          # AI sentiment analysis
    │       ├── heatmap_dashboard_screen.dart     # Google Maps heatmap
    │       ├── broadcast_center_screen.dart      # Mass notification system
    │       └── issue_intervention_screen.dart    # SLA breach escalation
    ├── widgets/
    │   ├── main_shell.dart            # Bottom navigation shell
    │   ├── post_card.dart             # Reusable post/issue card
    │   ├── app_bottom_nav.dart        # Citizen bottom navigation bar
    │   ├── management_bottom_nav.dart # Management bottom navigation bar
    │   ├── app_top_bar.dart           # Shared top app bar
    │   ├── content_tab_toggle.dart    # Forum/Announcements tab switch
    │   ├── category_tags.dart         # Post category tag chips
    │   ├── user_avatar.dart           # User avatar widget
    │   ├── proof_submission_widget.dart  # Proof-of-work upload widget
    │   ├── custom_card.dart           # Generic card component
    │   ├── custom_button.dart         # Reusable button with loading states
    │   ├── loading_indicator.dart     # Loading spinner
    │   └── error_widget.dart          # Error display with retry
    ├── utils/
    │   ├── date_formatter.dart        # Relative time and date formatting
    │   └── validators.dart            # Form validation utilities
    └── routes/
        └── app_router.dart            # Role-based declarative routing (go_router)
```

### Workflow

#### Citizen Issue Reporting Flow
```
User opens app
    ↓
Google Sign-In (Firebase Auth)
    ↓
Community Feed (Announcements + Forum tabs)
    ↓
Tap "Report Issue" → Post Creation Screen
    ↓
AI Enhancement (Gemini):
  • Rewrites description for clarity
  • Auto-suggests categories
  • Assigns priority level
    ↓
Geolocator tags the location
    ↓
Image uploaded to Firebase Storage
    ↓
Post saved to Cloud Firestore
    ↓
Issue appears in Issue Tracker (Pending)
```

#### Management Resolution Flow
```
Management Dashboard shows Pending Issues
    ↓
Team member picks up issue → status: In Progress
    ↓
Work is completed on-site
    ↓
Proof images uploaded via Proof Submission Widget
    ↓
AI Proof Verification (Gemini):
  • Analyses post context and comments
  • Reviews submitted proof images
  • Generates verification verdict
    ↓
Status updated → Resolved ✓
    ↓
Community members see resolution in real time
```

#### AI Innovation Highlights

- **Content Enhancement**: When creating a post, users can trigger Gemini AI to rewrite their description in a clearer, more structured format — lowering the barrier for non-technical community members.
- **Auto-Categorisation**: Gemini analyses the post content and automatically assigns relevant category tags (e.g., "Pothole", "Drainage", "Streetlight"), reducing manual effort.
- **Duplicate Detection**: New issue submissions are compared against existing open issues using Gemini; detected duplicates are suppressed from the feed and linked to the original report.
- **Proof-of-Work Verification**: Management teams submit before/after photos when resolving an issue. Gemini evaluates the evidence against the issue description and community comments to produce a verified, partial, or insufficient verdict — creating an accountability layer that was previously missing.
- **Sentiment Analysis**: Super admins see an AI-powered analysis of community sentiment across all forum posts, helping them identify unhappy areas or emerging concerns before they escalate.

---

## 🚧 Challenges Faced

1. **Firebase CORS on Web** — Google profile photos from the Sign-In API are blocked by CORS when accessed directly on web. We solved this by mirroring the profile photo to Firebase Storage at login time and serving it from there.

2. **Role-Based Routing** — Managing three distinct user roles (citizen, management, super admin) with different navigation structures and home screens required careful `GoRouter` redirect logic and role-aware shell routes.

3. **Firestore Composite Indexes** — Several queries required composite indexes on multiple fields (e.g., `authorId + type + createdAt`). To avoid deploy delays during development, some sorting was moved client-side while indexes were created asynchronously.

4. **Gemini API Integration** — Integrating Gemini's `generateContent` REST API required careful prompt engineering to get consistent, structured outputs (e.g., JSON-formatted category lists, binary proof verdicts). Handling edge cases like empty responses, rate limits, and malformed outputs required robust error handling.

5. **Real-Time Consistency** — Ensuring that upvote counts, comment counts, and issue statuses stay consistent across multiple simultaneous users required using Firestore `FieldValue.increment` and real-time stream subscriptions rather than client-side counters.

6. **Image Upload Performance** — Uploading multiple proof images before submission could block the UI. We used async upload pipelines with progress indicators to keep the experience responsive.

---

## 🚀 Installation & Setup

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) ≥ 3.0.0
- Dart SDK ≥ 3.0.0
- A [Firebase project](https://console.firebase.google.com/) with the following enabled:
  - Firebase Authentication (Google Sign-In provider)
  - Cloud Firestore
  - Firebase Storage
- A [Google Cloud project](https://console.cloud.google.com/) with:
  - Maps SDK for Android / Maps JavaScript API enabled
  - Generative Language API (Gemini) enabled
- [FlutterFire CLI](https://firebase.flutter.dev/docs/cli/) (for generating `firebase_options.dart`)

### Step-by-Step Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/beannfeeder/SustainaBit-CommUnity.git
   cd SustainaBit-CommUnity
   ```

2. **Configure Firebase**

   Install the FlutterFire CLI and run:
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
   This generates `lib/firebase_options.dart` with your project credentials.

3. **Configure API keys**

   Create `lib/src/config/api_key.dart` with your Google Maps API key:
   ```dart
   const String googleMapsApiKey = 'YOUR_GOOGLE_MAPS_API_KEY';
   ```

   Update `lib/gemini_config.dart` with your Gemini API key:
   ```dart
   const String geminiApiKey = 'YOUR_GEMINI_API_KEY';
   ```

4. **Set up Firestore security rules**

   Deploy the included rules:
   ```bash
   firebase deploy --only firestore:rules
   firebase deploy --only storage:rules
   ```

5. **Install dependencies**
   ```bash
   flutter pub get
   ```

6. **Run the app**
   ```bash
   # Android / iOS
   flutter run

   # Web
   flutter run -d chrome

   # Specific device
   flutter run -d <device_id>
   ```

7. **Run tests**
   ```bash
   flutter test
   ```

8. **Lint the codebase**
   ```bash
   flutter analyze
   ```

---

## 🗺️ Future Roadmap

| Priority | Feature | Description |
|----------|---------|-------------|
| 🔴 High | **Push Notifications** | Notify citizens when their reported issue changes status; alert management of new critical issues |
| 🔴 High | **Super Admin Role** | New Role for City Councils to oversee performance of management communities and determine whether reallocation of resources is required |
| 🟡 Medium | **Gamification** | Introduce a points and badge system to reward active community contributors |
| 🟡 Medium | **Multi-Language Support** | Localise the app for Bahasa Malaysia, Mandarin, and Tamil to serve Malaysia's diverse population |
| 🟡 Medium | **Advanced Analytics** | Deeper trend analysis — issue recurrence rates, seasonal patterns, zone comparisons |
| 🟢 Low | **Government API Integration** | Connect with official local government portals (e.g., MyGovUC) to automatically sync reported issues |
| 🟢 Low | **Community Events** | Allow management to post and citizens to RSVP for community clean-up drives and town halls |
| 🟢 Low | **Accessibility Improvements** | Screen reader support, high-contrast themes, and adjustable font sizes |
| 🟢 Low | **Dark Mode Refinement** | Fine-tune the dark theme across all screens for a consistent experience |

---

## 🏗️ Project Structure Summary

```
SustainaBit-CommUnity/
├── lib/                    # Flutter application source code
│   ├── main.dart           # App entry point
│   └── src/                # Feature modules
│       ├── config/         # Theme and constants
│       ├── models/         # Data models
│       ├── providers/      # State management
│       ├── routes/         # Navigation
│       ├── screens/        # UI screens
│       ├── services/       # Business logic & Firebase
│       ├── utils/          # Helper functions
│       └── widgets/        # Reusable UI components
├── test/                   # Unit tests
├── android/                # Android platform config
├── ios/                    # iOS platform config
├── web/                    # Web platform config
├── firestore.rules         # Firestore security rules
├── storage.rules           # Firebase Storage security rules
├── firebase.json           # Firebase project config
└── pubspec.yaml            # Dart/Flutter dependencies
```

## 📄 License

This project was developed for **Kitahack 2026** and is part of the SustainaBit submission.

---

*Built with ❤️ by Team SustainaBit — making communities more sustainable, one issue at a time.*
