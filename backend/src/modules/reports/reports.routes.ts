import { Router } from 'express';
import { authMiddleware } from '../../middleware/auth.js';
import * as reportsController from './reports.controller.js';

const router = Router();

router.use(authMiddleware);

router.post('/tax-report', reportsController.generateTaxReport);

export default router;
