# KwanPay design system

One source of truth for the website (`app/globals.css` → `@theme`) and the
Flutter app (`kwanpay_app/lib/core/theme/`). If a value changes here, change
it in both places.

## Principles

1. **Show the product, not decoration.** Real app screens and real photos
   beat illustrations, mock data and glowing gradients.
2. **Be specific.** Countries, fees, timings and names beat "seamless",
   "premium" and "built for Africa".
3. **One accent.** Amber marks the single most important action or fact on a
   screen. Everything else is ink, paper and grey.
4. **Calm motion.** Motion explains a change of state (a payment going
   through, a sheet opening). No shimmer, parallax, cursor effects or
   looping animation. Content never depends on JavaScript to become visible.
5. **Built for real conditions.** Mid-range Android phones, slow networks,
   bright sunlight, larger system font sizes.

## Colour

| Token | Hex | Use |
|---|---|---|
| `ink` | `#1E2340` | Primary text, dark surfaces, primary buttons on light |
| `ink-deep` | `#13162B` | Deepest surfaces, gradient end |
| `ink-soft` | `#2A3154` | Raised tiles on dark |
| `amber` | `#D98E3B` | The one accent: key action, key figure |
| `amber-deep` | `#B56F28` | Pressed state, gradient end |
| `amber-tint` | `#FBF3EA` | Accent backgrounds (badges, highlights) |
| `paper` | `#EDEFF0` | Page / app background |
| `charcoal` | `#24262B` | Body text on light |
| `muted` | `#6B7280` | Secondary text (meets 4.5:1 on white) |
| `line` | `#E5E7EB` | Borders, dividers |
| `success` | `#1E8E5A` | Completed, money in |
| `danger` | `#D14343` | Failed, errors |

Amber text on white is below 4.5:1 contrast: use it for large text and icons,
never for body copy.

## Type

Web: Geist Sans. App: the same family via `google_fonts`.

| Role | Web | App | Weight |
|---|---|---|---|
| Display | 44 / 60 / 96 px (mobile / tablet / desktop) | 34 | 800 |
| H1 | 36 / 48 px | 28 | 800 |
| H2 | 28 / 36 px | 22 | 700 |
| Title | 20 px | 18 | 700 |
| Body | 16–18 px, line-height 1.6 | 16 | 400 |
| Caption | 13–14 px | 13 | 500 |

Money amounts use tabular figures so columns line up.

## Spacing, radius, elevation

- Spacing scale (px): 4, 8, 12, 16, 24, 32, 48, 64, 96. Sections: 96 px
  desktop, 64 px mobile.
- Radius: `control` 14 px (inputs, small buttons), `card` 24 px, `sheet`
  32 px. Pills only for buttons and badges.
- Shadows: `shadow-card` for resting cards, `shadow-raised` for one hero
  element per screen. Never stack glows.

## Components

- **Primary button:** ink background, white label, 52 px tall in the app.
  The amber button is reserved for the single main conversion action on a
  page (e.g. "Join early access").
- **Amounts:** currency code before the number (`GHS 1,240.00`), two
  decimals, tabular figures; credits in `success`, debits in `charcoal`.
- **Status:** text plus colour (never colour alone): Pending, Completed,
  Failed, Cancelled.
- **Empty, loading and error states** are designed for every list and
  screen, not left blank.
