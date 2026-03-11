import { Router } from 'express';
import { authMiddleware } from '../../middleware/auth.js';
import * as authController from './auth.controller.js';

const router = Router();

// Public routes
router.post('/register', authController.register);
router.post('/login', authController.login);
router.post('/verify-token', authMiddleware, authController.verifyToken);
router.post('/forgot-password', authController.forgotPassword);

// Protected routes
router.post('/change-password', authMiddleware, authController.changePassword);
router.put('/profile', authMiddleware, authController.updateProfile);
router.put('/settings', authMiddleware, authController.updateSettings);
router.post('/logout', authMiddleware, authController.logout);

export default router;
