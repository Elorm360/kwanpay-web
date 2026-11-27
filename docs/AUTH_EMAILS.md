# Auth emails (Supabase dashboard setup)

The app confirms sign-ups and resets passwords with **6-digit codes**, not
links, so the whole flow stays inside the app. Supabase's default emails
contain only a link, so each template below must be pasted in once.

Supabase dashboard → project **kwanpay - db** → **Authentication** →
**Emails** (Templates).

## 1. Confirm signup

**Subject:** `Your KwanPay code: {{ .Token }}`

```html
<div style="font-family:-apple-system,Segoe UI,Roboto,Helvetica,Arial,sans-serif;max-width:480px;margin:0 auto;padding:32px 24px;color:#24262B">
  <p style="font-size:20px;font-weight:800;color:#1E2340;margin:0 0 24px">Kwan<span style="color:#D98E3B">Pay</span></p>
  <p style="font-size:16px;line-height:1.6;margin:0 0 16px">Enter this code in the KwanPay app to confirm your email:</p>
  <p style="font-size:34px;font-weight:800;letter-spacing:8px;color:#1E2340;background:#EDEFF0;border-radius:14px;padding:16px 0;text-align:center;margin:0 0 16px">{{ .Token }}</p>
  <p style="font-size:14px;line-height:1.6;color:#6B7280;margin:0 0 24px">The code expires in 1 hour. If you did not create a KwanPay account, you can ignore this email.</p>
  <p style="font-size:12px;color:#6B7280;margin:0">KwanPay Technologies Ltd.</p>
</div>
```

## 2. Reset password

**Subject:** `Your KwanPay password reset code: {{ .Token }}`

```html
<div style="font-family:-apple-system,Segoe UI,Roboto,Helvetica,Arial,sans-serif;max-width:480px;margin:0 auto;padding:32px 24px;color:#24262B">
  <p style="font-size:20px;font-weight:800;color:#1E2340;margin:0 0 24px">Kwan<span style="color:#D98E3B">Pay</span></p>
  <p style="font-size:16px;line-height:1.6;margin:0 0 16px">Someone asked to reset the password for your KwanPay account. Enter this code in the app to choose a new password:</p>
  <p style="font-size:34px;font-weight:800;letter-spacing:8px;color:#1E2340;background:#EDEFF0;border-radius:14px;padding:16px 0;text-align:center;margin:0 0 16px">{{ .Token }}</p>
  <p style="font-size:14px;line-height:1.6;color:#6B7280;margin:0 0 24px">The code expires in 1 hour. If this wasn't you, ignore this email; your password stays the same.</p>
  <p style="font-size:12px;color:#6B7280;margin:0">KwanPay Technologies Ltd.</p>
</div>
```

## 3. Recommended settings

- **Authentication → Sign In / Providers → Email:** keep *Confirm email* on.
  Set *Email OTP length* to **6** to match the copy above (the app accepts
  6–8 digits either way).
- **Authentication → Emails → SMTP Settings:** Supabase's built-in email
  service is for testing only. It sends a handful of emails per hour and,
  for new projects, only to members of your Supabase team. Before real users
  sign up, connect a provider (e.g. Resend, Postmark, Amazon SES) and send
  from an address on your own domain, such as `no-reply@kwanpay.app`.
- **Authentication → Attack Protection:** turn on *Leaked password
  protection*.
