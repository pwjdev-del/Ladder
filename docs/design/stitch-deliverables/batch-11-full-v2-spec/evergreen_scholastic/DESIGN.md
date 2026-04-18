# Design System Specification: The Scholastic Arboretum

## 1. Overview & Creative North Star
This design system is built upon the "Scholastic Arboretum" North Star. We are moving away from the "SaaS-dashboard" aesthetic and toward a high-end, editorial experience that feels like a cross between a prestigious academic journal and a modern conservatory.

The goal is to foster a sense of growth, stability, and wonder for the K-8 environment. We achieve this through **Intentional Asymmetry**—where large-scale serif headlines are balanced by functional sans-serif UI components—and **Organic Layering**, which replaces rigid grid lines with soft, tonal transitions. The interface should not feel like a digital tool; it should feel like a curated physical space.

---

## 2. Colors & Tonal Architecture
The palette is rooted in the depth of a forest floor, utilizing deep greens for foundation and bright, acidic limes for vital interaction points.

### The Palette
- **Foundational Greens:** 
  - `forest-900` (#3F5A3A): Use for high-authority surfaces and deep-background foundations.
  - `forest-700` (#527050): The primary canvas for dark-mode layouts or high-contrast sidebars.
  - `forest-500` (#6B8A67): Transitionary surfaces and secondary forest elements.
- **Vibrancy & Action:**
  - `lime-500` (#A8D234): The "High-Vitality" token. Reserved exclusively for primary CTAs and active states.
  - `lime-300` (#CCE68A): Used for soft focus glows and "dewy" hover states.
- **The Neutrals (Paper & Stone):**
  - `cream-100` (#F5F0E5): Use for "Logo Badges" and elevated editorial cards.
  - `paper` (#FFFFFF): The standard shell for light-mode content cards.
  - `stone-200` (#E8E2D8): Low-contrast backgrounds for input fields.
- **Ink (Typography):**
  - `ink-900` (#1B1F1B): Primary reading text.
  - `ink-600` (#4A5346): Metadata and secondary descriptions.
  - `ink-400` (#8A9082): Placeholders and tertiary utility text.

### The "No-Line" Rule
Traditional 1px solid borders are strictly prohibited for sectioning. Structural boundaries must be defined solely through background color shifts. For example, a `surface-container-low` component should sit on a `surface` background to define its edge. Contrast, not lines, defines the architecture.

### Signature Textures
To add "visual soul," use subtle linear gradients on primary containers. Transition from `forest-700` to `forest-500` at a 145-degree angle to provide a sense of natural light hitting a leaf. 

---

## 3. Typography: The Editorial Voice
We use a high-contrast typographic pairing to signal both academic prestige and modern accessibility.

### Headlines: Playfair Display
- **Role:** High-level storytelling, section headers, and page titles.
- **Styling:** Weight 600 or 700. Tracking must be set to -2% or -3% for a tight, sophisticated "ink-on-paper" look.
- **Intent:** Conveys the "Evergreen" nature of education—timeless and authoritative.

### Body & UI: Manrope
- **Role:** Data-heavy displays, body copy, and navigation.
- **Styling:** Weight 400 (Body) to 600 (Semibold UI). 
- **Intent:** Clean, highly legible, and friendly for younger students while remaining professional for faculty.

### Labels: The Utility Caps
- **Role:** Micro-copy, overlines, and tab labels.
- **Styling:** 11pt, All Caps, Weight 600, +10% tracking. This creates a clear visual distinction between "Content" and "Navigation."

---

## 4. Elevation & Depth
This system rejects "flat" design in favor of **Tonal Layering**.

- **The Layering Principle:** Depth is achieved by stacking `surface-container` tiers (Lowest to Highest). 
  - *Example:* Place a `surface-container-lowest` (#FFFFFF) card on a `surface-container-low` (#F3FCEB) background to create a soft, natural lift.
- **Ambient Shadows:** Shadows should be "warm." Use an 8% opacity black for dark backgrounds and a 4% opacity for light backgrounds. Use high blur values (24px+) and Y-offsets (8px+) to mimic soft, ambient sunlight rather than a harsh desk lamp.
- **The "Ghost Border" Fallback:** If a boundary is required for accessibility, use the `outline-variant` token at 15% opacity. Never use 100% opaque borders.
- **Glassmorphism:** For floating modals or navigation bars, use `surface` colors at 80% opacity with a `20px` backdrop-blur. This allows the organic greens of the background to bleed through, softening the interface.

---

## 5. Components

### Buttons
- **Primary:** `lime-500` fill with `ink-900` text. Use `999pt` (pill) radius. On hover, apply a `lime-300` outer glow (4px spread).
- **Secondary:** Transparent fill with a "Ghost Border" and `forest-900` text.
- **Tertiary:** Text-only with the Label-style caps, used for low-priority actions.

### Input Fields
- **Base:** `stone-200` background with `8pt` radius. 
- **Focus:** No change to border color. Instead, use a 2px outer glow of `lime-300`.
- **Labels:** Always use the Manrope 11pt Caps style above the input.

### Cards & Lists
- **Rule:** Forbid divider lines. 
- **Structure:** Separate list items using 8px or 12px of vertical white space. Use alternating tonal shifts (e.g., `surface` to `surface-container-low`) for striped lists.
- **Radius:** `12pt` for standard cards, `24pt` for major editorial containers or modals.

### Contextual Components (Education Focus)
- **The "Growth Meter":** A progress bar using a `forest-900` track and a `lime-500` fill, topped with a `lime-300` glow at the leading edge.
- **The Badge:** Use `cream-100` for achievement badges, using the Playfair Display font for numbers to make them feel like "awards."

---

## 6. Do’s and Don’ts

### Do:
- **Use White Space as a Tool:** Give the Playfair Display headlines room to breathe. Treat the screen like a premium magazine spread.
- **Embrace Asymmetry:** Align text to the left but allow imagery or "floating" lime-accented cards to break the right-side alignment.
- **Layering over Lines:** Always ask, "Can I define this area with a subtle background color change instead of a border?"

### Don’t:
- **No Pure Black:** Never use #000000. Use `ink-900` for maximum depth without the harshness of digital black.
- **Don't Overuse Lime:** `lime-500` is high-energy. Use it only for things that need to be clicked or highlighted. Too much "lime" creates visual fatigue.
- **Avoid Default Grids:** Don't just place four cards in a row. Try three cards with varying heights or a 2/3 and 1/3 split to create visual interest.