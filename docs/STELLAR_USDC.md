# Stellar Testnet USDC payments

How a KwanPay user pays a tourism business in USDC on the Stellar test
network, how KwanPay proves the payment happened, and how to repeat the demo.

Written for the Stellar Instawards review (West Africa chapter). Sections 7
and 8 map the work to the three SOW deliverables and hold the evidence.

> **Test network only.** Everything here runs on Stellar Testnet with
> Circle's test USDC, which has no real value. No real money moves, and the
> user's KwanPay GHS balance is never touched.

---

## 1. What the user does

1. In the app, **Pay → Pay with USDC**.
2. The first time, KwanPay sets up the user's Stellar Testnet account. The
   screen shows the USDC balance and the user's Stellar address.
3. If the balance is 0, the user copies the address, taps **Open Circle
   faucet**, chooses *Stellar Testnet*, and pastes it. Then they refresh.
4. They choose a business, enter the booking reference and an amount, and tap
   **Pay with USDC**.
5. The button walks through *Recording payment… → Sending on Stellar… →
   Confirming on Horizon…* and ends on **Payment made**, with the Stellar
   transaction hash, a **View on Stellar Expert** link, and a receipt.

## 2. How it works

```
 Phone (KwanPay app)                Supabase                        Stellar Testnet
 ───────────────────                ────────                        ───────────────
 ① initiate_stellar_usdc_payment ─▶ transactions row
                                     type Payment, USDC, Pending
                                     reference KWP-TXN-…
 ② sign + submit payment ──────────────────────────────────────────▶ USDC payment
    memo = SHA-256(reference)                                         user → business
 ③ verify-stellar-usdc-payment ───▶ Edge Function reads Horizon ◀─── transaction + ops
    (reference, tx hash)             checks, then
                                     confirm_stellar_usdc_payment
                                     → Completed, hash stored
 ④ success screen + receipt ◀────── updated row
```

The **reference** is the thread through everything. It is created once per
payment attempt, stored on the KwanPay record, and hashed into the Stellar
memo. That is what lets the server prove *this* on-chain payment belongs to
*this* KwanPay record.

## 3. Components

| Piece | Where | What it does |
|---|---|---|
| USDC Pay screen | `kwanpay_app/lib/features/pay/presentation/usdc_pay_screen.dart` | The whole user flow and its retry rules |
| Stellar wallet service | `kwanpay_app/lib/core/services/stellar/stellar_testnet_wallet_service.dart` | Creates and funds the Testnet account (Friendbot), opens the USDC trustline, builds, signs and submits the payment, finds an earlier payment by memo |
| Key store | `kwanpay_app/lib/core/services/stellar/stellar_key_store.dart` | Keeps the Testnet secret key in Android encrypted storage, never on the server |
| Asset settings | `kwanpay_app/lib/core/services/stellar/stellar_assets.dart` | Circle Testnet USDC issuer `GBBD47IF…FLA5`, faucet and explorer links |
| Start a payment | `initiate_stellar_usdc_payment` (Postgres) | Creates the Pending USDC record; repeat calls with the same reference return the same record |
| Verify on Horizon | `supabase/functions/verify-stellar-usdc-payment/index.ts` (Edge Function) | Reads the transaction from Horizon and runs every check in section 4 |
| Confirm | `confirm_stellar_usdc_payment` (Postgres, server only) | Moves Pending → Completed and stores the hash; repeat calls are safe |
| Receiving businesses | `tourism_stellar_accounts` table | Six Testnet business accounts, each with a USDC trustline |
| Receipt | `kwanpay_app/lib/features/receipts/` | Shows business, booking reference and Stellar transaction; shareable as PDF |

## 4. What the server checks before marking a payment paid

The Edge Function only confirms a payment when **all** of these hold on
Horizon:

1. The caller is signed in, and the KwanPay record is theirs, a `Payment`,
   on `stellar_testnet`.
2. The Stellar transaction exists and `successful` is true.
3. The memo is a hash memo equal to SHA-256 of the KwanPay reference.
4. It contains a `payment` operation in USDC from Circle's Testnet issuer.
5. The sender is the user's registered Stellar account.
6. The destination is the business's registered Stellar account.
7. The amount equals the KwanPay record's amount (to the cent).

Any failed check returns a plain reason and leaves the record Pending.

