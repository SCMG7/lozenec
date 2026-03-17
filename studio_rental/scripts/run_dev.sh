#!/bin/bash
flutter run --dart-define=API_BASE_URL=https://lozenec-production.up.railway.app/api/v1 --dart-define=IS_PRODUCTION=false "$@"
