#!/bin/bash
set -e

API_URL="http://10.50.10.30:8080"
MAILPIT_URL="http://10.50.10.30:8025"

# Generate unique IDs
HOST_ID=$(date +%s | tail -c 7)
GUEST_ID=$((HOST_ID + 1))

HOST_EMAIL="host-${HOST_ID}@test.local"
HOST_USER="host${HOST_ID}"
GUEST_EMAIL="guest-${GUEST_ID}@test.local"
GUEST_USER="guest${GUEST_ID}"
PASSWORD="SecurePass123!"

echo "========================================"
echo "Setting up two-player game..."
echo "========================================"

# Create host user
echo "Creating host user: $HOST_EMAIL"
curl -s -X POST "$API_URL/auth/signup" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"$HOST_EMAIL\",\"username\":\"$HOST_USER\",\"displayName\":\"Host $HOST_ID\",\"password\":\"$PASSWORD\"}" > /dev/null

sleep 2

# Get host verification token
HOST_MSG_ID=$(curl -s "$MAILPIT_URL/api/v1/search?query=to:$HOST_EMAIL" | jq -r '.messages[0].ID // empty')
if [ -n "$HOST_MSG_ID" ]; then
  HOST_TOKEN=$(curl -s "$MAILPIT_URL/api/v1/message/$HOST_MSG_ID" | grep -oE 'token=[a-zA-Z0-9-]+' | head -1 | cut -d= -f2)
  echo "Host verification token: ${HOST_TOKEN:0:10}..."

  # Verify host
  curl -s -X POST "$API_URL/auth/verify" \
    -H "Content-Type: application/json" \
    -d "{\"token\":\"$HOST_TOKEN\"}" > /dev/null
  echo "Host verified"
fi

# Login host
HOST_JWT=$(curl -s -X POST "$API_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"$HOST_EMAIL\",\"password\":\"$PASSWORD\"}" | jq -r '.accessJwt // empty')

if [ -z "$HOST_JWT" ]; then
  echo "ERROR: Failed to login host"
  exit 1
fi
echo "Host logged in"

# Create guest user
echo "Creating guest user: $GUEST_EMAIL"
curl -s -X POST "$API_URL/auth/signup" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"$GUEST_EMAIL\",\"username\":\"$GUEST_USER\",\"displayName\":\"Guest $GUEST_ID\",\"password\":\"$PASSWORD\"}" > /dev/null

sleep 2

# Get guest verification token
GUEST_MSG_ID=$(curl -s "$MAILPIT_URL/api/v1/search?query=to:$GUEST_EMAIL" | jq -r '.messages[0].ID // empty')
if [ -n "$GUEST_MSG_ID" ]; then
  GUEST_TOKEN=$(curl -s "$MAILPIT_URL/api/v1/message/$GUEST_MSG_ID" | grep -oE 'token=[a-zA-Z0-9-]+' | head -1 | cut -d= -f2)
  echo "Guest verification token: ${GUEST_TOKEN:0:10}..."

  # Verify guest
  curl -s -X POST "$API_URL/auth/verify" \
    -H "Content-Type: application/json" \
    -d "{\"token\":\"$GUEST_TOKEN\"}" > /dev/null
  echo "Guest verified"
fi

# Login guest
GUEST_JWT=$(curl -s -X POST "$API_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"$GUEST_EMAIL\",\"password\":\"$PASSWORD\"}" | jq -r '.accessJwt // empty')

if [ -z "$GUEST_JWT" ]; then
  echo "ERROR: Failed to login guest"
  exit 1
fi
echo "Guest logged in"

# Get guest user ID
GUEST_USER_ID=$(curl -s "$API_URL/users/me" -H "Authorization: Bearer $GUEST_JWT" | jq -r '.id // empty')
echo "Guest user ID: $GUEST_USER_ID"

# Create game
GAME_ID=$(curl -s -X POST "$API_URL/games/" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $HOST_JWT" \
  -d '{"maxPlayers":2}' | jq -r '.gameId // empty')

if [ -z "$GAME_ID" ]; then
  echo "ERROR: Failed to create game"
  exit 1
fi
echo "Game created: $GAME_ID"

# Invite guest
curl -s -X POST "$API_URL/games/$GAME_ID/invite" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $HOST_JWT" \
  -d "{\"userId\":\"$GUEST_USER_ID\"}" > /dev/null
echo "Guest invited to game"

# Save credentials to files (include isHost flag)
echo "{\"email\":\"$HOST_EMAIL\",\"password\":\"$PASSWORD\",\"gameId\":\"$GAME_ID\",\"isHost\":true}" > /tmp/host_creds.json
echo "{\"email\":\"$GUEST_EMAIL\",\"password\":\"$PASSWORD\",\"gameId\":\"$GAME_ID\",\"isHost\":false}" > /tmp/guest_creds.json

echo ""
echo "========================================"
echo "TWO PLAYER GAME READY!"
echo "========================================"
echo "HOST:  $HOST_EMAIL"
echo "GUEST: $GUEST_EMAIL"
echo "PASS:  $PASSWORD"
echo "GAME:  $GAME_ID"
echo "========================================"
echo ""
echo "Credentials saved to:"
echo "  /tmp/host_creds.json"
echo "  /tmp/guest_creds.json"
