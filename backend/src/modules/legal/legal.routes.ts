import { Router } from 'express';
import type { Request, Response } from 'express';

const router = Router();

router.get('/privacy-policy', (_req: Request, res: Response) => {
  res.json({
    data: {
      url: process.env['PRIVACY_POLICY_URL'] || 'https://rentmate.app/privacy',
    },
  });
});

router.get('/terms', (_req: Request, res: Response) => {
  res.json({
    data: {
      url: process.env['TERMS_URL'] || 'https://rentmate.app/terms',
    },
  });
});

export default router;
