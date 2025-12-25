import { test, expect, BrowserContext, Page } from '@playwright/test';

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
  // Register via API
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

  // Wait for email to arrive
  await new Promise(r => setTimeout(r, 1000));

  // Get verification token from Mailpit
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

  const token = tokenMatch[1];

  const verifyRes = await fetch(`${API_URL}/auth/verify`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ token }),
  });

  if (verifyRes.status !== 200) {
    throw new Error(`Verification failed: ${verifyRes.status}`);
  }

  console.log(`User ${player.username} registered and verified`);
}

async function loginAndGetToken(player: Player): Promise<void> {
  const res = await fetch(`${API_URL}/auth/login`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      email: player.email,
      password: player.password,
    }),
  });

  if (res.status !== 200) {
    throw new Error(`Login failed for ${player.username}`);
  }

  const data = await res.json();
  player.accessToken = data.accessToken;

  // Get user ID
  const meRes = await fetch(`${API_URL}/users/me`, {
    headers: { 'Authorization': `Bearer ${player.accessToken}` },
  });
  const me = await meRes.json();
  player.userId = me.id;

  console.log(`User ${player.username} logged in, ID: ${player.userId}`);
}

async function createFriendship(player1: Player, player2: Player): Promise<void> {
  // Player1 sends friend request
  const requestRes = await fetch(`${API_URL}/friends/request`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${player1.accessToken}`,
    },
    body: JSON.stringify({ userId: player2.userId }),
  });

  if (requestRes.status !== 201) {
    throw new Error(`Friend request failed: ${requestRes.status}`);
  }

  // Player2 accepts
  const acceptRes = await fetch(`${API_URL}/friends/accept`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${player2.accessToken}`,
    },
    body: JSON.stringify({ userId: player1.userId }),
  });

  if (acceptRes.status !== 200) {
    throw new Error(`Accept friend request failed: ${acceptRes.status}`);
  }

  console.log(`${player1.username} and ${player2.username} are now friends`);
}

async function createGameViaApi(host: Player): Promise<string> {
  const res = await fetch(`${API_URL}/games/`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${host.accessToken}`,
    },
    body: JSON.stringify({ maxPlayers: 4 }),
  });

  if (res.status !== 201) {
    throw new Error(`Failed to create game`);
  }

  const data = await res.json();
  console.log(`Game created: ${data.gameId}`);
  return data.gameId;
}

async function invitePlayerViaApi(inviter: Player, gameId: string, inviteeUserId: string): Promise<void> {
  const res = await fetch(`${API_URL}/games/${gameId}/invite`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${inviter.accessToken}`,
    },
    body: JSON.stringify({ userId: inviteeUserId }),
  });

  if (res.status !== 200) {
    const text = await res.text();
    throw new Error(`Failed to invite player: ${res.status} ${text}`);
  }

  console.log(`Invited user ${inviteeUserId} to game ${gameId}`);
}

