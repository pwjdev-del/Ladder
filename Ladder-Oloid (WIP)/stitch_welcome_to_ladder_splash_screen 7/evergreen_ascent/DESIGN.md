# Design System Specification: Editorial Organicism

## 1. Overview & Creative North Star
The Creative North Star for this design system is **"The Academic Atelier."** 

Unlike standard ed-tech apps that rely on playful, rounded bubbles and neon colors, this system treats student progress as a premium, editorial experience. It combines the prestige of traditional Ivy League aesthetics (The "Grown" Serif) with the sleek, hyper-functional ethos of modern high-end technology. 

We break the "template" look by rejecting rigid, centered grids in favor of **intentional asymmetry**. Expect large, offset display type, overlapping image containers that break out of their parent frames, and a layout that breathes through generous, luxurious whitespace. This is not just a tool; it is a digital companion for the ambitious.

---

## 2. Color Philosophy
The palette is rooted in nature and prestige, using deep botanical greens and warm stone neutrals to evoke a sense of grounded growth.

### The "No-Line" Rule
To maintain a high-end feel, **1px solid borders are strictly prohibited** for sectioning or containment. We define boundaries through tonal shifts alone. A card does not need a stroke to exist; it exists because its `surface-container-highest` value sits elegantly atop a `surface` background.

### Surface Hierarchy & Nesting
Treat the UI as a series of physical layers—like fine vellum paper stacked on a stone desk.
*   **Base:** `surface` (#fff8f2)
*   **Secondary Content:** `surface-container-low` (#fbf2e8)
*   **Actionable Cards:** `surface-container-highest` (#eae1d7)

### Glass & Gradient Rule
For elements meant to feel "floating" or "ethereal" (like navigation bars or modal overlays), use **Glassmorphism**:
*   **Fill:** `surface_variant` at 70% opacity.
*   **Backdrop Blur:** 20px – 32px.
*   **Signature Texture:** Use a subtle linear gradient on primary CTAs, transitioning from `primary` (#42603f) to `primary_container` (#5a7956) at a 135-degree angle to add "soul" and depth.

---

## 3. Typography
The typographic voice is a dialogue between the authoritative past and the efficient future.

*   **Headings (Grown Serif):** Used for `display` and `headline` tiers. It conveys the "Mission" of trustworthiness. Use tight letter-spacing (-2%) for large headlines to create a bespoke, high-fashion editorial look.
*   **Body & UI (Montserrat/Manrope):** Used for `title`, `body`, and `label`. Montserrat provides a geometric, clean counterpoint to the organic serif.
*   **Hierarchy Note:** To achieve a premium feel, increase the scale contrast. If a `display-lg` is 3.5rem, keep the supporting `body-md` at a crisp 0.875rem. This "high-low" contrast is the hallmark of professional editorial design.

---

## 4. Elevation & Depth
In this system, we do not "drop shadows"; we "ambiently light" the interface.

*   **The Layering Principle:** Depth is achieved via **Tonal Layering**. Instead of using shadows to separate a list of items, use the `surface-container` tiers. 
*   **Ambient Shadows:** When a floating element (like a FAB or floating header) is required, use a shadow with a 40px - 60px blur at 6% opacity. The shadow color must be a tinted green-gray derived from `on_surface` (#1f1b15), never pure black.
*   **The "Ghost Border" Fallback:** If a border is required for accessibility, use `outline_variant` (#c3c8be) at **15% opacity**. It should be felt, not seen.
*   **Corner Radii:** Adhere to the `xl` (1.5rem / 24px) or `lg` (1rem / 16px) tokens to mimic the soft, sophisticated curvature of premium hardware.

---

## 5. Components

### Buttons
*   **Primary:** Gradient fill (`primary` to `primary_container`), `xl` roundedness, white text. No shadow except on hover.
*   **Secondary:** `surface-container-highest` background with `on_surface` text.
*   **Tertiary:** No background. Underlined with a 2px `secondary_fixed` line that sits 4px below the baseline.

### Cards & Progress Trackers
*   **Cards:** Forbid divider lines. Use `surface-container-low` for the card body and `surface-container-highest` for internal "sub-cards" or headers.
*   **The Ladder Tracker:** A signature component. Vertical progress should be represented by a thick, `secondary_fixed` (#caf24d) line that glows subtly using a `secondary` tinted shadow.

### Input Fields
*   **Style:** Minimalist. No bounding box. A single `outline_variant` bottom-border (at 40% opacity) that transforms into a `primary` color line upon focus. Helper text should use `label-sm` in `tertiary`.

### Chips
*   **Filter Chips:** Use `surface-container-high` with `on_surface_variant` text. When selected, shift to `primary` with `on_primary` text.

---

## 6. Do's and Don'ts

### Do
*   **Do** use asymmetrical margins. For example, a 16px left margin and a 32px right margin for a headline can create a sophisticated "offset" look.
*   **Do** lean into "Warm Gray" (#DBD3C9). It makes the digital interface feel like a physical, tactile object.
*   **Do** use `secondary_fixed` (Accent Lime) sparingly. It is a "spark" for motivation, not a background color.

### Don't
*   **Don't** use 100% black text. Use `on_surface` (#1f1b15) to maintain the "Soft Gray" sophistication.
*   **Don't** use standard Material Design elevations. If it looks like a "default" shadow, it’s too heavy.
*   **Don't** crowd the interface. If you think you have enough whitespace, double it. Premium brands sell "the space between," not just the content.