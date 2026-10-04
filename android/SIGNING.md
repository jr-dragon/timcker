# Android release signing

Application ID: `net.chivincent.timcker`.

Release builds use an upload key with the alias `upload`. Google Play App
Signing manages the separate key that signs APKs delivered to users. Select
Google-managed app signing when configuring the first Play Console release.

## Back up before uploading

Keep encrypted backups of these local, ignored files outside this checkout:

- `android/signing/upload-keystore.jks`: the private upload key (JKS, RSA 2048).
- `android/key.properties`: the keystore password, private-key password, alias,
  and keystore path. The two passwords are randomly generated and stored here.

Save `storePassword` and `keyPassword` in a password manager and record the alias
`upload`. Do not commit the keystore or passwords, paste them into chat, or place
them in build logs. Both private files have owner-only permissions.

Also retain `android/signing/upload-certificate.pem`. It is a public certificate
for identifying the upload key, not a replacement for the keystore. Compare its
fingerprint with the upload certificate shown in Play Console after enrollment.

The keystore path in `key.properties` is relative to the `android` directory:
`storeFile=signing/upload-keystore.jks`. Restore both private files to these
locations on a new machine before building. Do not generate a new key for each
release. If the upload key is lost, use the Play Console upload-key reset process.

## Build and upload

From the project root:

```sh
flutter analyze
flutter test
flutter build appbundle --release
```

Upload the `.aab` printed by Flutter to Play Console's internal testing track.
The initial version is `1.0.0+1`; every later upload must use a higher build number
(the value after `+` in `pubspec.yaml`). Keep each uploaded AAB and its release
notes for traceability. AAB files contain no private signing key or passwords.

Missing signing credentials fail release signing; release builds never fall back
to the debug key. Debug builds continue to use the standard debug signing key.

References: [Flutter Android signing](https://docs.flutter.dev/deployment/android#sign-the-app)
and [Play App Signing](https://developer.android.com/studio/publish/app-signing).
