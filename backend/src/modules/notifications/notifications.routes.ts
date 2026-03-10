import { Router } from 'express';
import { authMiddleware } from '../../middleware/auth.js';
import * as notificationsController from './notifications.controller.js';

const router = Router();

router.use(authMiddleware);

router.get('/', notificationsController.list);
router.get('/unread-count', notificationsController.getUnreadCount);
router.patch('/mark-all-read', notificationsController.markAllRead);
router.patch('/:id/read', notificationsController.markRead);

export default router;
