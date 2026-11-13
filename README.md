# GRB Travels — Android and iOS

Open this `flutter_app` folder in VS Code and install the **Flutter** and **Dart** extensions. The single Dart codebase produces both Android and iOS apps.

## Android (Windows or macOS)

Run `flutter build apk --release` for an APK, or `flutter build appbundle --release` for the Play Console AAB. Configure an Android upload keystore before publishing.

## iOS (macOS only)

On a Mac, run `flutter pub get`, open `ios/Runner.xcworkspace` in Xcode, set your Apple Team and unique bundle ID, then use **Product → Archive** to upload to App Store Connect. Apple requires Xcode/macOS to produce a signed IPA.

The app uses a safe area on both operating systems to avoid display notches and uses the native back gesture/button to navigate WebView history.
