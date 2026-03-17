import { Router } from 'express';
import { authMiddleware } from '../../middleware/auth.js';
import * as propertiesController from './properties.controller.js';

const router = Router();

router.use(authMiddleware);

router.get('/', propertiesController.list);
router.get('/:id', propertiesController.getById);
router.post('/', propertiesController.create);
router.put('/:id', propertiesController.update);
router.delete('/:id', propertiesController.remove);

export default router;