## 5. Reliability: statuses, retries, duplicates

| Situation | What happens |
|---|---|
| Normal payment | Pending → Completed, hash stored |
| App retries the start | Same reference returns the same record (no duplicate) |
| Verification retried, or run twice | Already Completed with the same hash returns it unchanged |
| Payment sent, verification failed (e.g. network) | Hash is kept; the button becomes **Check again** and only verification is retried, never the payment |
| Send failed with no clear answer | Button becomes **Try again**. Before sending, the app looks for a successful payment from this account with this reference's memo and uses it if found. A dropped connection cannot cause a double payment |
| Inputs after an attempt | Business, booking and amount are locked once anything may have reached Stellar |
| Wallet limits (KYC) | Not applied: these payments come from the user's own Stellar account, not the KwanPay balance |

Statuses use the same set as every KwanPay transaction: Pending, Completed,
Failed, Cancelled.

## 6. Repeat the demo

**Needs:** the KwanPay Android app (debug build), a KwanPay account, internet.

1. Sign in and open **Pay → Pay with USDC**. Wait for *Setting up your
   Stellar account* to finish.
2. Copy the Stellar address shown on the card.
3. Go to <https://faucet.circle.com>, choose **Stellar Testnet**, paste the
   address and request USDC. Back in the app, tap refresh: the balance shows
   the test USDC.
4. Choose a business (e.g. *Cape Coast Tours*), enter a booking reference
   such as `BK2026DEMO`, and an amount such as `5`.
5. Tap **Pay with USDC** and wait for **Payment made**.
6. Tap **View on Stellar Expert**. The page shows the USDC payment, sender,
   destination and hash memo.
7. Tap **View receipt**, or open the payment from **Activity**. The receipt
   shows *Completed*, the business, booking reference and the same Stellar
   transaction hash.

### Automated checks

- App tests: `flutter test` in `kwanpay_app/` (42 tests, including Stellar
  receipts and explorer links in `test/stellar_receipt_test.dart`).
- Database flow, run in a rolled-back transaction: start → repeat start
  (same record) → confirm → repeat confirm (unchanged), wallet limits
  unaffected. Passed on 27 Nov 2026.

## 7. Evidence for the SOW

| SOW deliverable | Evidence |
|---|---|
| **1. USDC payment rail**: trustline, initiation, submission, secure result handling | Code in section 3 · demo steps 1–5 · Stellar Expert link below |
| **2. Verification and sync**: hash, status mapping, idempotency, persistence | Section 4 checks · section 5 table · KwanPay record and receipt below |
| **3. Demo and documentation** | This document · demo in section 6 · tests in section 6 |

### Recorded Testnet payment

<!-- Filled in after the on-device run. -->

| | |
|---|---|
| Date | _to be added_ |
| Business | _to be added_ |
| Amount | _to be added_ |
| KwanPay reference | _to be added_ |
| Stellar transaction | _to be added_ |
| Explorer | _to be added_ |
| KwanPay status | _to be added_ |

Screenshots: _to be added_ (USDC Pay screen, Payment made, receipt,
Stellar Expert page).

## 8. Known limitations

- **Testnet only.** Mainnet needs real USDC liquidity, a production Horizon
  or RPC provider, and the custody decision below.
- **Keys live on the phone.** The Testnet secret key is in Android encrypted
  storage. Reinstalling the app or changing phones creates a new Stellar
  account; the old test USDC is not recovered.
- **Stale Pending records.** If a user starts a payment and abandons it
  before sending, the KwanPay record stays Pending. No money is affected; a
  clean-up job is a next step.
- **Public Horizon.** Verification calls the public Testnet Horizon. If it is
  slow or down, verification fails and can be retried with **Check again**.
- **Six seeded businesses.** Receiving accounts are seeded test accounts,
  not onboarded merchants.

## 9. Next steps toward production

1. Decide custody: custodial, MPC, or user-held keys with recovery (roadmap
   Phase 3).
2. Cancel Pending Stellar payments whose transaction window (5 minutes) has
   passed with no matching payment on chain.
3. Merchant onboarding: let businesses register and verify their own
   Stellar receiving accounts.
4. Anchor integration (SEP-24/SEP-31) so users can move between GHS and USDC.
5. Mainnet readiness review: limits, monitoring, and reconciliation against
   the KwanPay ledger.
