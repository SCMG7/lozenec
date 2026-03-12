import { Router } from 'express';
import { authMiddleware } from '../../middleware/auth.js';
import * as expensesController from './expenses.controller.js';

const router = Router();

router.use(authMiddleware);

router.get('/', expensesController.list);
router.get('/summary', expensesController.getSummary);
router.get('/annual-summary', expensesController.getAnnualSummary);
router.get('/:id', expensesController.getById);
router.post('/', expensesController.create);
router.put('/:id', expensesController.update);
router.delete('/:id', expensesController.remove);

export default router;
