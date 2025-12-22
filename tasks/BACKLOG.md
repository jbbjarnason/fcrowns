# Backlog (MVP)

## Milestone 0 — Repo + infra bootstrap
- Create monorepo structure (app/, server/, packages/, infra/)
- Docker compose: Postgres, Mailpit, LiveKit, coturn, Caddy, server
- Caddy routes: api.<domain>, livekit.<domain>

## Milestone 1 — Core rules engine (packages/fivecrowns_core)
- Card model + deck construction (2 decks, 6 jokers)
- Shuffle + deal for 11 rounds
- Meld validation:
  - run validation with wild/joker substitutions
  - book validation with suit constraints
- Turn state machine:
  - mustDraw -> mustDiscard
  - goOut rules
  - final-turn rule (no adding to others)
- Scoring per Icelandic rules
- Unit tests covering edge cases

## Milestone 2 — Protocol + DTOs (packages/fivecrowns_protocol)
- REST DTOs for auth/friends/games
- WS command/event DTOs
- JSON serialization

## Milestone 3 — Server auth + email (server/)
- Signup -> create user -> send verification email
- Verify token -> mark email_verified_at
- Login -> JWT + refresh token
- Refresh rotation
- Password reset request/confirm
- Integrate Mailpit for dev

## Milestone 4 — Friends + lobby
- Search users by username prefix
- Friend request/accept/decline/block
- Create game + invite friends + join game + start game

## Milestone 5 — Realtime gameplay
- WS hub with per-game rooms
- Apply commands, persist event, update snapshot, broadcast events
- Reconnect (cmd.resync -> evt.state)

## Milestone 6 — Flutter app MVP
- Auth flows (verify email step)
- Friends UI
- Lobby UI
- Game UI: hand + piles + melds + turn indicator
- WS client with reconnect and snapshot handling

## Milestone 7 — LiveKit integration
- Join room per game
- Auto publish audio (mute toggle)
- Active player camera controls (auto-start toggle + per-turn button)
