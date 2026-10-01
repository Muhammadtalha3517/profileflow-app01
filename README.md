# ProfileFlow Assistant 🚀

**ProfileFlow Assistant** is an Android personal profile and data management application engineered in Flutter. It empowers users to store their real personal and professional credentials locally with encryption, and assists them in filling compatible online forms step-by-step with absolute user control.

---

## 🔒 Core Principles & Architecture Guarantee

1. **100% Authentic User Data**:
   - Zero fake data, zero mock identities, zero fabricated credentials in production builds.
   - The app begins with a completely empty profile; all profile entries come exclusively from information provided by the user.

2. **Strict User Control & Zero Auto-Submission**:
   - The app **NEVER** automatically submits forms or clicks *Next*, *Apply*, *Continue*, or *Purchase*.
   - The app **NEVER** bypasses CAPTCHAs, 2FA, or biometric verifications.
   - Every single form field is reviewed and confirmed by the user before values are populated.

3. **Local Encrypted Vault**:
   - All profile details are encrypted using AES-256 and stored on-device.
   - No cloud backend required.
   - Optional 4-digit PIN and Biometric Lock (Fingerprint / Face ID).

---

## 📱 Tech Stack & Highlights

* **Framework**: Flutter (Dart 3+)
* **Design System**: Material 3 with Dynamic Theming (Light & Dark modes, Deep Indigo `#3F51B5`, Teal `#00897B`, Slate neutrals)
* **Embedded Browser**: `webview_flutter` with isolated DOM inspection and change dispatch
* **Local Storage & Security**: `flutter_secure_storage`, `local_auth`, AES-256 vault encryption
* **State Management**: Provider (Clean MVVM architecture)

---

## 📂 Project Architecture

```
lib/
├── main.dart                          # App entrypoint, MultiProvider setup, lock routing
├── core/
│   ├── constants/                     # AppColors, AppTheme, AppStrings
│   ├── errors/                        # AppExceptions & failure handling
│   └── utils/                         # ProfileCompletionCalculator, DateFormatter, Validators
├── models/
│   ├── user_profile.dart              # Root profile container
│   ├── personal_info.dart             # Name, Email, Phone, Address, Postal Code
│   ├── professional_info.dart         # Title, Bio, Rates, Skills, Languages
│   ├── work_experience.dart           # Company, Job Title, Dates, Description
│   ├── education.dart                 # Institution, Degree, Field of Study, Dates
│   ├── portfolio_item.dart            # Projects, URLs, Skills
│   ├── task_item.dart                 # Target URL, allowed categories, status
│   ├── form_field_match.dart          # Field mapping metadata, confidence ratings
│   └── activity_log_entry.dart        # Audit log of scan & fill events
├── database/
│   ├── local_database.dart            # Local encrypted storage coordinator
│   └── database_backup_service.dart   # JSON export & import service
├── security/
│   ├── encryption_service.dart        # AES-256 encryption engine
│   ├── secure_vault_storage.dart      # Secure storage wrapper
│   └── biometric_auth_service.dart    # Biometric authentication bridge
├── field_mapping/
│   ├── field_definition.dart          # Profile field attributes & synonyms
│   ├── heuristic_rules.dart           # String normalization & similarity algorithms
│   └── field_matcher_engine.dart      # Confidence calculation & profile value extraction
├── automation/
│   ├── form_scanner_script.dart       # JavaScript DOM scanner
│   ├── form_filler_script.dart        # JavaScript input event dispatcher
│   └── assistant_session_manager.dart # Assistant lifecycle coordinator
├── providers/
│   ├── profile_provider.dart          # Reactive profile state
│   ├── task_provider.dart             # Reactive task manager
│   ├── assistant_provider.dart        # Assistant session & activity log state
│   ├── search_provider.dart           # Full-text vault search engine
│   ├── theme_provider.dart            # Theme mode toggle
│   └── security_provider.dart         # PIN & Biometrics auth state
├── widgets/
│   ├── assistant/                     # FieldReviewSheet, ManualActionBanner, OverrideDialog
│   ├── cards/                         # ProfileCompletionCard, TaskStatusCard, SectionSummaryCard
│   └── forms/                         # CustomTextField, DatePickerField, DynamicListEditor
└── screens/
    ├── onboarding/                    # OnboardingScreen, InitialProfileSetupScreen
    ├── lock/                          # PinLockScreen
    ├── navigation/                    # MainNavigationScreen (5 Bottom Tabs)
    ├── home/                          # HomeScreen (Dashboard, Quick Actions, Stats)
    ├── profile/                       # ProfileDashboardScreen, Editors & Managers
    ├── tasks/                         # TasksScreen, CreateTaskScreen, TaskDetailScreen
    ├── assistant_browser/             # FormAssistantWebViewScreen
    ├── search/                        # GlobalSearchScreen
    ├── activity/                      # ActivityHistoryScreen (Audit trail)
    └── settings/                      # SettingsScreen, SecuritySettings, ExportImport
```

---

## 🛠️ Build & Setup Instructions

### Prerequisites
* Flutter SDK (3.10.0 or higher)
* Android SDK (API Level 34)
* Java JDK 17

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Run Tests
```bash
flutter test
```

### 3. Run in Debug Mode on Android Device / Emulator
```bash
flutter run
```

### 4. Build Release APK
```bash
flutter build apk --release
```
The output APK will be generated at:
`build/app/outputs/flutter-apk/app-release.apk`

---

## 🛡️ Security Permissions (AndroidManifest.xml)
* `INTERNET` & `ACCESS_NETWORK_STATE`: For user-initiated in-app form browsing.
* `USE_BIOMETRIC` & `USE_FINGERPRINT`: For local biometric vault authentication.
* `READ_MEDIA_IMAGES` / `READ_EXTERNAL_STORAGE`: For user-selected profile photo & documents.
