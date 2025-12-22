# GitHub Secrets Setup

This document explains how to configure the required secrets for the CI/CD workflows.

## Required Secrets

### iOS Secrets

| Secret | Description |
|--------|-------------|
| `IOS_BUILD_CERTIFICATE_BASE64` | Base64-encoded .p12 distribution certificate |
| `IOS_P12_PASSWORD` | Password for the .p12 certificate |
| `IOS_KEYCHAIN_PASSWORD` | Temporary keychain password (can be any secure string) |
| `IOS_PROVISIONING_PROFILE_BASE64` | Base64-encoded .mobileprovision file |
| `IOS_EXPORT_OPTIONS_PLIST` | Contents of ExportOptions.plist for IPA export |

### Android Secrets

| Secret | Description |
|--------|-------------|
| `ANDROID_KEYSTORE_BASE64` | Base64-encoded .jks keystore file |
| `ANDROID_KEY_ALIAS` | Key alias in the keystore |
| `ANDROID_KEY_PASSWORD` | Password for the key |
| `ANDROID_STORE_PASSWORD` | Password for the keystore |

## Setup Instructions

### iOS Setup

1. **Export your distribution certificate:**
   - Open Keychain Access on your Mac
   - Find your "Apple Distribution" certificate
   - Right-click → Export → Save as .p12 file with a password

2. **Encode the certificate:**
   ```bash
   base64 -i certificate.p12 | pbcopy
   ```
   Paste this value as `IOS_BUILD_CERTIFICATE_BASE64`

3. **Get your provisioning profile:**
   - Download from Apple Developer Portal or Xcode
   - Located at `~/Library/MobileDevice/Provisioning Profiles/`

4. **Encode the provisioning profile:**
   ```bash
   base64 -i profile.mobileprovision | pbcopy
   ```
   Paste this value as `IOS_PROVISIONING_PROFILE_BASE64`

5. **Create ExportOptions.plist:**
   ```xml
   <?xml version="1.0" encoding="UTF-8"?>
   <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
   <plist version="1.0">
   <dict>
       <key>method</key>
       <string>app-store</string>
       <key>teamID</key>
       <string>YOUR_TEAM_ID</string>
       <key>uploadBitcode</key>
       <false/>
       <key>uploadSymbols</key>
       <true/>
       <key>signingStyle</key>
       <string>manual</string>
       <key>provisioningProfiles</key>
       <dict>
           <key>is.centroid.fcrown</key>
           <string>YOUR_PROVISIONING_PROFILE_NAME</string>
       </dict>
   </dict>
   </plist>
   ```
   Paste the entire XML as `IOS_EXPORT_OPTIONS_PLIST`

### Android Setup

1. **Create a keystore (if you don't have one):**
   ```bash
   keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA \
     -keysize 2048 -validity 10000 -alias upload
   ```

2. **Encode the keystore:**
   ```bash
   base64 -i upload-keystore.jks | pbcopy
   ```
   Paste this value as `ANDROID_KEYSTORE_BASE64`

3. **Set the remaining secrets:**
   - `ANDROID_KEY_ALIAS`: The alias you used (e.g., "upload")
   - `ANDROID_KEY_PASSWORD`: Password for the key
   - `ANDROID_STORE_PASSWORD`: Password for the keystore

## Adding Secrets to GitHub

1. Go to your repository on GitHub
2. Navigate to **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Add each secret with its name and value

## Local Development

For local release builds:

### Android
Create `app/android/key.properties`:
```properties
storePassword=your_store_password
keyPassword=your_key_password
keyAlias=upload
storeFile=path/to/upload-keystore.jks
```

### iOS
Configure signing in Xcode or use:
```bash
flutter build ios --release
```
and sign manually in Xcode.

## Workflow Triggers

- **Push to main**: Builds all platforms, uploads artifacts
- **Pull requests**: Builds without signing (verification only)
- **Tags (v*)**: Creates GitHub release with all signed artifacts

## Creating a Release

1. Update version in `app/pubspec.yaml`
2. Commit changes
3. Create and push a tag:
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```
4. The release workflow will automatically build and create a GitHub release

## Troubleshooting

### iOS Build Failures
- Verify certificate is not expired
- Ensure provisioning profile matches bundle ID
- Check Team ID in ExportOptions.plist

### Android Build Failures
- Verify keystore password is correct
- Ensure key alias matches
- Check that keystore is valid: `keytool -list -keystore upload-keystore.jks`
