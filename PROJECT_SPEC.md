# Five Crowns – Implementation Spec (Finite)

Date: 2025-12-21

## Goal
Build a self-hosted Five Crowns app that feels like Messenger:
- You have friends (add/remove/block)
- You can start a game with friends
- Game screen shows your hand and shared table state
- Optional LiveKit voice/video:
  - Audio is always on by default (player can mute)
  - **Only the active player** can publish video
  - UI includes:
    - **Auto-start video on my turn** (toggle)
    - **Start camera this turn** (button)

### Platforms
Flutter: **iOS, Android, Web**

### Core requirements
- **Server-authoritative**: server shuffles/deals/validates. Clients can’t cheat.
- **Realtime**: WebSocket commands/events.
- **Persistence**: Postgres event log + snapshots (full state including hands) so games can last days and survive restarts.
- **Auth**: email+password + JWT access (7 days) + refresh tokens.
- **Email verification**: required.
- **Password reset**: required (email link).
- **No paid SaaS**.

---

## Five Crowns ruleset (Icelandic)
Implement the rules as per the Icelandic rulebook:
- 2–7 players
- Deck: **two 58-card decks**
  - Suits: stars, hearts, spades, diamonds, clubs
  - Ranks: 3–10, J, Q, K
  - Total jokers: **6**
- 11 rounds:
  - Round 1 deals 3 cards, then +1 each round up to 13 cards in round 11.
- Wilds:
  - Jokers always wild
  - Rotating wild rank equals the number of cards dealt that round
    - Round 1 (3 cards): 3s wild
    - …
    - Round 11 (13 cards): Kings wild
- Melds:
  - **Run**: same suit, consecutive, min 3; wild/jokers allowed; unlimited wild/jokers and can be adjacent.
  - **Book**: same rank (different suits), min 3; wild/jokers allowed; unlimited wild/jokers.
- Turn:
  1) Draw from stock OR discard
  2) Optionally lay meld(s)
  3) Discard exactly 1 card
- Going out:
  - After drawing, player may go out only if they can lay down their entire hand as meld(s) AND still discard one card.
- After someone goes out:
  - Everyone gets **one final turn**
  - In the final turn, you **cannot add** to other players’ melds
- Scoring:
  - Number cards: face value
  - J=11, Q=12, K=13
  - Rotating wild=20
  - Joker=50

**Note:** If any rule detail is ambiguous in the rulebook, implement the common interpretation and document it in `packages/fivecrowns_core/RULE_NOTES.md`.

---

## Architecture overview
- `app/` Flutter client
- `server/` Dart backend (shelf)
- `packages/fivecrowns_core/` pure Dart game engine + tests (shared)
- `packages/fivecrowns_protocol/` DTOs for REST/WS (shared)
- `infra/` docker-compose with Postgres + LiveKit + coturn + Mailpit + Caddy

---

## Persistence model
- Store all actions as an append-only **event log**.
- Maintain a derived **snapshot** of full authoritative state (including hands) in Postgres so games survive restarts.
- Snapshot cadence: every **25 events** (or on key transitions like round start/end, go-out).
- Reconnect: always send full snapshot (no delta replay in MVP).

Security:
- DB is server-trusted; the API must never expose other players’ hands.
- (Optional, later) Encrypt snapshot blobs at rest.

---

## Realtime protocol (WebSocket, JSON)
See `PROTOCOL.md` for the full schema and examples.

---

## Email
- Dev: Mailpit in docker-compose (captures outgoing mail in a web UI)
- Prod: configure SMTP via env vars (can be self-hosted)

Verification and password reset emails must include a **single-use token** (store hashed tokens in DB).

---

## Video/Voice (LiveKit)
- One LiveKit room per game: `game-{gameId}`
- Audio: publish immediately on join (unmuted), mute is client-side track mute.
- Video: only active player may publish.
  - If user enabled “Auto-start video on my turn”, start camera when their turn begins.
  - Otherwise show “Start camera this turn” button when turn begins.
- Backend mints LiveKit JWT tokens.

---

## Deliverables
- Working docker-compose stack.
- Unit tests for the rules engine.
- Basic integration tests for auth + a short game flow.
- A playable MVP UI: auth, friends, lobby, game.

