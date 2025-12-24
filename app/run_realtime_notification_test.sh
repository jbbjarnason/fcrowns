#!/bin/bash
# Run real-time notification E2E tests on two iOS simulators
#
# This script launches the test on two simulators:
# - Simulator 1: Receiver (waits for notifications)
# - Simulator 2: Sender (triggers notifications)
#
# Usage: ./run_realtime_notification_test.sh

set -e

# Simulator IDs (adjust these for your setup)
RECEIVER_SIM="0F1E5812-D276-43CC-A93E-A8DCC870E2AD"  # iPhone 16 Pro
SENDER_SIM="CAD60ED6-64B8-4857-A0E5-28718642E20E"    # iPhone 16

# Boot simulators if not running
echo "Booting simulators..."
xcrun simctl boot $RECEIVER_SIM 2>/dev/null || true
xcrun simctl boot $SENDER_SIM 2>/dev/null || true

# Wait for simulators to be ready
sleep 3

# Open Simulator app
open -a Simulator

# First, run receiver in background and capture output
echo ""
echo "=============================================="
echo "Starting RECEIVER on iPhone 16 Pro..."
echo "=============================================="
echo ""

# Create temp file for receiver credentials
CREDS_FILE=$(mktemp)

# Run receiver and capture credentials
cd "$(dirname "$0")"
flutter test integration_test/realtime_notifications_test.dart \
  -d $RECEIVER_SIM \
  --dart-define=PLAYER_ROLE=receiver 2>&1 | tee "$CREDS_FILE" &

RECEIVER_PID=$!

# Wait for receiver to output credentials
echo "Waiting for receiver to be ready..."
sleep 15

# Extract credentials from receiver output
RECEIVER_EMAIL=$(grep "Email:" "$CREDS_FILE" | head -1 | awk '{print $2}')
RECEIVER_PASSWORD=$(grep "Password:" "$CREDS_FILE" | head -1 | awk '{print $2}')

if [ -z "$RECEIVER_EMAIL" ] || [ -z "$RECEIVER_PASSWORD" ]; then
    echo ""
    echo "ERROR: Could not extract receiver credentials."
    echo "Check the receiver output above for the credentials."
    echo ""
    echo "You can manually run the sender with:"
    echo "  flutter test integration_test/realtime_notifications_test.dart \\"
    echo "    -d $SENDER_SIM \\"
    echo "    --dart-define=PLAYER_ROLE=sender \\"
    echo "    --dart-define=RECEIVER_EMAIL=<email> \\"
    echo "    --dart-define=RECEIVER_PASSWORD=<password>"
    wait $RECEIVER_PID
    exit 1
fi

echo ""
echo "=============================================="
echo "Receiver credentials extracted:"
echo "  Email: $RECEIVER_EMAIL"
echo "  Password: $RECEIVER_PASSWORD"
echo "=============================================="
echo ""

# Give receiver a moment to be fully ready
sleep 5

# Now run sender
echo ""
echo "=============================================="
echo "Starting SENDER on iPhone 16..."
echo "=============================================="
echo ""

flutter test integration_test/realtime_notifications_test.dart \
  -d $SENDER_SIM \
  --dart-define=PLAYER_ROLE=sender \
  --dart-define=RECEIVER_EMAIL="$RECEIVER_EMAIL" \
  --dart-define=RECEIVER_PASSWORD="$RECEIVER_PASSWORD"

SENDER_EXIT=$?

# Wait for receiver to finish
echo ""
echo "Waiting for receiver to complete..."
wait $RECEIVER_PID
RECEIVER_EXIT=$?

# Cleanup
rm -f "$CREDS_FILE"

echo ""
echo "=============================================="
echo "TEST COMPLETE"
echo "=============================================="
echo "Sender exit code: $SENDER_EXIT"
echo "Receiver exit code: $RECEIVER_EXIT"
echo "=============================================="

if [ $SENDER_EXIT -eq 0 ] && [ $RECEIVER_EXIT -eq 0 ]; then
    echo "All tests PASSED!"
    exit 0
else
    echo "Some tests FAILED"
    exit 1
fi
