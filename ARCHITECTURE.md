# Architecture

## Services (single server)
- Caddy (TLS + reverse proxy)
- Dart API server (REST + WS)
- Postgres (persistent)
- LiveKit (SFU)
- coturn (TURN/STUN)
- Mailpit (dev-only mail capture)

## Domains
- `api.<domain>` -> Dart API (via Caddy)
- `livekit.<domain>` -> LiveKit (via Caddy)
- `turn.<domain>` -> coturn (direct ports)

## Ports / firewall
- 80/tcp and 443/tcp (Caddy)
- LiveKit media:
  - recommended: 7882/udp (UDP mux)
  - optional: 7881/tcp (RTC over TCP fallback)
- coturn:
  - 3478/tcp + 3478/udp
  - 5349/tcp + 5349/udp (TURN over TLS optional)

## Data flow
- REST for auth/friends/lobby actions
- WebSocket for realtime game commands/events
- LiveKit for audio/video streams
- Server mints LiveKit token per user per game, client joins room `game-<gameId>`
