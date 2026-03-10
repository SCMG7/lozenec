import { Router } from 'express';
import { authMiddleware } from '../../middleware/auth.js';
import * as analyticsController from './analytics.controller.js';

const router = Router();

router.use(authMiddleware);

router.get('/', analyticsController.getAnalytics);

export default router;
