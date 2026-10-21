#!/usr/bin/env bash
# Runs the Flutter integration test on the running emulator and keeps its log.
set -o pipefail
cd "$(dirname "$0")/../app"
mkdir -p screenshots
adb wait-for-device
adb shell settings put global window_animation_scale 0
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/app_test.dart \
  -d emulator-5554 2>&1 | tee screenshots/drive.log
