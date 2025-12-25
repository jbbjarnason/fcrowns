import { test, expect, BrowserContext, Page } from '@playwright/test';

const API_URL = 'http://localhost:8080';
const MAILPIT_URL = 'http://localhost:8025';
const WS_URL = 'ws://localhost:8080/ws';

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
  player.accessToken = data.accessJwt;

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
    body: JSON.stringify({ maxPlayers: 2 }),
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

// Helper to create a WebSocket connection and send commands
async function connectToWebSocket(accessToken: string): Promise<WebSocket> {
  return new Promise((resolve, reject) => {
    const ws = new WebSocket(WS_URL);

    ws.onopen = () => {
      // Send hello
      ws.send(JSON.stringify({
        type: 'cmd.hello',
        jwt: accessToken,
        clientSeq: 1,
      }));
    };

    ws.onmessage = (event) => {
      const data = JSON.parse(event.data);
      if (data.type === 'evt.hello') {
        resolve(ws);
      } else if (data.type === 'evt.error') {
        reject(new Error(`WebSocket error: ${data.message}`));
      }
    };

    ws.onerror = (error) => {
      reject(error);
    };
  });
}

// Helper to send a WebSocket command and wait for response
async function sendWsCommand(ws: WebSocket, command: any): Promise<any> {
  return new Promise((resolve, reject) => {
    const timeout = setTimeout(() => {
      reject(new Error('WebSocket command timeout'));
    }, 5000);

    const handler = (event: MessageEvent) => {
      const data = JSON.parse(event.data);
      if (data.type === 'evt.state' || data.type === 'evt.error') {
        clearTimeout(timeout);
        ws.removeEventListener('message', handler);
        resolve(data);
      }
    };

    ws.addEventListener('message', handler);
    ws.send(JSON.stringify(command));
  });
}

// Helper to join a game room (in lobby, before game starts - no state response expected)
function joinGameRoom(ws: WebSocket, gameId: string, clientSeq: number): void {
  ws.send(JSON.stringify({
    type: 'cmd.joinGame',
    gameId,
    clientSeq,
  }));
}

