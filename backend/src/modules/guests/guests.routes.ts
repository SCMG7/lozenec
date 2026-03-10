import { Router } from 'express';
import { authMiddleware } from '../../middleware/auth.js';
import * as guestsController from './guests.controller.js';

const router = Router();

router.use(authMiddleware);

router.get('/', guestsController.list);
router.get('/search', guestsController.search);
router.get('/:id', guestsController.getById);
router.post('/', guestsController.create);
router.put('/:id', guestsController.update);
router.delete('/:id', guestsController.remove);

export default router;
