# KwanPay build roadmap

Engineering plan for taking KwanPay from private beta to public launch. The
public, marketing version lives at `/roadmap` on the website; this file is the
working plan. Each phase ends with a shippable, tested state. Update the
checkboxes as work lands.

Status key: `[x]` done · `[~]` in progress · `[ ]` not started

---

## Phase 0 — Stabilize and secure (now)

Goal: a trustworthy codebase and environment to build on.

- [x] Remove the EtherHiding malware from `postcss.config.mjs` (`c27e9ba`)
- [ ] Rotate every secret that touched an infected machine or Vercel build:
      Supabase service-role and anon keys, admin session secret, Stellar
      secret keys, GitHub/Vercel tokens, and the old gateway keys
- [x] Malware fix pushed to all 7 remote branches; force-pushes and deletion
      blocked on every branch (including admins); `dixit-web` and
      `kwanpay-onboarding-preview` cleaned. Infection source identified as the
      cloned `gitcomp88/AICryptoTrader` repo (payload committed upstream)
- [x] CI guards: config files checked for hidden code, gitleaks secret scan,
      and a Flutter job (import-case check, analyze, tests)
- [x] Remove Fiatsend, Fincra, Flutterwave (and dead Moolre) code from the
      app and Edge Functions; add the provider-neutral `PaymentGateway`
      interface (`kwanpay_app/lib/core/payments/payment_gateway.dart`)
- [x] Database cleanup applied (`20261125122409_remove_payment_gateways`):
      gateway-only functions dropped, settlement and payout functions made
      gateway-neutral, and a `payment_providers` registry added. Enable a new
      gateway by inserting a row and setting `is_active = true`
- [~] 19 gateway Edge Functions replaced with inert 410 stubs behind JWT
      verification. Still to do in the dashboard: delete them and remove their
      secrets (the Supabase connector cannot delete functions)
- [ ] Turn on leaked-password protection in Supabase Auth
- [x] Repo migrations synced with the live database: 69 files match the 69
      recorded migrations (exported byte-exact; 5 hand-applied ones repaired)
- [x] Rename `lib/Core` to `lib/core` so imports work on case-sensitive
      systems; `tool/check_import_case.dart` keeps it that way
- [x] Replace the template test with model unit tests; fix withdrawals
      showing as incoming and the always-empty "Transfers" filter

## Phase 1 — Payment gateway

Goal: users can top up and withdraw GHS via Mobile Money through one partner.

- [ ] Choose the gateway. Criteria: licensed for Ghana collections and
      payouts, MTN/Telecel/AirtelTigo coverage, signed webhooks, sandbox,
      settlement times, fees, and support for future countries
- [ ] Implement `PaymentGateway` for the chosen partner and return it from
      `paymentGatewayProvider`
- [ ] Edge Functions: `initiate-collection`, `verify-collection`,
      `initiate-payout`, `verify-payout`, and one signed `payment-webhook`.
      Keep names provider-neutral so a second partner can be added later
- [ ] Database: allow the new provider id; all balance changes stay in
      `SECURITY DEFINER` RPCs triggered only by verified gateway events
- [ ] Daily reconciliation job comparing gateway settlements with the ledger
- [ ] Limits (per transaction, daily) and clear failure/refund states

## Phase 2 — Wallet core

Goal: a wallet people can trust with real money.

Milestones, in order; each ships on its own with tests.

1. [x] **Double-entry ledger** (`20261125130946_add_double_entry_ledger`)
   - `ledger_accounts` / `ledger_journals` / `ledger_entries`; journals must
     net to zero per currency (checked at commit); entries are append-only
   - Every money function posts through `ledger_post`; `wallet_balances` is a
     cache that cannot go negative; `adjust_wallet_balance` retired
   - `ledger_verify()` reports any cache/ledger disagreement
   - Fixes: FX credits rounded to 2 decimals; payouts get `completed_at`
   - End-to-end flow test: `supabase/tests/ledger_flow_test.sql`
2. [~] **Limits and KYC tiers**
   - Done: tiers 0–3 in `kyc_tiers` (Basic, Phone verified, ID verified,
     Full); per-transaction, daily and monthly caps in GHS enforced by a
     trigger on `transactions` for Send, Payment and Withdrawal (other
     currencies converted via `fx_rates`); private `kyc-documents` bucket;
     `submit_kyc_documents` and `admin_review_kyc` (service role only)
   - Done in the app: Limits and verification screen with usage, Ghana Card /
     passport capture with selfie, tier badge on Profile, "Raise limit" on
     limit refusals
   - Done on the web: `/admin/kyc` review queue (operators and up), oldest
     first, ID photos through 5-minute signed links, approve or reject with a
     reason the user sees; waiting count on the admin tabs
   - Left: phone verification (needs an SMS provider); set the limit figures
     against Bank of Ghana e-money rules before launch (they are test
     placeholders)
3. [ ] **Receipts and notifications**: receipt view and shareable PDF per
   transaction, in-app notification feed, push notifications (FCM)
4. [ ] **Statements**: search and date filters in Activity; monthly statement
   export (PDF/CSV) generated from the ledger
5. [ ] **Admin wallet tools** (web admin): user and wallet lookup, ledger
   view per user, transaction review, manual hold/release with audit trail,
   nightly `ledger_verify()` alert

## Phase 3 — Stellar settlement

Goal: cross-border value moves as USDC on Stellar.

- [x] Testnet USDC payments in the app: account and trustline set-up,
      payment with reference memo, Horizon verification, receipts, no
      double pay on retry. First recorded payment 27 Nov 2026; see
      `docs/STELLAR_USDC.md` (Stellar Instawards deliverables)
- [ ] Decide custody model (custodial, MPC or user-held keys)
- [ ] Anchor integration (SEP-24/SEP-31) for fiat on/off-ramp
- [ ] Live FX quotes with expiry, and transparent fees
- [ ] Mainnet readiness review

## Phase 4 — Merchant payments

Goal: tourism businesses get paid by travelers.

- [ ] Merchant onboarding and KYB
- [ ] QR payments and shareable payment links
- [ ] Merchant dashboard on the web (payments, payouts, exports)
- [ ] Settlement to merchant Mobile Money or bank accounts

## Phase 5 — Launch readiness

- [ ] Regulatory path confirmed (licensed partner or own PSP license)
- [ ] External security review and penetration test
- [ ] Monitoring, alerting and incident runbooks
- [ ] Play Store and App Store releases; public beta

## Phase 6 — AI travel companion

- [ ] Smart budgeting and spending insights
- [ ] Trip planning and recommendations built on wallet data (opt-in)
