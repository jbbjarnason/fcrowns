# CLAUDE.md (for Claude Code / agents)

You are implementing the project described in `PROJECT_SPEC.md`.

## Non-negotiables
- Flutter: iOS/Android/Web
- Backend: Dart (shelf) + WebSockets
- Postgres persistence: event log + snapshots (full state incl. hands)
- Server-authoritative gameplay (no client cheating)
- Email verification + password reset are required (use Mailpit for dev)
- LiveKit: audio always on by default (muteable), only active player publishes video

## Implementation order
1) packages/fivecrowns_core (engine + tests)
2) packages/fivecrowns_protocol (DTOs + JSON codecs)
3) server (auth + friends + games + ws + db + email + livekit token)
4) app (auth + friends + lobby + game + ws + livekit)

## Quality bars
- Clear separation: core engine is pure + testable.
- WebSocket protocol exactly matches PROTOCOL.md.
- Never leak other players’ hands to clients.
- Reconnect works by full snapshot.
- Use structured logging and error codes.

