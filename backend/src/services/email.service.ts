import { Resend } from 'resend';

const resend = new Resend(process.env['RESEND_API_KEY'] || '');

const FROM_EMAIL = process.env['FROM_EMAIL'] || 'noreply@rentmate.app';
const APP_DOMAIN = process.env['APP_DOMAIN'] || 'https://rentmate.app';

export async function sendPasswordResetEmail(
  to: string,
  resetToken: string,
): Promise<void> {
  const resetLink = `${APP_DOMAIN}/reset-password?token=${resetToken}`;

  try {
    await resend.emails.send({
      from: FROM_EMAIL,
      to,
      subject: 'Reset your RentMate password',
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h2>Password Reset Request</h2>
          <p>You requested a password reset for your RentMate account.</p>
          <p>Click the button below to reset your password. This link expires in 1 hour.</p>
          <p style="margin: 24px 0;">
            <a href="${resetLink}"
               style="background-color: #2563eb; color: white; padding: 12px 24px;
                      text-decoration: none; border-radius: 6px; display: inline-block;">
              Reset Password
            </a>
          </p>
          <p style="color: #666; font-size: 14px;">
            If you didn't request this reset, you can safely ignore this email.
          </p>
          <p style="color: #666; font-size: 14px;">
            Or copy this link: ${resetLink}
          </p>
        </div>
      `,
    });
  } catch (error) {
    // Log but don't throw — don't leak email existence to caller
    console.error('[Email] Failed to send password reset email:', error);
  }
}
