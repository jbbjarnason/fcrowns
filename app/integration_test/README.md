# iOS Integration Tests

Integration tests for the Five Crowns app running on iOS simulator.

## Prerequisites

1. iOS Simulator available (Xcode installed)
2. Backend services running (`cd infra && docker-compose up`)
3. Flutter SDK installed

## Quick Start

### 1. Boot iOS Simulator

```bash
# List available simulators
xcrun simctl list devices available | grep iPhone

# Boot a simulator
xcrun simctl boot "iPhone 16 Pro"

# Or get the UDID and use that
xcrun simctl list devices booted
```

### 2. Run Simple UI Tests

```bash
cd app
flutter test integration_test/simple_flow_test.dart -d <simulator-id>
```

### 3. Run Full Auth Flow Tests

For tests that require API access, you need to configure the host IP:

```bash
# Get your host machine IP
ipconfig getifaddr en0  # e.g., 10.50.10.30

# Run with API URL configured
flutter test integration_test/auth_flow_test.dart \
  -d <simulator-id> \
  --dart-define=API_HOST=10.50.10.30
```

## Cross-Platform Multiplayer Test

To test iOS + Web multiplayer:

### Option 1: Automated Setup

1. Start Playwright test (creates users and game):
```bash
cd e2e
npm run test -- --grep "Cross-Platform"
```

2. The test will output credentials for the iOS player.

3. Run iOS test with those credentials:
```bash
cd app
flutter test integration_test/join_game_test.dart -d <simulator-id>
```

### Option 2: Two iOS Simulators

```bash
cd app
./run_two_ios_test.sh "iPhone 16 Pro" "iPhone 16"
```

Or manually:

```bash
# Terminal 1 - Host
flutter test integration_test/two_ios_players_test.dart \
  -d <sim1-id> \
  --dart-define=PLAYER_ROLE=host

# Terminal 2 - Guest (use credentials from host output)
flutter test integration_test/two_ios_players_test.dart \
  -d <sim2-id> \
  --dart-define=PLAYER_ROLE=guest \
  --dart-define=GUEST_EMAIL=<email> \
  --dart-define=GUEST_PASSWORD=<password>
```

## Test Files

| File | Description |
|------|-------------|
| `simple_flow_test.dart` | Basic UI navigation and validation tests |
| `auth_flow_test.dart` | Full authentication flow with API calls |
| `multiplayer_test.dart` | Basic multiplayer game creation test |
| `join_game_test.dart` | Test for joining an existing game |
| `two_ios_players_test.dart` | Coordinated two-player test |
| `test_helpers.dart` | Utility functions for API calls |

## Troubleshooting

### API Connection Issues

If the iOS simulator can't reach the backend:

1. Check Docker is running: `docker ps`
2. Verify server port is exposed: `docker-compose ps`
3. Try using host machine IP instead of localhost
4. Check macOS firewall settings

### Simulator Not Found

```bash
# List all available simulators
xcrun simctl list devices available

# Boot a specific simulator
xcrun simctl boot <device-name-or-udid>
```

### Test Timeouts

Increase timeout in test or use:
```bash
flutter test integration_test/... --timeout 5m
```
