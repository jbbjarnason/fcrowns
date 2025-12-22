# Agent: Backend (Dart)

## Mission
Implement the Dart backend (shelf REST + WebSocket) per PROTOCOL.md and PROJECT_SPEC.md.

## Responsibilities
- Postgres schema + migrations
- Auth (email verify + reset) and JWT + refresh token rotation
- Friends + games endpoints
- WebSocket hub + game command handlers
- Event log + snapshot persistence
- LiveKit token minting endpoint

## Constraints
- Never leak other players’ hands
- Snapshot every 25 events
- Resync always returns full snapshot
- Use structured error codes (evt.error)
