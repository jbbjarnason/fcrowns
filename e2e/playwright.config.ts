import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './tests',
  fullyParallel: false,
  forbidOnly: !!process.env.CI,
  retries: 0,
  workers: 1,
  reporter: 'html',
  timeout: 180000,
  use: {
    baseURL: 'http://localhost:3000',
    trace: 'on-first-retry',
    headless: !!process.env.CI,
    video: 'on',
    // Permissions for media
    permissions: ['microphone', 'camera'],
    // Launch options for fake media
    launchOptions: {
      args: [
        '--use-fake-device-for-media-stream',
        '--use-fake-ui-for-media-stream',
        '--allow-file-access',
        '--disable-web-security',
      ],
    },
  },
  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
  ],
  webServer: {
    command: 'npx serve ../app/build/web -l 3000',
    url: 'http://localhost:3000',
    reuseExistingServer: true,
    timeout: 60000,
  },
});
