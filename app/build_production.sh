#!/bin/bash
# Production build script for Five Crowns app

DOMAIN="fcrowns.centroid.is"
API_URL="https://${DOMAIN}"
WS_URL="wss://${DOMAIN}/ws"

echo "Building Five Crowns for production"
echo "API URL: $API_URL"
echo "WS URL: $WS_URL"
echo ""

BUILD_ARGS="--dart-define=API_URL=${API_URL} --dart-define=WS_URL=${WS_URL}"

case "$1" in
  apk)
    echo "Building Android APK..."
    flutter build apk $BUILD_ARGS --release
    echo ""
    echo "APK: build/app/outputs/flutter-apk/app-release.apk"
    ;;
  aab)
    echo "Building Android App Bundle (Play Store)..."
    flutter build appbundle $BUILD_ARGS --release
    echo ""
    echo "AAB: build/app/outputs/bundle/release/app-release.aab"
    ;;
  ios)
    echo "Building iOS..."
    flutter build ios $BUILD_ARGS --release
    echo ""
    echo "Open Xcode to archive and submit to App Store"
    ;;
  ipa)
    echo "Building iOS IPA..."
    flutter build ipa $BUILD_ARGS --release
    echo ""
    echo "IPA: build/ios/ipa/"
    ;;
  web)
    echo "Building Web..."
    flutter build web $BUILD_ARGS --release
    echo ""
    echo "Web: build/web/"
    ;;
  all)
    echo "Building all platforms..."
    flutter build apk $BUILD_ARGS --release
    flutter build appbundle $BUILD_ARGS --release
    flutter build ios $BUILD_ARGS --release
    flutter build web $BUILD_ARGS --release
    echo ""
    echo "All builds complete!"
    ;;
  run-android)
    echo "Running on Android device with production config..."
    flutter run $BUILD_ARGS
    ;;
  run-ios)
    echo "Running on iOS device with production config..."
    flutter run $BUILD_ARGS
    ;;
  *)
    echo "Usage: $0 {apk|aab|ios|ipa|web|all|run-android|run-ios}"
    echo ""
    echo "  apk         - Build Android APK"
    echo "  aab         - Build Android App Bundle (Play Store)"
    echo "  ios         - Build iOS (then archive in Xcode)"
    echo "  ipa         - Build iOS IPA"
    echo "  web         - Build Web"
    echo "  all         - Build all platforms"
    echo "  run-android - Run on Android with production URLs"
    echo "  run-ios     - Run on iOS with production URLs"
    exit 1
    ;;
esac
