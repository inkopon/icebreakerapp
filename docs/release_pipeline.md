# Release pipeline

## Android / Play Store

The Android release workflow lives at `.github/workflows/android-release.yml` and follows the same structure used by Running Hit: install dependencies, run tests, sign the release AAB, upload it as a GitHub artifact, and deploy it to the selected Play Store track with Fastlane.

Required GitHub Actions secrets:

- `KEYSTORE_BASE64`: Base64 contents of the Android upload keystore (`.jks`).
- `KEYSTORE_PASSWORD`: Keystore password.
- `KEY_PASSWORD`: Upload key password.
- `KEY_ALIAS`: Upload key alias.
- `GOOGLE_PLAY_JSON_KEY`: Full JSON content for the Google Play service account key.

Manual run input:

- `track`: `internal`, `alpha`, `beta`, or `production`.

Branch trigger:

- Any push to `release/**` deploys to `internal` unless the workflow is run manually with a different track.

Important before first Play Store registration:

- The Android `applicationId` is `com.inkopon.icebreaker`. Use this package name when creating the Play Store app, because it cannot be changed later.

## iOS / App Store preparation

The iOS workflow at `.github/workflows/ios-build.yml` is manual and builds with `--no-codesign`. It is intentionally prepared as a compile check only until Apple Developer Team ID, provisioning profiles, certificates, and App Store Connect API credentials are available.

