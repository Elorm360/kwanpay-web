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

- [ ] Double-entry ledger as the source of truth for balances
- [ ] KYC tiers (phone, ID, selfie) with limits per tier
- [ ] Push notifications and receipts for every transaction
- [ ] Transaction search, filters and statement export
- [ ] Admin tools: user lookup, transaction review, manual hold/release,
      audit trail (extend the existing web admin CRM)

## Phase 3 — Stellar settlement

Goal: cross-border value moves as USDC on Stellar.

- [~] Stellar wallet identity and USDC payment verification (testnet)
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
