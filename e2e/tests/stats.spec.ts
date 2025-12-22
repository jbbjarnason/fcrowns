import { test, expect } from '@playwright/test';

const API_URL = 'http://localhost:8080';
const MAILPIT_URL = 'http://localhost:8025';

// Helper to create and verify a user, returning the access token
async function createVerifiedUser(suffix: string): Promise<{ accessToken: string; userId: string }> {
  const user = {
    email: `stats${suffix}@test.local`,
    username: `stats${suffix}`,
    displayName: `Stats User ${suffix}`,
    password: 'password123',
  };

  // Register
  const signupRes = await fetch(`${API_URL}/auth/signup`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(user),
  });

  if (signupRes.status !== 201) {
    // User might already exist, try to login
    const loginRes = await fetch(`${API_URL}/auth/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email: user.email, password: user.password }),
    });

    if (loginRes.status === 200) {
      const loginData = await loginRes.json();
      const meRes = await fetch(`${API_URL}/users/me`, {
        headers: { 'Authorization': `Bearer ${loginData.accessJwt}` },
      });
      const meData = await meRes.json();
      return { accessToken: loginData.accessJwt, userId: meData.id };
    }
    throw new Error(`Failed to create user: ${signupRes.status}`);
  }

  // Wait for email and get verification token
  await new Promise(r => setTimeout(r, 1000));
  const messagesRes = await fetch(`${MAILPIT_URL}/api/v1/search?query=to:${user.email}`);
  const messages = await messagesRes.json();

  if (!messages.messages || messages.messages.length === 0) {
    throw new Error(`No verification email for ${user.email}`);
  }

  const messageId = messages.messages[0].ID;
  const messageRes = await fetch(`${MAILPIT_URL}/api/v1/message/${messageId}`);
  const message = await messageRes.json();
  const tokenMatch = message.Text?.match(/token=([a-zA-Z0-9-]+)/);

  if (!tokenMatch) {
    throw new Error('No verification token found');
  }

  // Verify
  await fetch(`${API_URL}/auth/verify`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ token: tokenMatch[1] }),
  });

  // Login
  const loginRes = await fetch(`${API_URL}/auth/login`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email: user.email, password: user.password }),
  });

  const loginData = await loginRes.json();

  // Get user ID
  const meRes = await fetch(`${API_URL}/users/me`, {
    headers: { 'Authorization': `Bearer ${loginData.accessJwt}` },
  });
  const meData = await meRes.json();

  return { accessToken: loginData.accessJwt, userId: meData.id };
}

test.describe('Stats API', () => {

  test('should return empty stats for new user', async () => {
    const id = Date.now().toString(36);
    const { accessToken } = await createVerifiedUser(`new${id}`);

    const res = await fetch(`${API_URL}/users/me/stats`, {
      headers: { 'Authorization': `Bearer ${accessToken}` },
    });

    expect(res.status).toBe(200);
    const data = await res.json();

    expect(data.overall).toBeDefined();
    expect(data.overall.gamesPlayed).toBe(0);
    expect(data.overall.gamesWon).toBe(0);
    expect(data.groups).toBeDefined();
    expect(Array.isArray(data.groups)).toBe(true);
  });

  test('should require authentication for stats', async () => {
    const res = await fetch(`${API_URL}/users/me/stats`);
    expect(res.status).toBe(401);
  });

  test('should require authentication for group stats', async () => {
    const res = await fetch(`${API_URL}/users/me/stats/some-group-key`);
    expect(res.status).toBe(401);
  });

  test('should return error for non-existent group', async () => {
    const id = Date.now().toString(36);
    const { accessToken } = await createVerifiedUser(`nogroup${id}`);

    const res = await fetch(`${API_URL}/users/me/stats/non-existent-group-key`, {
      headers: { 'Authorization': `Bearer ${accessToken}` },
    });

    // Could be 404 (not found) or 403 (not authorized to view this group)
    expect([403, 404]).toContain(res.status);
  });
});

test.describe('Game Creation for Stats', () => {

  test('should create game and track in user games', async () => {
    const id = Date.now().toString(36);
    const { accessToken, userId } = await createVerifiedUser(`creator${id}`);

    // Create a game
    const createRes = await fetch(`${API_URL}/games/`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${accessToken}`,
      },
      body: JSON.stringify({ maxPlayers: 4 }),
    });

    expect(createRes.status).toBe(201);
    const gameData = await createRes.json();
    expect(gameData.gameId).toBeDefined();

    // Get user's games
    const gamesRes = await fetch(`${API_URL}/games/`, {
      headers: { 'Authorization': `Bearer ${accessToken}` },
    });

    expect(gamesRes.status).toBe(200);
    const gamesData = await gamesRes.json();
    expect(gamesData.games).toBeDefined();
    expect(gamesData.games.length).toBeGreaterThan(0);

    // Find the created game
    const createdGame = gamesData.games.find((g: any) => g.id === gameData.gameId);
    expect(createdGame).toBeDefined();
  });
});

test.describe('Friends API', () => {

  test('should return friends list for authenticated user', async () => {
    const id = Date.now().toString(36);
    const { accessToken } = await createVerifiedUser(`lonely${id}`);

    const res = await fetch(`${API_URL}/friends/`, {
      headers: { 'Authorization': `Bearer ${accessToken}` },
    });

    expect(res.status).toBe(200);
    const data = await res.json();

    // Verify response has friends array (structure may vary)
    expect(data).toBeDefined();
    expect(data.friends).toBeDefined();
    expect(Array.isArray(data.friends)).toBe(true);
  });

  test('should send friend request', async () => {
    const id = Date.now().toString(36);
    const user1 = await createVerifiedUser(`friend1${id}`);
    const user2 = await createVerifiedUser(`friend2${id}`);

    // User1 sends friend request to User2
    const res = await fetch(`${API_URL}/friends/request`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${user1.accessToken}`,
      },
      body: JSON.stringify({ userId: user2.userId }),
    });

    expect([200, 201]).toContain(res.status);
  });

  test('should accept friend request', async () => {
    const id = Date.now().toString(36);
    const user1 = await createVerifiedUser(`accept1${id}`);
    const user2 = await createVerifiedUser(`accept2${id}`);

    // User1 sends friend request to User2
    await fetch(`${API_URL}/friends/request`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${user1.accessToken}`,
      },
      body: JSON.stringify({ userId: user2.userId }),
    });

    // User2 accepts
    const acceptRes = await fetch(`${API_URL}/friends/accept`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${user2.accessToken}`,
      },
      body: JSON.stringify({ userId: user1.userId }),
    });

    expect(acceptRes.status).toBe(200);

    // Verify both are now friends
    const friends1Res = await fetch(`${API_URL}/friends/`, {
      headers: { 'Authorization': `Bearer ${user1.accessToken}` },
    });
    const friends1Data = await friends1Res.json();
    expect(friends1Data.friends.length).toBeGreaterThan(0);
  });

  test('should search for users', async () => {
    const id = Date.now().toString(36);
    const { accessToken } = await createVerifiedUser(`searcher${id}`);

    // Search API should work with any query
    const res = await fetch(`${API_URL}/users/search?username=test`, {
      headers: { 'Authorization': `Bearer ${accessToken}` },
    });

    expect(res.status).toBe(200);
    const data = await res.json();
    expect(data.users).toBeDefined();
    expect(Array.isArray(data.users)).toBe(true);
  });
});
