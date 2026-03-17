import { Router } from 'express';
import multer from 'multer';
import { authMiddleware } from '../../middleware/auth.js';
import * as expensesController from './expenses.controller.js';

const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 10 * 1024 * 1024 }, // 10 MB
  fileFilter: (_req, file, cb) => {
    if (file.mimetype.startsWith('image/')) {
      cb(null, true);
    } else {
      cb(new Error('Only image files are allowed'));
    }
  },
});

const router = Router();

router.use(authMiddleware);

router.get('/', expensesController.list);
router.get('/summary', expensesController.getSummary);
router.get('/annual-summary', expensesController.getAnnualSummary);
router.get('/:id', expensesController.getById);
router.post('/', expensesController.create);
router.put('/:id', expensesController.update);
router.delete('/:id', expensesController.remove);
router.post('/:id/receipt', upload.single('receipt'), expensesController.uploadReceipt);
router.delete('/:id/receipt', expensesController.deleteReceipt);

export default router;
