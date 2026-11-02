# Zplit Brand

Canonical branding assets live in this folder (`brand/`). App runtime assets stay under `assets/images/`.

---

## Logo

| File | Use |
|------|-----|
| [`images/zplit-logo.png`](images/zplit-logo.png) | Primary logo mark |
| [`stability.svg`](stability.svg) | Brand SVG asset |
| [`images/homescreen.png`](images/homescreen.png) | Home screen brand illustration |
| [`images/onboarding-1.png`](images/onboarding-1.png) | Onboarding illustration 1 |
| [`images/onboarding-2.png`](images/onboarding-2.png) | Onboarding illustration 2 |
| [`images/onboarding-3.png`](images/onboarding-3.png) | Onboarding illustration 3 |

**Do:** use SVG when scaling; keep clear space around the mark; use on light or dark backgrounds as appropriate.
**Don't:** stretch, recolor, or crop until the mark is unreadable.

---

## Colors

From `lib/theme/app_theme.dart`.

| Role | HEX |
|------|-----|
| Primary | `#00C853` |
| Primary container (light) | `#E6F9EE` |
| Primary dark / secondary | `#00A343` |
| Error / negative | `#EF4444` |
| On primary | `#000000` |
| Light background | `#FFFFFF` |
| Light surface | `#F9FAFB` |
| Light card | `#FFFFFF` |
| Light divider | `#E5E7EB` |
| Light text primary | `#111827` |
| Light text secondary | `#6B7280` |
| Light text hint | `#9CA3AF` |
| Dark background | `#0C0B10` |
| Dark surface | `#14131A` |
| Dark card | `#1C1A24` |
| Dark divider | `#25232F` |
| Dark text primary | `#F9FAFB` |
| Dark text secondary | `#A0A0B0` |
| Dark text hint | `#6B6B80` |

---

## Typography

Material 3 default sans (no custom `fontFamily`). Scale from `TextTheme` in `app_theme.dart`:

| Style | Size | Weight | Letter spacing |
|-------|------|--------|-----------------|
| Display large | 32 | w700 | -0.5 |
| Display medium | 28 | w700 | -0.5 |
| Headline large | 24 | w600 | -0.3 |
| Headline medium | 20 | w600 | -0.2 |
| Headline small | 18 | w600 | — |
| Body large | 16 | w400 | — |
| Body medium | 14 | w400 | — |
| Body small | 12 | w400 | — |
| Label large | 14 | w500 | 0.1 |
| Label medium | 12 | w500 | 0.1 |
| Label small | 11 | w500 | 0.2 |

---

## Icons

- **UI:** Material Icons; active accent `#00C853`.