test.describe('Game Invite Friend Flow', () => {
  let player1: Player;
  let player2: Player;

  test.beforeEach(async () => {
    // Use unique emails/usernames per test to avoid conflicts
    const timestamp = Date.now();
    player1 = {
      email: `host${timestamp}@test.com`,
      username: `host${timestamp}`,
      displayName: 'Host Player',
      password: 'TestPass123!',
    };
    player2 = {
      email: `guest${timestamp}@test.com`,
      username: `guest${timestamp}`,
      displayName: 'Guest Player',
      password: 'TestPass123!',
    };
  });

  test('can invite a friend to game after accepting friend request', async ({ browser }) => {
    // This test verifies the fix for "Too many elements" error when inviting friends
    // The bug occurred because accepted friendships create two rows in the database

    // Step 1: Register and verify both users
    await registerAndVerifyUser(player1);
    await registerAndVerifyUser(player2);

    // Step 2: Login both users
    await loginAndGetToken(player1);
    await loginAndGetToken(player2);

    // Step 3: Create friendship (this creates TWO rows in friendships table)
    await createFriendship(player1, player2);

    // Step 4: Create game
    const gameId = await createGameViaApi(player1);

    // Step 5: Invite player2 - this was failing with "Too many elements" before fix
    await invitePlayerViaApi(player1, gameId, player2.userId!);

    // Step 6: Verify game has both players
    const gameRes = await fetch(`${API_URL}/games/${gameId}`, {
      headers: { 'Authorization': `Bearer ${player1.accessToken}` },
    });
    const game = await gameRes.json();

    expect(game.players.length).toBe(2);
    const playerIds = game.players.map((p: any) => p.user.id);
    expect(playerIds).toContain(player1.userId);
    expect(playerIds).toContain(player2.userId);

    console.log('Game successfully created with both players!');
  });

  test('can start a game after inviting a friend', async ({ browser }) => {
    // Register and setup
    await registerAndVerifyUser(player1);
    await registerAndVerifyUser(player2);
    await loginAndGetToken(player1);
    await loginAndGetToken(player2);
    await createFriendship(player1, player2);

    const gameId = await createGameViaApi(player1);
    await invitePlayerViaApi(player1, gameId, player2.userId!);

    // Create browser contexts for each player
    player1.context = await browser.newContext();
    player2.context = await browser.newContext();
    player1.page = await player1.context.newPage();
    player2.page = await player2.context.newPage();

    // Login via UI and join the game lobby
    const viewport = { width: 1280, height: 720 };
    await player1.page.setViewportSize(viewport);
    await player2.page.setViewportSize(viewport);

    // Login player1 via UI
    await player1.page.goto('/');
    await player1.page.waitForTimeout(4000);
    const centerX = viewport.width / 2;

    // Type email
    await player1.page.mouse.click(centerX, viewport.height * 0.42);
    await player1.page.waitForTimeout(500);
    await player1.page.keyboard.type(player1.email, { delay: 20 });

    // Type password
    await player1.page.mouse.click(centerX, viewport.height * 0.52);
    await player1.page.waitForTimeout(500);
    await player1.page.keyboard.type(player1.password, { delay: 20 });

    // Click login
    await player1.page.mouse.click(centerX, viewport.height * 0.65);
    await player1.page.waitForTimeout(3000);

    // Navigate to game
    await player1.page.goto(`/#/games/${gameId}`);
    await player1.page.waitForTimeout(3000);
    await player1.page.screenshot({ path: 'test-results/invite-friend-lobby.png' });

    // Login player2 via UI
    await player2.page.goto('/');
    await player2.page.waitForTimeout(4000);

    await player2.page.mouse.click(centerX, viewport.height * 0.42);
    await player2.page.waitForTimeout(500);
    await player2.page.keyboard.type(player2.email, { delay: 20 });

    await player2.page.mouse.click(centerX, viewport.height * 0.52);
    await player2.page.waitForTimeout(500);
    await player2.page.keyboard.type(player2.password, { delay: 20 });

    await player2.page.mouse.click(centerX, viewport.height * 0.65);
    await player2.page.waitForTimeout(3000);

    // Player2 navigates to the game
    await player2.page.goto(`/#/games/${gameId}`);
    await player2.page.waitForTimeout(3000);
    await player2.page.screenshot({ path: 'test-results/invite-friend-lobby-player2.png' });

    // Host starts the game
    await player1.page.mouse.click(centerX, viewport.height * 0.62);
    await player1.page.waitForTimeout(3000);
    await player1.page.screenshot({ path: 'test-results/invite-friend-game-started.png' });

    // Verify both players see the game screen
    await player2.page.waitForTimeout(2000);
    await player2.page.screenshot({ path: 'test-results/invite-friend-player2-game.png' });

    console.log('Game started successfully with invited friend!');

    // Cleanup
    await player1.context.close();
    await player2.context.close();
  });
});
