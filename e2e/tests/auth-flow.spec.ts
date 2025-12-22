import { test, expect } from '@playwright/test';

const API_URL = 'http://localhost:8080';
const MAILPIT_URL = 'http://localhost:8025';

// Helper to generate unique test user
function generateTestUser() {
  const id = Math.random().toString(36).substring(7);
  return {
    email: `test-${id}@test.local`,
    username: `user${id}`,
    displayName: `Test User ${id}`,
    password: 'SecurePass123!',
  };
}

// Helper to get verification token from Mailpit with retry
async function getVerificationToken(email: string): Promise<string> {
  // Retry up to 5 times with 500ms delay
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

test.describe('Authentication Flow', () => {

  test('should register a new user and verify email', async () => {
    const user = generateTestUser();

    // Register
    const signupRes = await fetch(`${API_URL}/auth/signup`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(user),
    });

    expect(signupRes.status).toBe(201);
    const signupData = await signupRes.json();
    expect(signupData.message).toContain('verification');

    // Get verification token from email
    const token = await getVerificationToken(user.email);
    expect(token).toBeTruthy();

    // Verify
    const verifyRes = await fetch(`${API_URL}/auth/verify`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ token }),
    });

    expect(verifyRes.status).toBe(200);
  });

  test('should login with verified user', async () => {
    const user = generateTestUser();

    // Register and verify
    await fetch(`${API_URL}/auth/signup`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(user),
    });

    const token = await getVerificationToken(user.email);
    await fetch(`${API_URL}/auth/verify`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ token }),
    });

    // Login
    const loginRes = await fetch(`${API_URL}/auth/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        email: user.email,
        password: user.password,
      }),
    });

    expect(loginRes.status).toBe(200);
    const loginData = await loginRes.json();
    expect(loginData.accessJwt).toBeTruthy();
    expect(loginData.refreshToken).toBeTruthy();
  });

  test('should reject login with wrong password', async () => {
    const user = generateTestUser();

    // Register and verify
    await fetch(`${API_URL}/auth/signup`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(user),
    });

    const token = await getVerificationToken(user.email);
    await fetch(`${API_URL}/auth/verify`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ token }),
    });

    // Login with wrong password
    const loginRes = await fetch(`${API_URL}/auth/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        email: user.email,
        password: 'wrongpassword',
      }),
    });

    expect(loginRes.status).toBe(401);
  });

  test('should reject login for unverified user', async () => {
    const user = generateTestUser();

    // Register but don't verify
    await fetch(`${API_URL}/auth/signup`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(user),
    });

    // Try to login
    const loginRes = await fetch(`${API_URL}/auth/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        email: user.email,
        password: user.password,
      }),
    });

    // Server returns 401 for unverified users (treated as invalid credentials)
    expect([401, 403]).toContain(loginRes.status);
  });

  test('should request password reset', async () => {
    const user = generateTestUser();

    // Register and verify
    await fetch(`${API_URL}/auth/signup`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(user),
    });

    const verifyToken = await getVerificationToken(user.email);
    await fetch(`${API_URL}/auth/verify`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ token: verifyToken }),
    });

    // Request password reset (don't clear mailpit - just request and verify response)
    const resetRes = await fetch(`${API_URL}/auth/password-reset/request`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email: user.email }),
    });

    expect(resetRes.status).toBe(200);
    const resetData = await resetRes.json();
    expect(resetData.message).toBeDefined();
  });

  test('should refresh access token', async () => {
    const user = generateTestUser();

    // Register, verify, and login
    await fetch(`${API_URL}/auth/signup`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(user),
    });

    const token = await getVerificationToken(user.email);
    await fetch(`${API_URL}/auth/verify`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ token }),
    });

    const loginRes = await fetch(`${API_URL}/auth/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        email: user.email,
        password: user.password,
      }),
    });

    const loginData = await loginRes.json();

    // Refresh token
    const refreshRes = await fetch(`${API_URL}/auth/refresh`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ refreshToken: loginData.refreshToken }),
    });

    expect(refreshRes.status).toBe(200);
    const refreshData = await refreshRes.json();
    expect(refreshData.accessJwt).toBeTruthy();
    expect(refreshData.refreshToken).toBeTruthy();
  });
});
