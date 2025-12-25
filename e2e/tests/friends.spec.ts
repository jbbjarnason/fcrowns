import { test, expect } from '@playwright/test';

const API_URL = 'http://localhost:8080';
const MAILPIT_URL = 'http://localhost:8025';

// Helper to generate unique test user
function generateTestUser(suffix: string) {
  const id = Math.random().toString(36).substring(7);
  return {
    email: `friend-${suffix}-${id}@test.local`,
    username: `friend${suffix}${id}`,
    displayName: `Friend ${suffix.toUpperCase()} User`,
    password: 'SecurePass123!',
  };
}

// Helper to get verification token from Mailpit with retry
async function getVerificationToken(email: string): Promise<string> {
  for (let i = 0; i < 5; i++) {
    await new Promise(r => setTimeout(r, 500));

    const messagesRes = await fetch(`${MAILPIT_URL}/api/v1/search?query=to:${email}`);
    const messages = await messagesRes.json();

    if (messages.messages && messages.messages.length > 0) {
      const messageId = messages.messages[0].ID;
      const messageRes = await fetch(`${MAILPIT_URL}/api/v1/message/${messageId}`);
      const message = await messageRes.json();

      const tokenMatch = message.Text?.match(/token=([a-zA-Z0-9-]+)/) ||
                         message.HTML?.match(/token=([a-zA-Z0-9-]+)/);

      if (tokenMatch) {
        return tokenMatch[1];
      }
    }
  }

  throw new Error(`No verification email found for ${email} after retries`);
}

// Helper to create and verify a user, returning access token
async function createVerifiedUser(userData: ReturnType<typeof generateTestUser>): Promise<{ token: string; userId: string }> {
  // Register
  const signupRes = await fetch(`${API_URL}/auth/signup`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(userData),
  });

  if (signupRes.status !== 201) {
    throw new Error(`Signup failed: ${signupRes.status}`);
  }

  // Get verification token and verify
  const verifyToken = await getVerificationToken(userData.email);
  await fetch(`${API_URL}/auth/verify`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ token: verifyToken }),
  });

  // Login
  const loginRes = await fetch(`${API_URL}/auth/login`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      email: userData.email,
      password: userData.password,
    }),
  });

  const loginData = await loginRes.json();

  // Get user ID
  const meRes = await fetch(`${API_URL}/users/me`, {
    headers: { 'Authorization': `Bearer ${loginData.accessJwt}` },
  });
  const meData = await meRes.json();

  return { token: loginData.accessJwt, userId: meData.id };
}

