# Protocol (REST + WebSocket)

## Auth (REST)
Base URL: `https://api.<domain>`

### POST /auth/signup
Body:
```json
{ "email": "a@b.com", "password": "secret", "username": "jon", "displayName": "Jon", "avatarUrl": null }
```
Response 201:
```json
{ "message": "verification_sent" }
```

### POST /auth/verify
Body:
```json
{ "token": "<token-from-email>" }
```

### POST /auth/login
Body:
```json
{ "email": "a@b.com", "password": "secret" }
```
Response 200:
```json
{ "accessJwt": "<jwt>", "refreshToken": "<opaque>" }
```
Login must fail if `email_verified_at IS NULL`.

### POST /auth/refresh
Body:
```json
{ "refreshToken": "<opaque>" }
```
Response 200 returns new access + rotated refresh token.

### POST /auth/password-reset/request
Body:
```json
{ "email": "a@b.com" }
```
Always respond 200 to avoid user enumeration.

### POST /auth/password-reset/confirm
Body:
```json
{ "token": "<token-from-email>", "newPassword": "newsecret" }
```

---

## Users & Friends (REST)

### GET /me
Auth: Bearer access JWT

### GET /users/search?username=prefix
Returns list of users (limited fields).

### POST /friends/request
```json
{ "userId": "uuid" }
```

### POST /friends/accept
```json
{ "userId": "uuid" }
```

### POST /friends/decline
```json
{ "userId": "uuid" }
```

### POST /friends/block
```json
{ "userId": "uuid" }
```

---

## Games (REST)
### POST /games
Body:
```json
{ "maxPlayers": 7 }
```

### POST /games/{gameId}/invite
```json
{ "userId": "uuid" }
```

### POST /games/{gameId}/livekit-token
Response:
```json
{ "url": "wss://livekit.<domain>", "room": "game-<gameId>", "token": "<livekit-jwt>" }
```

---

## WebSocket (Realtime)
Endpoint: `wss://api.<domain>/ws`
Auth: client sends `cmd.hello` with access JWT.

### Client → Server commands
All commands include:
- `type`
- `clientSeq` (monotonic per connection; used for correlating errors)
- where relevant `gameId`

#### cmd.hello
```json
{ "type": "cmd.hello", "jwt": "<accessJwt>", "clientSeq": 1 }
```

#### cmd.resync
```json
{ "type": "cmd.resync", "gameId": "g123", "clientSeq": 2 }
```

#### cmd.joinGame
```json
{ "type": "cmd.joinGame", "gameId": "g123", "clientSeq": 3 }
```

#### cmd.startGame
```json
{ "type": "cmd.startGame", "gameId": "g123", "clientSeq": 4 }
```

#### cmd.draw
```json
{ "type": "cmd.draw", "gameId": "g123", "from": "stock", "clientSeq": 5 }
```

#### cmd.discard
```json
{ "type": "cmd.discard", "gameId": "g123", "card": "7S", "clientSeq": 6 }
```

#### cmd.layDown
Lay melds without going out.
```json
{ "type": "cmd.layDown", "gameId": "g123", "melds": [ ... ], "clientSeq": 7 }
```

#### cmd.goOut
```json
{ "type": "cmd.goOut", "gameId": "g123", "melds": [ ... ], "discard": "QH", "clientSeq": 8 }
```

#### cmd.settings.videoAutoStart
```json
{ "type": "cmd.settings.videoAutoStart", "gameId": "g123", "enabled": true, "clientSeq": 9 }
```

### Server → Client messages
All server messages include:
- `type`
- `gameId` (when applicable)
- `serverSeq` (monotonic per game)

#### evt.state (snapshot)
Sent on join/resync and occasionally.
Snapshot includes:
- Public state for everyone
- Private `yourHand` only for the recipient

#### evt.event (incremental)
Events like:
- `turnChanged`, `cardDrawn`, `cardDiscarded`, `meldsLaid`, `roundStarted`, `roundEnded`, `gameFinished`

#### evt.error
```json
{ "type": "evt.error", "clientSeq": 6, "code": "invalid_move", "message": "Not your turn" }
```

---

## Card encoding
Use a compact stable encoding:
- Suits: `S` spades, `H` hearts, `D` diamonds, `C` clubs, `T` stars
- Ranks: `3-10`, `J`, `Q`, `K`
- Joker: `X`
Examples: `7S`, `10T`, `QH`, `X`

