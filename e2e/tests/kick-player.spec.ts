import { test, expect, Browser, BrowserContext, Page } from '@playwright/test';

const API_URL = 'http://localhost:8080';
const MAILPIT_URL = 'http://localhost:8025';

interface Player {
  email: string;
  username: string;
  displayName: string;
  password: string;
  context?: BrowserContext;
  page?: Page;
  accessToken?: string;
  userId?: string;
}

async function registerAndVerifyUser(player: Player): Promise<void> {
  const signupRes = await fetch(`${API_URL}/auth/signup`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      email: player.email,
      username: player.username,
      displayName: player.displayName,
      password: player.password,
    }),
  });

  if (signupRes.status !== 201) {
    const text = await signupRes.text();
    throw new Error(`Signup failed: ${signupRes.status} ${text}`);
  }

  await new Promise(r => setTimeout(r, 1000));

  const messagesRes = await fetch(`${MAILPIT_URL}/api/v1/search?query=to:${player.email}`);
  const messages = await messagesRes.json();

  if (!messages.messages || messages.messages.length === 0) {
    throw new Error(`No verification email found for ${player.email}`);
  }

  const messageId = messages.messages[0].ID;
  const messageRes = await fetch(`${MAILPIT_URL}/api/v1/message/${messageId}`);
  const message = await messageRes.json();

  const tokenMatch = message.Text?.match(/token=([a-zA-Z0-9-]+)/) ||
                     message.HTML?.match(/token=([a-zA-Z0-9-]+)/);

  if (!tokenMatch) {
    throw new Error(`No verification token found in email for ${player.email}`);
  }

  const verifyRes = await fetch(`${API_URL}/auth/verify`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ token: tokenMatch[1] }),
  });

  if (verifyRes.status !== 200) {
    throw new Error(`Verification failed: ${verifyRes.status}`);
  }

  console.log(`User ${player.username} registered and verified`);
}

async function loginViaApi(player: Player): Promise<void> {
  const loginRes = await fetch(`${API_URL}/auth/login`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      email: player.email,
      password: player.password,
    }),
  });

  if (loginRes.status !== 200) {
    throw new Error(`Login failed for ${player.email}`);
  }

  const loginData = await loginRes.json();
  player.accessToken = loginData.accessJwt;

  // Get user ID from /users/me
  const meRes = await fetch(`${API_URL}/users/me`, {
    headers: { 'Authorization': `Bearer ${player.accessToken}` },
  });
  const meData = await meRes.json();
  player.userId = meData.id;
}

async function addFriend(player: Player, friendUserId: string): Promise<void> {
  const res = await fetch(`${API_URL}/friends/request`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${player.accessToken}`,
    },
    body: JSON.stringify({ userId: friendUserId }),
  });

  if (res.status !== 201 && res.status !== 200) {
    const text = await res.text();
    throw new Error(`Friend request failed: ${res.status} ${text}`);
  }
}

async function acceptFriendRequest(player: Player, fromUserId: string): Promise<void> {
  const res = await fetch(`${API_URL}/friends/accept`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${player.accessToken}`,
    },
    body: JSON.stringify({ userId: fromUserId }),
  });

  if (res.status !== 200) {
    const text = await res.text();
    throw new Error(`Accept friend failed: ${res.status} ${text}`);
  }
}

async function createGame(player: Player): Promise<string> {
  const res = await fetch(`${API_URL}/games`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${player.accessToken}`,
    },
    body: JSON.stringify({ maxPlayers: 4 }),
  });

  if (res.status !== 201) {
    const text = await res.text();
    throw new Error(`Create game failed: ${res.status} ${text}`);
  }

  const data = await res.json();
  return data.gameId;
}

async function inviteToGame(player: Player, gameId: string, friendId: string): Promise<void> {
  const res = await fetch(`${API_URL}/games/${gameId}/invite`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${player.accessToken}`,
    },
    body: JSON.stringify({ userId: friendId }),
  });

  if (res.status !== 200) {
    throw new Error(`Invite failed: ${res.status}`);
  }
}

