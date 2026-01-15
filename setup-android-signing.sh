#!/usr/bin/env bash
#
# Android Signing Key Generator for Five Crowns
# Generates a keystore for signing Android releases and outputs
# the values needed for GitHub Actions secrets.
#
set -euo pipefail

echo "================================================"
echo "  Android Signing Key Generator"
echo "================================================"
echo ""

# Check for keytool (comes with JDK)
if ! command -v keytool &> /dev/null; then
    echo "ERROR: keytool not found. Please install Java JDK."
    exit 1
fi

KEYSTORE_FILE="upload-keystore.jks"
KEY_ALIAS="upload"

# Check if keystore already exists
if [[ -f "$KEYSTORE_FILE" ]]; then
    echo "WARNING: $KEYSTORE_FILE already exists!"
    read -p "Overwrite? (y/N): " OVERWRITE
    if [[ "$OVERWRITE" != "y" && "$OVERWRITE" != "Y" ]]; then
        echo "Aborted."
        exit 0
    fi
    rm -f "$KEYSTORE_FILE"
fi

# Generate secure passwords
echo "Generating secure passwords..."
STORE_PASSWORD=$(openssl rand -base64 24 | tr -d '\n' | tr -d '/' | tr -d '+')
KEY_PASSWORD=$(openssl rand -base64 24 | tr -d '\n' | tr -d '/' | tr -d '+')

# Prompt for certificate details
echo ""
echo "Enter certificate details (press Enter for defaults):"
read -p "Your name or organization [Five Crowns Dev]: " CN
CN=${CN:-"Five Crowns Dev"}
read -p "Organizational Unit [Mobile]: " OU
OU=${OU:-"Mobile"}
read -p "Organization [Centroid]: " O
O=${O:-"Centroid"}
read -p "City []: " L
read -p "State/Province []: " ST
read -p "Country Code (2 letters) [US]: " C
C=${C:-"US"}

# Build the distinguished name
DNAME="CN=$CN, OU=$OU, O=$O, L=$L, ST=$ST, C=$C"

echo ""
echo "Generating keystore..."

keytool -genkeypair \
    -v \
    -keystore "$KEYSTORE_FILE" \
    -keyalg RSA \
    -keysize 2048 \
    -validity 10000 \
    -alias "$KEY_ALIAS" \
    -storepass "$STORE_PASSWORD" \
    -keypass "$KEY_PASSWORD" \
    -dname "$DNAME"

echo ""
echo "Keystore created: $KEYSTORE_FILE"

# Base64 encode the keystore
echo ""
echo "Base64 encoding keystore..."
KEYSTORE_BASE64=$(base64 -i "$KEYSTORE_FILE")

# Output for GitHub secrets
echo ""
echo "================================================"
echo "  GitHub Actions Secrets"
echo "================================================"
echo ""
echo "Add these secrets to your GitHub repository:"
echo "  Settings > Secrets and variables > Actions > New repository secret"
echo ""
echo "---"
echo ""
echo "Secret name: ANDROID_KEYSTORE_BASE64"
echo "Secret value (base64-encoded keystore):"
echo ""
echo "$KEYSTORE_BASE64"
echo ""
echo "---"
echo ""
echo "Secret name: ANDROID_KEY_ALIAS"
echo "Secret value:"
echo "$KEY_ALIAS"
echo ""
echo "---"
echo ""
echo "Secret name: ANDROID_KEY_PASSWORD"
echo "Secret value:"
echo "$KEY_PASSWORD"
echo ""
echo "---"
echo ""
echo "Secret name: ANDROID_STORE_PASSWORD"
echo "Secret value:"
echo "$STORE_PASSWORD"
echo ""
echo "================================================"
echo ""
echo "IMPORTANT:"
echo "  1. Save these values securely (password manager)"
echo "  2. The keystore file ($KEYSTORE_FILE) should be backed up securely"
echo "  3. If you lose this keystore, you cannot update your app on Play Store"
echo "  4. Delete this file after adding secrets to GitHub (it's in .gitignore)"
echo ""
echo "To verify the keystore:"
echo "  keytool -list -v -keystore $KEYSTORE_FILE -storepass '$STORE_PASSWORD'"
echo ""
