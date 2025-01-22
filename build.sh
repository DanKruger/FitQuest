#! /usr/bin/bash
flutter pub get
flutter build apk --release --dart-define-from-file=.env
