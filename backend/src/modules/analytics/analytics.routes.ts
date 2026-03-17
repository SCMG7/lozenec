import { Router } from 'express';
import { authMiddleware } from '../../middleware/auth.js';
import * as analyticsController from './analytics.controller.js';

const router = Router();

router.use(authMiddleware);

router.get('/', analyticsController.getAnalytics);
router.get('/summary', analyticsController.getSummary);
router.get('/monthly', analyticsController.getMonthly);
router.get('/top-guests', analyticsController.getTopGuests);

export default router;
