#!/bin/bash

# Two iOS Players Integration Test
# This script runs a multiplayer game test on two iOS simulators

set -e

cd "$(dirname "$0")"

echo "=========================================="
echo "Two iOS Players Integration Test"
echo "=========================================="
echo ""

# List available simulators
echo "Available iOS Simulators:"
xcrun simctl list devices available | grep -E "iPhone|iPad" | head -10
echo ""

# Get simulator IDs
SIMULATOR_1=${1:-"iPhone 16 Pro"}
SIMULATOR_2=${2:-"iPhone 16"}

echo "Using simulators:"
echo "  Host: $SIMULATOR_1"
echo "  Guest: $SIMULATOR_2"
echo ""

# Get simulator UDIDs
SIM1_ID=$(xcrun simctl list devices available | grep "$SIMULATOR_1" | head -1 | grep -oE "[A-F0-9-]{36}")
SIM2_ID=$(xcrun simctl list devices available | grep "$SIMULATOR_2" | head -1 | grep -oE "[A-F0-9-]{36}")

if [ -z "$SIM1_ID" ]; then
  echo "Error: Could not find simulator '$SIMULATOR_1'"
  exit 1
fi

if [ -z "$SIM2_ID" ]; then
  echo "Error: Could not find simulator '$SIMULATOR_2'"
  exit 1
fi

echo "Simulator UDIDs:"
echo "  Host: $SIM1_ID"
echo "  Guest: $SIM2_ID"
echo ""

# Boot simulators
echo "Booting simulators..."
xcrun simctl boot "$SIM1_ID" 2>/dev/null || true
xcrun simctl boot "$SIM2_ID" 2>/dev/null || true

# Wait for simulators to boot
sleep 5

# Open Simulator app to show the devices
open -a Simulator

echo ""
echo "Starting host on $SIMULATOR_1..."
echo ""

# Run host test in background
flutter test integration_test/two_ios_players_test.dart \
  -d "$SIM1_ID" \
  --dart-define=PLAYER_ROLE=host \
  2>&1 | tee /tmp/host_test.log &

HOST_PID=$!

# Wait for host to set up (parse output for guest credentials)
echo "Waiting for host to create game and guest user..."
sleep 20

# Try to extract guest credentials from host output
GUEST_EMAIL=$(grep -oP 'Email: \K[^\s]+' /tmp/host_test.log 2>/dev/null | tail -1 || echo "")
GUEST_PASSWORD=$(grep -oP 'Password: \K[^\s]+' /tmp/host_test.log 2>/dev/null | tail -1 || echo "")

if [ -n "$GUEST_EMAIL" ] && [ -n "$GUEST_PASSWORD" ]; then
  echo ""
  echo "Found guest credentials:"
  echo "  Email: $GUEST_EMAIL"
  echo "  Password: $GUEST_PASSWORD"
  echo ""
  echo "Starting guest on $SIMULATOR_2..."
  echo ""

  # Run guest test
  flutter test integration_test/two_ios_players_test.dart \
    -d "$SIM2_ID" \
    --dart-define=PLAYER_ROLE=guest \
    --dart-define=GUEST_EMAIL="$GUEST_EMAIL" \
    --dart-define=GUEST_PASSWORD="$GUEST_PASSWORD" \
    2>&1 | tee /tmp/guest_test.log &

  GUEST_PID=$!
else
  echo "Could not extract guest credentials from host output."
  echo "Run guest manually with the credentials printed in the host terminal."
fi

# Wait for both tests
wait $HOST_PID 2>/dev/null || true
wait $GUEST_PID 2>/dev/null || true

echo ""
echo "=========================================="
echo "Test complete!"
echo "=========================================="
