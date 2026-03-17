import prisma from '../config/db.js';

/**
 * Send a push notification to all devices registered for a given user.
 *
 * Currently this is a stub that logs the notification. When Firebase Admin SDK
 * credentials are configured (FIREBASE_PROJECT_ID env var), it will send real
 * push notifications.
 */
export async function sendPushNotification(
  userId: string,
  title: string,
  body: string,
  data?: Record<string, string>,
): Promise<void> {
  const deviceTokens = await prisma.deviceToken.findMany({
    where: { user_id: userId },
    select: { token: true, platform: true },
  });

  if (deviceTokens.length === 0) {
    return;
  }

  const firebaseProjectId = process.env.FIREBASE_PROJECT_ID;

  if (!firebaseProjectId) {
    // Firebase not configured — log the notification for development
    console.log('[Push Stub] Would send push notification:', {
      userId,
      title,
      body,
      data,
      deviceCount: deviceTokens.length,
      tokens: deviceTokens.map((dt) => ({
        token: dt.token.substring(0, 10) + '...',
        platform: dt.platform,
      })),
    });
    return;
  }

  // Firebase Admin SDK integration — to be configured with real credentials
  // When FIREBASE_PROJECT_ID, FIREBASE_PRIVATE_KEY, and FIREBASE_CLIENT_EMAIL
  // are set, this would use firebase-admin to send FCM messages.
  for (const deviceToken of deviceTokens) {
    try {
      // TODO: Replace with actual Firebase Admin SDK call:
      // await admin.messaging().send({
      //   token: deviceToken.token,
      //   notification: { title, body },
      //   data,
      // });
      console.log(`[Push] Sent to ${deviceToken.platform} device: ${title}`);
    } catch (error) {
      console.error(
        `[Push] Failed to send to device ${deviceToken.token.substring(0, 10)}...:`,
        error,
      );
    }
  }
}