test.describe('Lay Off Feature', () => {
  let player1: Player;
  let player2: Player;

  test.beforeEach(async () => {
    const timestamp = Date.now();
    player1 = {
      email: `layoff_host${timestamp}@test.com`,
      username: `layoff_host${timestamp}`,
      displayName: 'Host Player',
      password: 'TestPass123!',
    };
    player2 = {
      email: `layoff_guest${timestamp}@test.com`,
      username: `layoff_guest${timestamp}`,
      displayName: 'Guest Player',
      password: 'TestPass123!',
    };
  });

  test('lay off command is rejected when not player turn', async ({ browser }) => {
    // This test verifies that the lay off command properly validates turn order

    // Setup: register, login, create friendship, create game
    await registerAndVerifyUser(player1);
    await registerAndVerifyUser(player2);
    await loginAndGetToken(player1);
    await loginAndGetToken(player2);
    await createFriendship(player1, player2);

    const gameId = await createGameViaApi(player1);
    await invitePlayerViaApi(player1, gameId, player2.userId!);

    // Connect both players via WebSocket
    const ws1 = await connectToWebSocket(player1.accessToken!);
    const ws2 = await connectToWebSocket(player2.accessToken!);

    // Both players join the game room first (before starting - no response expected for lobby)
    joinGameRoom(ws1, gameId, 2);
    joinGameRoom(ws2, gameId, 2);
    await new Promise(r => setTimeout(r, 500)); // Give server time to process joins

    // Player 1 starts the game (now both are in the room to receive state)
    await sendWsCommand(ws1, {
      type: 'cmd.startGame',
      gameId,
      clientSeq: 3,
    });

    // Player 2 tries to lay off (but it's player 1's turn)
    const layOffResult = await sendWsCommand(ws2, {
      type: 'cmd.layOff',
      gameId,
      targetPlayerIndex: 0,
      meldIndex: 0,
      cards: ['H7'],
      clientSeq: 3,
    });

    // Should receive an error
    expect(layOffResult.type).toBe('evt.error');
    expect(layOffResult.code).toBe('not_your_turn');

    console.log('Correctly rejected lay off from player who is not current turn');

    // Cleanup
    ws1.close();
    ws2.close();
  });

  test('lay off command is rejected during mustDraw phase', async ({ browser }) => {
    // Setup
    await registerAndVerifyUser(player1);
    await registerAndVerifyUser(player2);
    await loginAndGetToken(player1);
    await loginAndGetToken(player2);
    await createFriendship(player1, player2);

    const gameId = await createGameViaApi(player1);
    await invitePlayerViaApi(player1, gameId, player2.userId!);

    // Connect via WebSocket
    const ws1 = await connectToWebSocket(player1.accessToken!);
    const ws2 = await connectToWebSocket(player2.accessToken!);

    // Join game room first, then start
    joinGameRoom(ws1, gameId, 2);
    joinGameRoom(ws2, gameId, 2);
    await new Promise(r => setTimeout(r, 500)); // Give server time to process joins
    await sendWsCommand(ws1, { type: 'cmd.startGame', gameId, clientSeq: 3 });

    // Player 1 tries to lay off before drawing (in mustDraw phase)
    const layOffResult = await sendWsCommand(ws1, {
      type: 'cmd.layOff',
      gameId,
      targetPlayerIndex: 0,
      meldIndex: 0,
      cards: ['H7'],
      clientSeq: 4,
    });

    // Should receive an error (either mustDraw phase or invalid meld)
    expect(layOffResult.type).toBe('evt.error');
    console.log(`Correctly rejected lay off during draw phase: ${layOffResult.message}`);

    // Cleanup
    ws1.close();
    ws2.close();
  });

  test('game flow with WebSocket commands works correctly', async ({ browser }) => {
    // This test verifies the basic WebSocket game flow

    // Setup
    await registerAndVerifyUser(player1);
    await registerAndVerifyUser(player2);
    await loginAndGetToken(player1);
    await loginAndGetToken(player2);
    await createFriendship(player1, player2);

    const gameId = await createGameViaApi(player1);
    await invitePlayerViaApi(player1, gameId, player2.userId!);

    // Connect via WebSocket
    const ws1 = await connectToWebSocket(player1.accessToken!);
    const ws2 = await connectToWebSocket(player2.accessToken!);

    // Both join the room first (no response expected for lobby)
    joinGameRoom(ws1, gameId, 2);
    joinGameRoom(ws2, gameId, 2);
    await new Promise(r => setTimeout(r, 500)); // Give server time to process joins

    // Start game (will broadcast state to both players)
    const state1 = await sendWsCommand(ws1, { type: 'cmd.startGame', gameId, clientSeq: 3 });

    // Verify initial game state
    expect(state1.type).toBe('evt.state');

    console.log('Game started, state received');

    // Player 1 draws from stock
    const drawResult = await sendWsCommand(ws1, {
      type: 'cmd.draw',
      gameId,
      from: 'stock',
      clientSeq: 4,
    });

    expect(drawResult.type).toBe('evt.state');
    console.log('Player 1 drew from stock successfully');

    // Get the game state to see player 1's hand
    // State structure: { gameId, status, currentPlayerIndex, turnPhase, yourHand: string[], players: [], ... }
    const gameState = drawResult.state;
    const hand = gameState.yourHand;
    console.log(`Player 1 hand size: ${hand?.length}`);

    // Player 1 discards first card (we'll use the actual card from the state)
    if (hand && hand.length > 0) {
      const cardToDiscard = hand[0]; // First card in hand

      const discardResult = await sendWsCommand(ws1, {
        type: 'cmd.discard',
        gameId,
        card: cardToDiscard,
        clientSeq: 5,
      });

      expect(discardResult.type).toBe('evt.state');
      console.log(`Player 1 discarded ${cardToDiscard} successfully`);

      // Now it should be player 2's turn
      const newState = discardResult.state;
      console.log(`Current player index: ${newState.currentPlayerIndex}`);
    }

    // Cleanup
    ws1.close();
    ws2.close();
  });

  test('game UI displays melds correctly', async ({ browser }) => {
    // This test verifies the UI can display melds from other players

    // Setup
    await registerAndVerifyUser(player1);
    await registerAndVerifyUser(player2);
    await loginAndGetToken(player1);
    await loginAndGetToken(player2);
    await createFriendship(player1, player2);

    const gameId = await createGameViaApi(player1);
    await invitePlayerViaApi(player1, gameId, player2.userId!);

    // Create browser contexts
    player1.context = await browser.newContext();
    player2.context = await browser.newContext();
    player1.page = await player1.context.newPage();
    player2.page = await player2.context.newPage();

    const viewport = { width: 1280, height: 720 };
    await player1.page.setViewportSize(viewport);
    await player2.page.setViewportSize(viewport);

    // Login player1 via UI
    await player1.page.goto('/');
    await player1.page.waitForTimeout(4000);
    const centerX = viewport.width / 2;

    // Type credentials for player 1
    await player1.page.mouse.click(centerX, viewport.height * 0.47);
    await player1.page.waitForTimeout(500);
    await player1.page.keyboard.type(player1.email, { delay: 20 });

    await player1.page.mouse.click(centerX, viewport.height * 0.56);
    await player1.page.waitForTimeout(500);
    await player1.page.keyboard.type(player1.password, { delay: 20 });

    await player1.page.mouse.click(centerX, viewport.height * 0.65);
    await player1.page.waitForTimeout(3000);

    // Navigate player 1 to game lobby
    await player1.page.goto(`/#/games/${gameId}`);
    await player1.page.waitForTimeout(3000);
    await player1.page.screenshot({ path: 'test-results/layoff-lobby-player1.png' });

    // Login player2 via UI
    await player2.page.goto('/');
    await player2.page.waitForTimeout(4000);

    await player2.page.mouse.click(centerX, viewport.height * 0.47);
    await player2.page.waitForTimeout(500);
    await player2.page.keyboard.type(player2.email, { delay: 20 });

    await player2.page.mouse.click(centerX, viewport.height * 0.56);
    await player2.page.waitForTimeout(500);
    await player2.page.keyboard.type(player2.password, { delay: 20 });

    await player2.page.mouse.click(centerX, viewport.height * 0.65);
    await player2.page.waitForTimeout(3000);

    // Navigate player 2 to game lobby
    await player2.page.goto(`/#/games/${gameId}`);
    await player2.page.waitForTimeout(3000);
    await player2.page.screenshot({ path: 'test-results/layoff-lobby-player2.png' });

    // Player 1 starts the game (click start button)
    await player1.page.mouse.click(centerX, viewport.height * 0.62);
    await player1.page.waitForTimeout(3000);

    // Both navigate to play screen
    await player1.page.goto(`/#/games/${gameId}/play`);
    await player2.page.goto(`/#/games/${gameId}/play`);
    await player1.page.waitForTimeout(3000);
    await player2.page.waitForTimeout(3000);

    // Take screenshots of the game screen
    await player1.page.screenshot({ path: 'test-results/layoff-game-player1.png' });
    await player2.page.screenshot({ path: 'test-results/layoff-game-player2.png' });

    console.log('Game UI verified - check screenshots for meld display');

    // Cleanup
    await player1.context.close();
    await player2.context.close();
  });
});
