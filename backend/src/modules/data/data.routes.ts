import { Router } from 'express';
import { authMiddleware } from '../../middleware/auth.js';
import * as dataController from './data.controller.js';

const router = Router();

router.use(authMiddleware);

router.post('/export', dataController.exportData);
router.delete('/clear', dataController.clearData);

export default router;
