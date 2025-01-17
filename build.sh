#! /usr/bin/bash
flutter pub get
flutter build apk --dart-define-from-file=.env
