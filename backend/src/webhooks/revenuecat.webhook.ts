import { Router } from 'express';
import type { Request, Response } from 'express';
import prisma from '../config/db.js';
import { asyncHandler } from '../utils/asyncHandler.js';

const router = Router();

router.post(
  '/revenuecat',
  asyncHandler(async (req: Request, res: Response) => {
    // Verify webhook secret — reject if secret is not configured
    const secret = process.env['REVENUECAT_WEBHOOK_SECRET'];
    if (!secret) {
      console.error('[RevenueCat Webhook] REVENUECAT_WEBHOOK_SECRET is not set');
      res.status(500).json({ error: 'Webhook secret not configured' });
      return;
    }

    const authHeader = req.headers['authorization'];
    if (authHeader !== `Bearer ${secret}`) {
      res.status(401).json({ error: 'Unauthorized' });
      return;
    }

    const event = req.body as {
      event: {
        type: string;
        app_user_id: string;
        expiration_at_ms?: number;
        product_id?: string;
      };
    };

    const { type, app_user_id: userId, expiration_at_ms, product_id } = event.event;

    console.log(`[RevenueCat Webhook] Event: ${type} for user: ${userId}`);

    try {
      switch (type) {
        case 'INITIAL_PURCHASE':
        case 'RENEWAL':
        case 'PRODUCT_CHANGE': {
          // Set pro_expires_at to subscription end date
          const expiresAt = expiration_at_ms
            ? new Date(expiration_at_ms)
            : new Date(Date.now() + 30 * 24 * 60 * 60 * 1000); // fallback: 30 days

          await prisma.user.update({
            where: { id: userId },
            data: { pro_expires_at: expiresAt },
          });
          break;
        }

        case 'CANCELLATION':
        case 'EXPIRATION': {
          // Set pro_expires_at to past (but keep data)
          await prisma.user.update({
            where: { id: userId },
            data: { pro_expires_at: new Date(0) },
          });
          break;
        }

        case 'NON_SUBSCRIPTION_PURCHASE': {
          // One-time tax report purchase
          if (product_id?.includes('tax_report')) {
            await prisma.user.update({
              where: { id: userId },
              data: { has_lifetime_tax_report: true },
            });
          }
          break;
        }

        default:
          console.log(`[RevenueCat Webhook] Unhandled event type: ${type}`);
      }
    } catch (error) {
      console.error(`[RevenueCat Webhook] Error processing event:`, error);
      // Return 200 anyway to prevent retries for user-not-found errors
    }

    res.json({ status: 'ok' });
  }),
);

export default router;
