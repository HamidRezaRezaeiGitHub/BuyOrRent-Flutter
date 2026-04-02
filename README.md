# BuyOrRent

A financial decision-support app helping Canadians compare **renting vs. buying** a home.  
Flutter rewrite of the [original React app](https://github.com/HamidRezaRezaeiGitHub/BuyOrRent).

**Platforms:** iOS · Android · Web

## Tech Stack

Flutter 3.41 / Dart 3.11 · Riverpod · GoRouter · fl_chart · Material 3

## Development

```bash
flutter pub get          # Install dependencies
flutter run -d chrome    # Run on web
flutter test             # Run tests
flutter analyze          # Lint check
```

### Project Structure

```
lib/
├── app/           # App widget, router, theme
├── features/      # Feature modules (landing, questionnaire, results)
└── shared/        # Models, services, widgets, config
```

Reference React codebase is at `_reference_old_react_app/` (git-ignored, searchable in IDE).

---

## Release & Distribution

### Prerequisites (Developer Machine)

1. **Flutter SDK** — installed via Homebrew (`brew install --cask flutter`)
2. **Xcode** (iOS) — install from Mac App Store, then:
   ```bash
   sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
   sudo xcodebuild -runFirstLaunch
   brew install cocoapods
   ```
3. **Android Studio** (Android) — install from https://developer.android.com/studio, then:
   - Open Android Studio → SDK Manager → install latest Android SDK + build tools
   - Accept licenses: `flutter doctor --android-licenses`
4. **Apple Developer Account** ($99/year) — required for App Store distribution
5. **Google Play Developer Account** ($25 one-time) — required for Play Store distribution

### Android Release

| Step                  | UAT                                                       | Production                                       |
| --------------------- | --------------------------------------------------------- | ------------------------------------------------ |
| 1. Create signing key | `keytool -genkey -v -keystore uat.keystore ...`           | `keytool -genkey -v -keystore prod.keystore ...` |
| 2. Configure signing  | Add keystore to `android/key.properties`                  | Same, with prod keystore                         |
| 3. Build              | `flutter build apk --flavor uat`                          | `flutter build appbundle --flavor prod`          |
| 4. Distribute         | Upload APK to Firebase App Distribution or share directly | Upload AAB to Google Play Console                |
| 5. Testing track      | Internal testing track on Play Console                    | Production track on Play Console                 |

**Flavor setup:** Create `android/app/src/uat/` and `android/app/src/prod/` with per-environment configs (API keys, app name, bundle ID suffix).

### iOS Release

| Step            | UAT (TestFlight)                                                        | Production (App Store)                                      |
| --------------- | ----------------------------------------------------------------------- | ----------------------------------------------------------- |
| 1. Certificates | Create Development + Distribution certs in Apple Developer portal       | Same                                                        |
| 2. App ID       | Register `com.buyorrent.buyOrRent.uat`                                  | Register `com.buyorrent.buyOrRent`                          |
| 3. Provisioning | Create Ad Hoc provisioning profile                                      | Create App Store provisioning profile                       |
| 4. Build        | `flutter build ipa --flavor uat --export-method ad-hoc`                 | `flutter build ipa --flavor prod --export-method app-store` |
| 5. Upload       | Open `build/ios/ipa/*.ipa` in Transporter → upload to App Store Connect | Same                                                        |
| 6. Distribute   | App Store Connect → TestFlight → add testers                            | App Store Connect → submit for App Review                   |

### Web Release

```bash
flutter build web                           # Build static site
# Deploy to GitHub Pages, Vercel, Netlify, or Firebase Hosting
```

---

## Installing the App (End Users)

### Android

1. Open the **Google Play Store** on your phone
2. Search for **"BuyOrRent"**
3. Tap **Install**

_For UAT testers:_ You'll receive an email invite to join the testing program. Follow the link to install the test version.

### iOS

1. Open the **App Store** on your iPhone
2. Search for **"BuyOrRent"**
3. Tap **Get** → authenticate with Face ID / Touch ID

_For UAT testers:_ You'll receive a TestFlight invite via email. Install the **TestFlight** app first, then open the invite link to install the test version.

### Web

Visit the hosted URL in any browser (link TBD after deployment).