async function startGame(player: Player, gameId: string): Promise<void> {
  const res = await fetch(`${API_URL}/games/${gameId}/start`, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${player.accessToken}`,
    },
  });

  if (res.status !== 200) {
    const text = await res.text();
    throw new Error(`Start game failed: ${res.status} ${text}`);
  }
}

// Skip: Kick feature is implemented via WebSocket, not REST API endpoints
// These tests need to be rewritten to use WebSocket for testing
test.describe.skip('Kick Player Feature', () => {
  const timestamp = Date.now();

  const player1: Player = {
    email: `kick-test-p1-${timestamp}@test.com`,
    username: `kickp1_${timestamp}`,
    displayName: 'Kicker 1',
    password: 'Test123!@#',
  };

  const player2: Player = {
    email: `kick-test-p2-${timestamp}@test.com`,
    username: `kickp2_${timestamp}`,
    displayName: 'Kicker 2',
    password: 'Test123!@#',
  };

  const player3: Player = {
    email: `kick-test-p3-${timestamp}@test.com`,
    username: `kickp3_${timestamp}`,
    displayName: 'To Be Kicked',
    password: 'Test123!@#',
  };

  test.beforeAll(async () => {
    // Register all players
    await registerAndVerifyUser(player1);
    await registerAndVerifyUser(player2);
    await registerAndVerifyUser(player3);

    // Login all players
    await loginViaApi(player1);
    await loginViaApi(player2);
    await loginViaApi(player3);

    // Make them all friends
    await addFriend(player1, player2.userId!);
    await acceptFriendRequest(player2, player1.userId!);

    await addFriend(player1, player3.userId!);
    await acceptFriendRequest(player3, player1.userId!);

    await addFriend(player2, player3.userId!);
    await acceptFriendRequest(player3, player2.userId!);
  });

  test('players can vote to kick another player during active game', async () => {
    // Player 1 creates game
    const gameId = await createGame(player1);
    console.log(`Game created: ${gameId}`);

    // Invite player 2 and 3
    await inviteToGame(player1, gameId, player2.userId!);
    await inviteToGame(player1, gameId, player3.userId!);

    // Start the game (requires WebSocket - use API if available)
    // For now, test the kick vote API directly

    // Player 1 initiates kick vote against player 3
    const initiateRes = await fetch(`${API_URL}/games/${gameId}/kick/initiate`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${player1.accessToken}`,
      },
      body: JSON.stringify({ targetUserId: player3.userId }),
    });

    // Expect the endpoint to exist (will fail until implemented)
    expect(initiateRes.status).toBe(201);

    const voteData = await initiateRes.json();
    const voteId = voteData.voteId;
    expect(voteId).toBeDefined();

    // Player 2 votes to kick
    const vote2Res = await fetch(`${API_URL}/games/${gameId}/kick/vote`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${player2.accessToken}`,
      },
      body: JSON.stringify({ voteId, approve: true }),
    });

    expect(vote2Res.status).toBe(200);

    // Check that player 3 is kicked (all votes received)
    const voteResult = await vote2Res.json();
    expect(voteResult.passed).toBe(true);
    expect(voteResult.playerKicked).toBe(true);

    // Verify player 3 is no longer in the game
    const gameRes = await fetch(`${API_URL}/games/${gameId}`, {
      headers: {
        'Authorization': `Bearer ${player1.accessToken}`,
      },
    });

    const gameData = await gameRes.json();
    const playerIds = gameData.players.map((p: any) => p.user.id);
    expect(playerIds).not.toContain(player3.userId);
    expect(playerIds).toContain(player1.userId);
    expect(playerIds).toContain(player2.userId);
  });

  test('kick vote fails if a player votes against', async () => {
    // Create a new game
    const gameId = await createGame(player1);

    // Invite players
    await inviteToGame(player1, gameId, player2.userId!);
    await inviteToGame(player1, gameId, player3.userId!);

    // Player 1 initiates kick against player 3
    const initiateRes = await fetch(`${API_URL}/games/${gameId}/kick/initiate`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${player1.accessToken}`,
      },
      body: JSON.stringify({ targetUserId: player3.userId }),
    });

    expect(initiateRes.status).toBe(201);
    const voteData = await initiateRes.json();
    const voteId = voteData.voteId;

    // Player 2 votes AGAINST the kick
    const vote2Res = await fetch(`${API_URL}/games/${gameId}/kick/vote`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${player2.accessToken}`,
      },
      body: JSON.stringify({ voteId, approve: false }),
    });

    expect(vote2Res.status).toBe(200);
    const voteResult = await vote2Res.json();
    expect(voteResult.passed).toBe(false);
    expect(voteResult.playerKicked).toBe(false);

    // Verify player 3 is still in the game
    const gameRes = await fetch(`${API_URL}/games/${gameId}`, {
      headers: {
        'Authorization': `Bearer ${player1.accessToken}`,
      },
    });

    const gameData = await gameRes.json();
    const playerIds = gameData.players.map((p: any) => p.user.id);
    expect(playerIds).toContain(player3.userId);
  });

  test('player cannot vote to kick themselves', async () => {
    const gameId = await createGame(player1);
    await inviteToGame(player1, gameId, player2.userId!);

    // Player 1 tries to kick themselves
    const res = await fetch(`${API_URL}/games/${gameId}/kick/initiate`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${player1.accessToken}`,
      },
      body: JSON.stringify({ targetUserId: player1.userId }),
    });

    expect(res.status).toBe(400);
  });

  test('cannot initiate kick if vote already in progress', async () => {
    const gameId = await createGame(player1);
    await inviteToGame(player1, gameId, player2.userId!);
    await inviteToGame(player1, gameId, player3.userId!);

    // First kick vote
    const res1 = await fetch(`${API_URL}/games/${gameId}/kick/initiate`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${player1.accessToken}`,
      },
      body: JSON.stringify({ targetUserId: player3.userId }),
    });

    expect(res1.status).toBe(201);

    // Try to initiate another kick vote while first is pending
    const res2 = await fetch(`${API_URL}/games/${gameId}/kick/initiate`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${player2.accessToken}`,
      },
      body: JSON.stringify({ targetUserId: player1.userId }),
    });

    expect(res2.status).toBe(409); // Conflict - vote already in progress
  });
});

// Skip: isConnected field is only available via WebSocket, not REST API
test.describe.skip('Player Online Status', () => {
  test('game state includes player connection status', async () => {
    const timestamp = Date.now();

    const player: Player = {
      email: `online-test-${timestamp}@test.com`,
      username: `online_${timestamp}`,
      displayName: 'Online Test',
      password: 'Test123!@#',
    };

    await registerAndVerifyUser(player);
    await loginViaApi(player);

    const gameId = await createGame(player);

    // Get game state
    const res = await fetch(`${API_URL}/games/${gameId}`, {
      headers: {
        'Authorization': `Bearer ${player.accessToken}`,
      },
    });

    expect(res.status).toBe(200);
    const gameData = await res.json();

    // Each player should have isConnected field
    for (const p of gameData.players) {
      expect(p).toHaveProperty('isConnected');
      expect(typeof p.isConnected).toBe('boolean');
    }
  });
});
