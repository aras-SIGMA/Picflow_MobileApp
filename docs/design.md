# Design System Specification

## 1. Overview and Aesthetic Direction
- **Style Archetype**: Modern Fluid Editorial & Calibrated Optical Spectrum
- **Core Mood**: Warm Editorial, High-Key Clarity, Optical Precision, Pristine Craft
- **Primary Viewport & Density**: Mobile Compact (360px – 428px standard viewport, touch target $\ge 48\times 48\,\text{dp}$, dense metadata presentation with generous surrounding whitespace)

---

## 2. Color Palette (Semantic Tokens)

| Token Name | Approximate Value | Role / Usage |
| :--- | :--- | :--- |
| `color-bg-canvas` | `#FFFDF6` | Main application background (warm cream editorial canvas) |
| `color-surface-elevated` | `#F8F3E8` | Elevated card surfaces and container backgrounds |
| `color-surface-subtle` | `#F5EFE6` | Secondary input backings, pill surfaces, and section strips |
| `color-surface-border` | `#E8DEC9` | Primary structural dividers, card borders, and input outlines |
| `color-surface-border-subtle` | `#F0E9DC` | Subtle internal item dividers and recessed container borders |
| `color-primary` | `#2563EB` | Primary interactive actions, focused states, and key highlights |
| `color-primary-hover` | `#1D4ED8` | Pressed / active state for primary action elements |
| `color-primary-highlight` | `#3B82F6` | Secondary accent, interactive badges, and focused borders |
| `color-text-main` | `#1C1917` | High-contrast body text, headings, and high-emphasis labels |
| `color-text-muted` | `#57534E` | Secondary captions, subheadings, and contextual descriptions |
| `color-text-faint` | `#8F887C` | Monospace metadata values, timestamps, and input placeholders |
| `color-status-success` | `#10B981` | Positive feedback, success confirmations, and calibrated green gamut |
| `color-status-warning` | `#F59E0B` | Warning alerts, intermediate score indicators, and attention states |
| `color-status-danger` | `#EF4444` | Destructive buttons, error alerts, and calibrated red gamut |
| `color-overlay-scrim` | `rgba(28, 25, 23, 0.45)` | Backdrop mask for dialogs, bottom sheets, and image lightboxes |

---

## 3. Typography

- **Font Family**:
  - **Primary Sans**: `Plus Jakarta Sans`, `Inter`, `-apple-system`, `Roboto`, `sans-serif`
  - **Monospace (Data / Metrics)**: `JetBrains Mono`, `Roboto Mono`, `monospace`
  - **Editorial Display (Headlines)**: `Instrument Serif`, `Georgia`, `serif`
- **Type Scale**:
  - `Display / H1`: `28px` (font-weight: 700, line-height: 1.25, letter-spacing: -0.02em)
  - `Heading / H2`: `22px` (font-weight: 700, line-height: 1.3, letter-spacing: -0.015em)
  - `Subheading / H3`: `18px` (font-weight: 600, line-height: 1.35, letter-spacing: -0.01em)
  - `Body Regular`: `14px` (font-weight: 400, line-height: 1.5)
  - `Body Medium`: `14px` (font-weight: 500, line-height: 1.5)
  - `Label / Button`: `14px` (font-weight: 600, line-height: 1.2, letter-spacing: 0.01em)
  - `Caption / Small`: `12px` (font-weight: 400, line-height: 1.4)
  - `Metadata / Code`: `11px` (font-weight: 500, line-height: 1.3, letter-spacing: 0.04em, monospace)

---

## 4. Spacing and Layout Architecture

- **Base Grid Unit**: 4px / 8px scale
  - `space-2xs`: 4px
  - `space-xs`: 8px
  - `space-sm`: 12px
  - `space-md`: 16px
  - `space-lg`: 20px
  - `space-xl`: 24px
  - `space-2xl`: 32px
  - `space-3xl`: 48px
- **Screen Padding**: Horizontal screen gutter is `16px` on compact mobile and `20px` on larger mobile viewports.
- **Content Stacking Rhythm**:
  - Inter-component spacing within cards: `8px` to `12px`
  - Vertical card-to-card gap in feeds: `16px`
  - Section-to-section gap in details/profiles: `24px`

---

## 5. Shape, Elevation, and Borders

- **Border Radii**:
  - Micro (metadata badges, small tags): `6px`
  - Small (buttons, inputs, select fields): `10px`
  - Medium (cards, list containers, bottom sheet top corners): `16px`
  - Large (modal dialogs, floating hero sheets): `24px`
  - Full / Pill (circular action buttons, avatar masks, filter capsules): `9999px`
- **Borders**:
  - Default Container Border: `1px solid var(--color-surface-border)`
  - Subtle Item Divider: `1px solid var(--color-surface-border-subtle)`
- **Shadows / Elevation**:
  - `elevation-flat`: `none`
  - `elevation-card`: `0 1px 3px 0 rgba(0, 0, 0, 0.06), 0 3px 8px -1px rgba(0, 0, 0, 0.08)`
  - `elevation-card-hover`: `0 2px 6px 0 rgba(0, 0, 0, 0.08), 0 8px 16px -2px rgba(0, 0, 0, 0.10)`
  - `elevation-floating`: `0 10px 18px -4px rgba(0, 0, 0, 0.12), 0 4px 6px -2px rgba(0, 0, 0, 0.06)`

