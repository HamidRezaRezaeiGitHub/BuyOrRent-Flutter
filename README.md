# BuyOrRent

A financial decision-support app that helps Canadians compare **renting vs. buying** a home. Flutter rewrite of the [original React app](https://github.com/HamidRezaRezaeiGitHub/BuyOrRent), targeting iOS, Android, and Web.

---

## Table of Contents

1. [Tech Stack](#tech-stack)
2. [Developer Guide](#developer-guide)
   - [Prerequisites](#prerequisites)
   - [Local Development](#local-development)
   - [Android — UAT Build](#android--uat-build)
   - [Android — Production Build](#android--production-build)
   - [iOS — UAT Build (TestFlight)](#ios--uat-build-testflight)
   - [iOS — Production Build (App Store)](#ios--production-build-app-store)
3. [Installing on Your Phone (Non-Technical)](#installing-on-your-phone-non-technical)
   - [Android](#android)
   - [iPhone](#iphone)
4. [Project Structure](#project-structure)
5. [Reference App](#reference-app)

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter 3.41 / Dart 3.11 |
| State Management | Riverpod |
| Routing | GoRouter |
| Charting | fl_chart |
| Theming | Material 3 |
| Testing | flutter_test + mocktail |

---

## Developer Guide

### Prerequisites

| Tool | Version | Notes |
|------|---------|-------|
| Flutter SDK | 3.41.x stable | [Install guide](https://docs.flutter.dev/get-started/install) |
| Dart | 3.11.x | Included with Flutter |
| Android Studio | Latest | Android SDK + emulator |
| Xcode | 15+ | **macOS only** — required for iOS builds |
| Apple Developer account | Active ($99/yr) | Required for TestFlight & App Store |
| Google Play Console account | Active ($25 one-time) | Required for Play Store distribution |
| Java / JDK | 17+ | Required by Android Gradle |

```bash
flutter doctor   # Verify your environment is fully set up
```

---

### Local Development

```bash
flutter pub get          # Install dependencies
flutter run -d chrome    # Web (hot-reload)
flutter run              # Picks a connected device / emulator
flutter test             # Run all tests
flutter analyze          # Static analysis / lint
```

---

### Android — UAT Build

UAT (User Acceptance Testing) uses a **debug** or **profile** build distributed to testers before a public release.

**Option A — Direct APK (simplest)**

```bash
# Build a debug APK
flutter build apk --debug

# Output: build/app/outputs/flutter-apk/app-debug.apk
# Share this file directly with testers (email, Slack, etc.)
```

**Option B — Firebase App Distribution (recommended)**

1. Create a project in [Firebase Console](https://console.firebase.google.com).
2. Add the Android app (use `com.example.buy_or_rent` or your bundle ID).
3. Download `google-services.json` → place in `android/app/`.
4. Install Firebase CLI: `npm install -g firebase-tools && firebase login`
5. Build and distribute:

```bash
flutter build apk --release
firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk \
  --app <YOUR_FIREBASE_APP_ID> \
  --groups "uat-testers"
```

Testers receive an email with a download link and install it directly on their Android device.

---

### Android — Production Build

Production releases go to the **Google Play Store**.

**Step 1 — Create a release keystore (one-time)**

```bash
keytool -genkey -v \
  -keystore android/app/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload
```

> **Important:** Back up `upload-keystore.jks` securely. Losing it means you cannot update your app on the Play Store.

**Step 2 — Configure signing**

Create `android/key.properties` (this file is git-ignored):

```properties
storePassword=<your-keystore-password>
keyPassword=<your-key-password>
keyAlias=upload
storeFile=upload-keystore.jks
```

Add the following to `android/app/build.gradle.kts` (inside `android { ... }`):

```kotlin
val keyProperties = Properties()
val keyPropertiesFile = rootProject.file("key.properties")
if (keyPropertiesFile.exists()) keyProperties.load(keyPropertiesFile.inputStream())

signingConfigs {
    create("release") {
        keyAlias = keyProperties["keyAlias"] as String
        keyPassword = keyProperties["keyPassword"] as String
        storeFile = file(keyProperties["storeFile"] as String)
        storePassword = keyProperties["storePassword"] as String
    }
}

buildTypes {
    release {
        signingConfig = signingConfigs.getByName("release")
    }
}
```

**Step 3 — Build the App Bundle**

```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

**Step 4 — Upload to Google Play Console**

1. Open [Google Play Console](https://play.google.com/console).
2. Create a new app (first time) or select existing.
3. Go to **Production → Create new release**.
4. Upload `app-release.aab`.
5. Fill in release notes and submit for review.

---

### iOS — UAT Build (TestFlight)

> Requires a **Mac** with Xcode and an active Apple Developer account.

**Step 1 — Configure the app in Apple Developer Portal (one-time)**

1. Sign in to [developer.apple.com](https://developer.apple.com).
2. Go to **Certificates, Identifiers & Profiles**.
3. Create an **App ID** with bundle identifier `com.example.buyorrent` (or your chosen ID).
4. Create a **Development Certificate** and a **Distribution Certificate**.
5. Create a **Provisioning Profile** (App Store Distribution).

**Step 2 — Configure Xcode**

```bash
open ios/Runner.xcworkspace
```

In Xcode:
- Select the `Runner` target → **Signing & Capabilities**.
- Set **Team** to your Apple Developer team.
- Set **Bundle Identifier** to match the one registered in the portal.
- Set **Provisioning Profile** to the one created above.

**Step 3 — Build and upload**

```bash
flutter build ipa --release
# Output: build/ios/ipa/buy_or_rent.ipa
```

Open **Xcode → Window → Organizer**, select the archive, and click **Distribute App → TestFlight & App Store**.

Alternatively, use `xcrun altool`:

```bash
xcrun altool --upload-app \
  -f build/ios/ipa/buy_or_rent.ipa \
  -t ios \
  --apiKey <API_KEY> --apiIssuer <ISSUER_ID>
```

**Step 4 — Add testers in App Store Connect**

1. Open [App Store Connect](https://appstoreconnect.apple.com).
2. Go to **TestFlight → Internal Testing** (team members) or **External Testing** (up to 10,000 testers).
3. Add testers by email. They receive an invitation to download **TestFlight** and install the build.

---

### iOS — Production Build (App Store)

The build process is identical to the UAT step above.

**After uploading to App Store Connect:**

1. Navigate to your app → **App Store** tab.
2. Click **+ Version or Platform** and create a new version.
3. Fill in screenshots, description, keywords, and privacy policy URL.
4. Select the build uploaded via TestFlight.
5. Click **Submit for Review**.

Apple's review process typically takes 1–3 business days.

---

## Installing on Your Phone (Non-Technical)

### Android

**Via Google Play Store (when published):**

1. Open the **Google Play Store** on your Android phone.
2. Search for **"BuyOrRent"**.
3. Tap **Install** and wait for it to download.
4. Tap **Open** to launch the app.

**Via direct APK link (beta / UAT):**

1. Open the download link sent to you by the developer.
2. If prompted, tap **Download anyway**.
3. Once downloaded, open the file from your notifications or the **Downloads** folder.
4. If asked "Allow install from unknown sources", tap **Settings** → enable **Install unknown apps** for your browser → go back and tap **Install**.
5. Tap **Open** when installation is complete.

---

### iPhone

**Via TestFlight (beta / UAT):**

1. Install **[TestFlight](https://apps.apple.com/app/testflight/id899247664)** from the App Store (it's free).
2. Open the invitation email or link sent by the developer and tap **View in TestFlight**.
3. Tap **Accept** → **Install**.
4. The app appears on your home screen — tap it to open.

**Via App Store (when published):**

1. Open the **App Store** on your iPhone.
2. Tap the 🔍 search icon and type **"BuyOrRent"**.
3. Tap **Get** next to the app.
4. Authenticate with Face ID / Touch ID / Apple ID password.
5. The app installs and appears on your home screen.

---

## Project Structure

```
lib/
├── app/           # App widget, router, theme
├── features/      # Feature modules (landing, questionnaire, results)
└── shared/        # Models, services, widgets, config
```

## Reference App

The original React codebase is available at `_reference_old_react_app/` (git-ignored) for formula and UX reference.
