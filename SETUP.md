# Metal Strength — Setup before deploying

The app **runs out of the box in guest mode** (no backend needed). To enable real
accounts, the donation link, and to ship to the stores, complete the steps below.

---

## 1. Firebase (email/password + Google sign-in)

The app calls `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)`.
Until you generate the real options it throws and the app silently falls back to
**guest mode** — so it never crashes, it just can't authenticate yet.

### 1a. Generate the Firebase config
```bash
dart pub global activate flutterfire_cli
flutterfire configure
```
Pick (or create) your Firebase project and the platforms you ship. This
**overwrites** `lib/firebase_options.dart` with your real keys. After this,
**email/password sign-up and sign-in work immediately**.

### 1b. Enable the sign-in methods
In the Firebase console → **Authentication → Sign-in method**, enable:
- **Email/Password**
- **Google**

### 1c. Google sign-in — Android
1. Add `android/app/google-services.json` (download from the Firebase console).
2. Register your signing **SHA-1** (and SHA-256) in the Firebase console
   (Project settings → Your apps → Android). Get it with:
   ```bash
   cd android && ./gradlew signingReport
   ```
3. Apply the Google Services Gradle plugin:
   - `android/settings.gradle.kts` → add to the `plugins { }` block:
     ```kotlin
     id("com.google.gms.google-services") version "4.4.2" apply false
     ```
   - `android/app/build.gradle.kts` → add to its `plugins { }` block:
     ```kotlin
     id("com.google.gms.google-services")
     ```
4. If Google sign-in still fails, copy the **Web client ID** (Authentication →
   Sign-in method → Google → Web SDK configuration) into
   `lib/core/config.dart` → `AppConfig.googleServerClientId`.

### 1d. Google sign-in — iOS
1. Add `ios/Runner/GoogleService-Info.plist` to the Runner target in Xcode.
2. In `ios/Runner/Info.plist`, add a URL scheme equal to the **REVERSED_CLIENT_ID**
   from that plist:
   ```xml
   <key>CFBundleURLTypes</key>
   <array>
     <dict>
       <key>CFBundleURLSchemes</key>
       <array><string>com.googleusercontent.apps.XXXXXX, your REVERSED_CLIENT_ID</string></array>
     </dict>
   </array>
   ```

> Email/password works with just step 1a. Steps 1c/1d are only needed for the
> "Continue with Google" button.

---

## 2. Donation link
Edit `lib/core/config.dart` → `AppConfig.donationUrl` and point it at your
Ko-fi / Buy Me a Coffee / PayPal.me / Patreon page.

---

## 3. World records & tips
- `lib/core/data/world_records.dart` holds a **curated starter set** of widely
  cited all-time records (men + women) for the iconic lifts. **Verify and extend
  these before release** — records change and vary by federation. Lifts without a
  record (for the user's sex) simply hide the card.
- `lib/core/data/exercise_tips.dart` holds original, copyright-free coaching tips
  grouped by movement pattern (EN/FR). Edit freely.

---

## 4. Languages
**English, French, Spanish, German and Portuguese** ship in
`lib/l10n/app_strings.dart`. The user picks the language on the landing screen;
the choice is persisted. Adding another language is drop-in:
1. Add its code to `AppState.supportedLocales`.
2. Add an endonym to `_languageNames` in `lib/features/home/landing_screen.dart`
   (this drives the language picker).
3. Add the language's column to each entry in `app_strings.dart`. Missing keys
   fall back to English automatically, so you can ship incrementally.

> **Coaching tips** in `lib/core/data/exercise_tips.dart` are only translated for
> `en`/`fr`; other languages fall back to the English tips until you add their
> column there. Everything else in the UI is fully localized.

---

## 5. Pricing — the app is 100% free
There is **no Pro tier, paywall, or in-app purchase**. Every feature —
unlimited per-exercise history, full trend charts, and CSV export — is free for
everyone. The only monetization is the **optional donation button** on the
landing screen (configure its link in §2).

> If you ever want to reintroduce a paid tier, you'd add the
> [`in_app_purchase`](https://pub.dev/packages/in_app_purchase) package and gate
> the relevant features; the CSV rows are already produced by
> `HistoryService.toCsv`.

---

## 6. Store readiness checklist
- [ ] `flutterfire configure` run; Email/Password + Google enabled.
- [ ] Donation URL set.
- [ ] World records verified.
- [x] **App icon set** — the magnet "magnetiss" logo is generated for Android
      (incl. adaptive icon) and iOS. See §7 to regenerate.
- [x] **Release signing config** — `android/app/build.gradle.kts` signs the
      release build from `android/key.properties`. See §7.
- [ ] **Privacy policy** published and linked (required by Apple/Google because
      the app collects an account email).
- [ ] `flutter analyze` clean, `flutter test` green.

---

## 7. App icon & release build

### 7a. App icon (the magnet logo)
The launcher icon is the magnet-gripping-a-barbell mark. Its source PNGs live in
`assets/icon/` and are produced by a script (no design tool needed):

```bash
python tool/generate_icon.py          # writes assets/icon/icon*.png
dart run flutter_launcher_icons       # regenerates Android + iOS icon sets
```

`flutter_launcher_icons` is configured at the bottom of `pubspec.yaml`
(dark `#0B0E14` adaptive background + transparent foreground). Re-run both
commands after any tweak to the logo.

### 7b. Android signing
Release builds are signed with an **upload keystore** referenced by
`android/key.properties` (git-ignored — never commit it). `build.gradle.kts`
loads it automatically and falls back to debug signing if the file is absent
(so fresh clones / CI still build).

To create your own keystore (one-time):
```bash
keytool -genkeypair -v -keystore android/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```
Then copy `android/key.properties.example` → `android/key.properties` and fill in
the passwords/alias. **Back up the `.jks` file and its passwords** — losing them
means you can never update the app on Google Play again.

### 7c. Build the artifacts
```bash
flutter build appbundle --release     # android/.../app-release.aab  -> Play Console
flutter build apk --release           # a standalone APK for sideloading/testing
flutter build ipa --release           # iOS (run on macOS, needs an Apple account)
```
Bump `version:` in `pubspec.yaml` (`x.y.z+build`) before each store upload — the
`+build` number must increase every time.