---

## 6. Generic Component Specifications

### 6.1 Buttons
- **Primary Action Button**:
  - Height: `48px`
  - Background: `color-primary` (`#2563EB`)
  - Foreground Text: `#FFFFFF`
  - Border-radius: `10px`
  - Typography: Label / Button (`14px`, weight: 600)
  - Pressed State: Background `color-primary-hover` (`#1D4ED8`)
  - Disabled State: Opacity `0.45`
- **Secondary / Outline Button**:
  - Height: `48px`
  - Background: `color-surface-elevated` (`#F8F3E8`)
  - Border: `1px solid color-surface-border` (`#E8DEC9`)
  - Foreground Text: `color-text-main` (`#1C1917`)
  - Border-radius: `10px`
- **Ghost / Text Button**:
  - Height: `40px`
  - Background: `transparent`
  - Foreground Text: `color-text-muted` (`#57534E`)
  - Pressed State: Background `color-surface-subtle`
- **Icon Action Button (Circular)**:
  - Dimensions: `40px x 40px` (Touch target `48px x 48px`)
  - Background: `color-surface-subtle` or `transparent`
  - Border: `1px solid color-surface-border`
  - Border-radius: `9999px`

### 6.2 Form Controls
- **Text Inputs & Multi-line Areas**:
  - Height (Single-line): `48px`
  - Background: `color-surface-elevated` (`#F8F3E8`)
  - Border: `1px solid color-surface-border` (`#E8DEC9`)
  - Padding: `12px 16px`
  - Border-radius: `10px`
  - Typography: Body Regular (`14px`)
  - Placeholder: `color-text-faint` (`#8F887C`)
  - Focused State: Border `2px solid color-primary` with zero margin drift
  - Error State: Border `1px solid color-status-danger`
- **Dropdown / Select Triggers**:
  - Height: `48px`
  - Background: `color-surface-elevated`
  - Border: `1px solid color-surface-border`
  - Padding: `12px 16px`
  - Right Icon: Downward chevron sized `18px`, color `color-text-muted`

### 6.3 Content Cards & Containers
- **Standard Surface Card**:
  - Background: `color-surface-elevated` (`#F8F3E8`)
  - Border: `1px solid color-surface-border` (`#E8DEC9`)
  - Padding: `16px`
  - Border-radius: `16px`
  - Shadow: `elevation-card`
- **Embedded Media Container**:
  - Background: `#EBE4D5` (neutral tone placeholder)
  - Border-radius: `12px`
  - Overflow: `hidden`

### 6.4 Navigation & App Shells
- **Top App Bar**:
  - Height: `56px`
  - Background: `color-bg-canvas` (`#FFFDF6`)
  - Border-bottom: `1px solid color-surface-border` (`#E8DEC9`)
  - Horizontal Padding: `16px`
  - Title Alignment: Center or Left-aligned with `Heading / H3` (`18px`, weight: 700)
- **Bottom Navigation Bar**:
  - Height: `64px` (excluding system navigation inset)
  - Background: `color-bg-canvas` (`#FFFDF6`)
  - Border-top: `1px solid color-surface-border` (`#E8DEC9`)
  - Item Layout: Equal flex distribution
  - Active Icon/Label: `color-primary` (`#2563EB`)
  - Inactive Icon/Label: `color-text-muted` (`#57534E`)

### 6.5 Badges, Pills & Metadata Chips
- **Category / Filter Pill**:
  - Height: `32px`
  - Padding: `6px 14px`
  - Border-radius: `9999px`
  - Inactive: Background `color-surface-subtle`, border `1px solid color-surface-border`, text `color-text-muted`
  - Active: Background `color-primary`, border `1px solid color-primary`, text `#FFFFFF`
- **Monospace Metadata Chip (Optic / Metric Badge)**:
  - Height: `24px`
  - Padding: `2px 8px`
  - Background: `color-surface-subtle` (`#F5EFE6`)
  - Border: `1px solid color-surface-border` (`#E8DEC9`)
  - Border-radius: `6px`
  - Typography: Metadata / Code (`11px`, weight: 500, monospace)
  - Text Color: `color-text-main`

---

## 7. AI Agent Guardrails (Rules for Consistency)

- **Feature-Agnostic Strictness**: Never introduce domain-specific feature logic or hardcoded mock labels into UI styling tokens.
- **Strict Color Token Usage**: All Flutter widgets must reference tokens from `AppColors` or `Theme.of(context)`—never use raw literals like `Color(0xFF2563EB)` directly inside presentation widgets.
- **Grid Compliance**: Spacing margins, padding, and layout gaps must strictly snap to the `4px / 8px` rhythm (`4`, `8`, `12`, `16`, `20`, `24`, `32`).
- **Touch Target Accessibility**: Every interactive element (buttons, chips, tap targets) must maintain a minimum physical touch target of $48\times 48\,\text{dp}$.
- **Contrast Ratios**: Normal body text against surfaces must strictly maintain WCAG AA contrast ratio of $\ge 4.5:1$.
