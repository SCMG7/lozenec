import { Router } from 'express';
import { authMiddleware } from '../../middleware/auth.js';
import * as dashboardController from './dashboard.controller.js';

const router = Router();

router.get('/', authMiddleware, dashboardController.getDashboard);

export default router;