test.describe('Friend Request Flow', () => {
  let user1: ReturnType<typeof generateTestUser>;
  let user2: ReturnType<typeof generateTestUser>;
  let user1Auth: { token: string; userId: string };
  let user2Auth: { token: string; userId: string };

  test.beforeEach(async () => {
    // Create two test users
    user1 = generateTestUser('alice');
    user2 = generateTestUser('bob');

    user1Auth = await createVerifiedUser(user1);
    user2Auth = await createVerifiedUser(user2);
  });

  test('should send and accept friend request with correct names', async () => {
    // User1 searches for User2 by full username (avoid ambiguous partial match)
    const searchRes = await fetch(`${API_URL}/users/search?username=${user2.username}`, {
      headers: { 'Authorization': `Bearer ${user1Auth.token}` },
    });
    expect(searchRes.status).toBe(200);

    const searchData = await searchRes.json();
    const foundUser = searchData.users.find((u: any) => u.username === user2.username);
    expect(foundUser).toBeDefined();
    expect(foundUser.displayName).toBe(user2.displayName);

    // User1 sends friend request to User2
    const requestRes = await fetch(`${API_URL}/friends/request`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${user1Auth.token}`,
      },
      body: JSON.stringify({ userId: user2Auth.userId }),
    });
    expect(requestRes.status).toBe(201);

    const requestData = await requestRes.json();
    expect(requestData.status).toBe('pending');

    // User1 checks pending outgoing requests
    const user1FriendsRes = await fetch(`${API_URL}/friends/`, {
      headers: { 'Authorization': `Bearer ${user1Auth.token}` },
    });
    expect(user1FriendsRes.status).toBe(200);

    const user1FriendsData = await user1FriendsRes.json();
    expect(user1FriendsData.pendingOutgoing.length).toBe(1);
    expect(user1FriendsData.pendingOutgoing[0].user.username).toBe(user2.username);
    expect(user1FriendsData.pendingOutgoing[0].user.displayName).toBe(user2.displayName);
    expect(user1FriendsData.friends.length).toBe(0);

    // User2 checks pending incoming requests
    const user2FriendsRes = await fetch(`${API_URL}/friends/`, {
      headers: { 'Authorization': `Bearer ${user2Auth.token}` },
    });
    expect(user2FriendsRes.status).toBe(200);

    const user2FriendsData = await user2FriendsRes.json();
    expect(user2FriendsData.pendingIncoming.length).toBe(1);
    expect(user2FriendsData.pendingIncoming[0].user.username).toBe(user1.username);
    expect(user2FriendsData.pendingIncoming[0].user.displayName).toBe(user1.displayName);
    expect(user2FriendsData.pendingIncoming[0].incomingRequest).toBe(true);

    // User2 accepts friend request
    const acceptRes = await fetch(`${API_URL}/friends/accept`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${user2Auth.token}`,
      },
      body: JSON.stringify({ userId: user1Auth.userId }),
    });
    expect(acceptRes.status).toBe(200);

    const acceptData = await acceptRes.json();
    expect(acceptData.status).toBe('accepted');

    // Verify both users now show each other as friends
    const user1FinalRes = await fetch(`${API_URL}/friends/`, {
      headers: { 'Authorization': `Bearer ${user1Auth.token}` },
    });
    const user1FinalData = await user1FinalRes.json();

    expect(user1FinalData.friends.length).toBe(1);
    expect(user1FinalData.friends[0].user.username).toBe(user2.username);
    expect(user1FinalData.friends[0].user.displayName).toBe(user2.displayName);
    expect(user1FinalData.pendingOutgoing.length).toBe(0);

    const user2FinalRes = await fetch(`${API_URL}/friends/`, {
      headers: { 'Authorization': `Bearer ${user2Auth.token}` },
    });
    const user2FinalData = await user2FinalRes.json();

    expect(user2FinalData.friends.length).toBe(1);
    expect(user2FinalData.friends[0].user.username).toBe(user1.username);
    expect(user2FinalData.friends[0].user.displayName).toBe(user1.displayName);
    expect(user2FinalData.pendingIncoming.length).toBe(0);
  });

  test('should decline friend request', async () => {
    // User1 sends friend request to User2
    await fetch(`${API_URL}/friends/request`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${user1Auth.token}`,
      },
      body: JSON.stringify({ userId: user2Auth.userId }),
    });

    // User2 declines the request
    const declineRes = await fetch(`${API_URL}/friends/decline`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${user2Auth.token}`,
      },
      body: JSON.stringify({ userId: user1Auth.userId }),
    });
    expect(declineRes.status).toBe(200);

    const declineData = await declineRes.json();
    expect(declineData.status).toBe('declined');

    // Verify no friendship exists
    const user1FriendsRes = await fetch(`${API_URL}/friends/`, {
      headers: { 'Authorization': `Bearer ${user1Auth.token}` },
    });
    const user1FriendsData = await user1FriendsRes.json();

    expect(user1FriendsData.friends.length).toBe(0);
    expect(user1FriendsData.pendingOutgoing.length).toBe(0);
  });

  test('should auto-accept mutual friend requests', async () => {
    // User1 sends friend request to User2
    await fetch(`${API_URL}/friends/request`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${user1Auth.token}`,
      },
      body: JSON.stringify({ userId: user2Auth.userId }),
    });

    // User2 also sends friend request to User1 (before accepting)
    const mutualRes = await fetch(`${API_URL}/friends/request`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${user2Auth.token}`,
      },
      body: JSON.stringify({ userId: user1Auth.userId }),
    });
    expect(mutualRes.status).toBe(200);

    const mutualData = await mutualRes.json();
    expect(mutualData.status).toBe('accepted'); // Auto-accepted

    // Both should now be friends
    const user1FriendsRes = await fetch(`${API_URL}/friends/`, {
      headers: { 'Authorization': `Bearer ${user1Auth.token}` },
    });
    const user1FriendsData = await user1FriendsRes.json();

    expect(user1FriendsData.friends.length).toBe(1);
    expect(user1FriendsData.friends[0].user.displayName).toBe(user2.displayName);
  });

  test('should remove friend', async () => {
    // Become friends first
    await fetch(`${API_URL}/friends/request`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${user1Auth.token}`,
      },
      body: JSON.stringify({ userId: user2Auth.userId }),
    });

    await fetch(`${API_URL}/friends/accept`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${user2Auth.token}`,
      },
      body: JSON.stringify({ userId: user1Auth.userId }),
    });

    // User1 removes User2
    const removeRes = await fetch(`${API_URL}/friends/${user2Auth.userId}`, {
      method: 'DELETE',
      headers: { 'Authorization': `Bearer ${user1Auth.token}` },
    });
    expect(removeRes.status).toBe(200);

    // Both should have no friends
    const user1FriendsRes = await fetch(`${API_URL}/friends/`, {
      headers: { 'Authorization': `Bearer ${user1Auth.token}` },
    });
    const user1FriendsData = await user1FriendsRes.json();
    expect(user1FriendsData.friends.length).toBe(0);

    const user2FriendsRes = await fetch(`${API_URL}/friends/`, {
      headers: { 'Authorization': `Bearer ${user2Auth.token}` },
    });
    const user2FriendsData = await user2FriendsRes.json();
    expect(user2FriendsData.friends.length).toBe(0);
  });

  test('should block user and prevent friend requests', async () => {
    // User1 blocks User2
    const blockRes = await fetch(`${API_URL}/friends/block`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${user1Auth.token}`,
      },
      body: JSON.stringify({ userId: user2Auth.userId }),
    });
    expect(blockRes.status).toBe(200);

    // User2 tries to send friend request to User1
    const requestRes = await fetch(`${API_URL}/friends/request`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${user2Auth.token}`,
      },
      body: JSON.stringify({ userId: user1Auth.userId }),
    });
    expect(requestRes.status).toBe(403);
  });

  test('should not allow friend request to self', async () => {
    const requestRes = await fetch(`${API_URL}/friends/request`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${user1Auth.token}`,
      },
      body: JSON.stringify({ userId: user1Auth.userId }),
    });
    expect(requestRes.status).toBe(400);
  });

  test('should not allow duplicate friend request', async () => {
    // First request
    await fetch(`${API_URL}/friends/request`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${user1Auth.token}`,
      },
      body: JSON.stringify({ userId: user2Auth.userId }),
    });

    // Duplicate request
    const duplicateRes = await fetch(`${API_URL}/friends/request`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${user1Auth.token}`,
      },
      body: JSON.stringify({ userId: user2Auth.userId }),
    });
    expect(duplicateRes.status).toBe(409);
  });

  test('should return 404 for non-existent user', async () => {
    const requestRes = await fetch(`${API_URL}/friends/request`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${user1Auth.token}`,
      },
      body: JSON.stringify({ userId: '00000000-0000-0000-0000-000000000000' }),
    });
    expect(requestRes.status).toBe(404);
  });
});
