#!/bin/bash
set -e

# Simulator IDs (booted)
SIM_HOST="E7EDB821-D59F-44A9-9EC5-9303119FF421"  # iPhone 16 Pro
SIM_GUEST="3C777B05-2540-4C1A-9CE0-BED74BF84D0E" # iPhone 16

APP_BUNDLE="com.example.fivecrownsApp"
OUTPUT_FILE="/tmp/claude/tasks/play_game_$(date +%s).output"

mkdir -p /tmp/claude/tasks

echo "========================================"
echo "PLAY GAME INTEGRATION TEST"
echo "========================================"
echo "Host simulator:  $SIM_HOST"
echo "Guest simulator: $SIM_GUEST"
echo "Output file:     $OUTPUT_FILE"
echo ""

# Step 1: Erase simulator content (clears Keychain too)
echo "Step 1: Erasing simulator content (including Keychain)..."
echo "  Erasing host simulator..."
xcrun simctl shutdown "$SIM_HOST" 2>/dev/null || true
xcrun simctl erase "$SIM_HOST"
xcrun simctl boot "$SIM_HOST"
echo "  Erasing guest simulator..."
xcrun simctl shutdown "$SIM_GUEST" 2>/dev/null || true
xcrun simctl erase "$SIM_GUEST"
xcrun simctl boot "$SIM_GUEST"
echo "  Waiting for simulators to boot..."
sleep 5
echo "  Simulators ready"

# Step 2: Create fresh game
echo ""
echo "Step 2: Setting up test users and game..."
./setup_two_player_game.sh
echo ""

# Step 3: Run tests on both simulators using separate test files
echo "Step 3: Running tests on both simulators..."
echo ""

# Run host test
echo "Starting HOST test on iPhone 16 Pro..."
flutter test integration_test/play_game_host_test.dart \
  -d "$SIM_HOST" \
  2>&1 | tee -a "$OUTPUT_FILE" &
HOST_PID=$!
echo "Host started (PID: $HOST_PID)" >> "$OUTPUT_FILE"

# Wait a moment before starting guest
sleep 5

# Run guest test
echo "Starting GUEST test on iPhone 16..."
flutter test integration_test/play_game_guest_test.dart \
  -d "$SIM_GUEST" \
  2>&1 | tee -a "$OUTPUT_FILE" &
GUEST_PID=$!
echo "Guest started (PID: $GUEST_PID)" >> "$OUTPUT_FILE"

echo ""
echo "Both tests running on fresh installs!"
echo "Output: $OUTPUT_FILE"
echo ""
echo "Waiting for tests to complete..."

# Wait for both tests
wait $HOST_PID
HOST_EXIT=$?
wait $GUEST_PID
GUEST_EXIT=$?

echo ""
echo "========================================"
echo "TEST RESULTS"
echo "========================================"
echo "Host exit code:  $HOST_EXIT"
echo "Guest exit code: $GUEST_EXIT"
echo "Output file:     $OUTPUT_FILE"
echo "========================================"
