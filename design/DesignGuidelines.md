# Zplit Design Guidelines

## Theme-Based UI

Zplit supports multiple themes, not just colors. Each theme may redefine the layout and component placement.

## First Theme: Minimal, Clean, Sleek

- Modern
- Minimalistic
- Clean
- Sleek

## UX First

All UI should prioritize an intuitive and easy-to-navigate experience with minimal cognitive load.

## Layout Variants for Each Submission

Each design submission should provide 4 modes for each screen:

## Brand Colors

- Primary (Cool Tone): #0077cc (Deep Vibrant Blue)
- Primary hover: #0066b3
- Secondary (Complementary): #7c3aed (Muted Purple) — for secondary actions (Cancel, alternate CTAs, data viz accents)
- Background (light): #f5f7fb (off-white/light gray)
- Surface: #fbfcfe (slightly off-white)
- Text (near-black): #111827
- Success: #16a34a (green) — for success/positive states
- Warning: #f97316 (orange) — for warning/negative notices

### Color Usage Guidelines

- **Primary (#0077cc):** Main buttons, Split CTA, active navigation
- **Secondary (#7c3aed):** Cancel buttons, secondary actions, alternate CTAs, data visualization accents
- **Success (#16a34a):** Positive confirmations, settled payments
- **Warning (#f97316):** Alerts, overdue payments, destructive actions
- **Focus Ring:** Faint alpha-tint of primary for keyboard focus visibility

### Accessibility

The `Split` button and other primary CTAs should use the primary color and follow these accessibility rules:

- High contrast (white text on primary background). Aim for 4.5:1 contrast ratio.
- Hover color `#0066b3`.
- Focus-visible ring for keyboard users (use a faint alpha-tint of primary).
- Include an icon and accessible label; the icon should be decorative (`aria-hidden`) and the button must have `aria-label`.

## Screens (Required)

- Onboarding: A set of intro screens showcasing Zplit’s features.
- Account Setup (Login/Signup): Local account creation with username, name, profile picture.
- Groups Page: Creating and listing groups.
- Invite Users Page: Invite users via link or email.
- Add Expenses Page: Simple, intuitive input forms for expenses.
- Graphs Page: Visualizations for expense tracking and insights.

## Implementation Notes

- Implement each screen as a discrete React route.
- Provide a global ThemeProvider to toggle `data-theme` and `data-orientation` for previewing all variants.
- Keep components composition-first and accessible (a11y).
- Use minimal interactions and clear primary CTA.

## Submission Notes

- The issue will be multi-assigned and multiple designs are allowed.
- Deadline: 1st December 2025
- The best submission becomes the first theme for Zplit.

---

This document is part of the project to help designers implement and preview the theme across the frontend example application.
