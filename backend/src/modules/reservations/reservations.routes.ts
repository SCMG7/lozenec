import { Router } from 'express';
import { authMiddleware } from '../../middleware/auth.js';
import * as reservationsController from './reservations.controller.js';

const router = Router();

router.use(authMiddleware);

router.get('/calendar', reservationsController.getCalendar);
router.get('/check-conflict', reservationsController.checkConflict);
router.get('/by-date', reservationsController.getByDate);
router.get('/:id/summary', reservationsController.getSummary);
router.get('/:id', reservationsController.getById);
router.post('/', reservationsController.create);
router.put('/:id', reservationsController.update);
router.patch('/:id/mark-paid', reservationsController.markPaid);
router.delete('/:id', reservationsController.remove);

export default router;
