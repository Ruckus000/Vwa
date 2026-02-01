# VWA Design System

## Version 1.0 â€” Neo-Brutalist

---

# Table of Contents

1. [Brand Overview](#1-brand-overview)
2. [Design Philosophy](#2-design-philosophy)
3. [Color System](#3-color-system)
4. [Typography](#4-typography)
5. [Spacing & Layout](#5-spacing--layout)
6. [Iconography](#6-iconography)
7. [Component Library](#7-component-library)
8. [Animation & Interaction](#8-animation--interaction)
9. [Accessibility](#9-accessibility)
10. [Screen Specifications](#10-screen-specifications)
11. [Implementation Guidelines](#11-implementation-guidelines)
12. [Voice & Tone](#12-voice--tone)

---

# 1. Brand Overview

## 1.1 Product Definition

**Vwa** (pronounced "vwah") is a mobile application that teaches Gen Z slang through text-to-speech pronunciation and contextual translations. The app bridges generational and linguistic gaps by making contemporary English slang accessible to non-native speakers and older generations.

## 1.2 Target Audience

| Segment               | Description                                                   | Primary Need                                               |
| --------------------- | ------------------------------------------------------------- | ---------------------------------------------------------- |
| **Language Learners** | Non-native English speakers (18-35) learning informal English | Understand slang in media, conversations, social platforms |
| **Parents/Educators** | Adults 35-55 wanting to understand younger generations        | Decode communication from children, students               |
| **ESL Students**      | International students in English-speaking countries          | Navigate informal social situations                        |
| **Content Creators**  | International creators consuming English-language content     | Understand and use trending terminology                    |

## 1.3 Brand Personality

Vwa's personality mirrors the irreverent, bold, and unapologetic nature of slang itself.

**Brand Attributes:**

- **Bold** â€” We don't whisper. Our design makes a statement.
- **Direct** â€” No fluff. Information first.
- **Contemporary** â€” We're of the moment, not chasing it.
- **Accessible** â€” Complex ideas, simple delivery.
- **Playful** â€” Serious about learning, not about ourselves.

**Brand Voice:**

- Confident, not arrogant
- Casual, not sloppy
- Informative, not pedantic
- Witty, not try-hard

## 1.4 Logo & Wordmark

The Vwa logo consists of a bold "V" lettermark contained within a square, paired with the "VWA" wordmark.

**Lettermark Specifications:**

- Container: Square, no border radius
- Background: Primary Orange (#FF6B00)
- Border: 2-3px solid, high contrast (white in dark mode, black in light mode)
- Shadow: 4px offset, no blur
- Letter: "V" in SF Pro Display Black (900 weight), white

**Wordmark:**

- Font: SF Pro Display
- Weight: 900 (Black)
- Case: Uppercase
- Letter-spacing: -1px (tight)

**Clear Space:**
Minimum clear space around logo = height of the "V" lettermark

**Minimum Size:**

- Digital: 24px height
- Print: 0.25 inches height

---

# 2. Design Philosophy

## 2.1 Neo-Brutalism

Vwa adopts Neo-Brutalist design principlesâ€”a modern interpretation of mid-century Brutalist architecture applied to digital interfaces. This approach rejects the over-polished, homogeneous aesthetic that dominates modern app design in favor of rawness, honesty, and functional clarity.

**Why Neo-Brutalism for Vwa:**

1. **Personality Match** â€” Slang is raw, unfiltered language. Our design should reflect that energy.
2. **Differentiation** â€” In a sea of soft gradients and glassmorphism, we stand out.
3. **Demographic Alignment** â€” Research shows 87% of users 18-24 prefer emotionally expressive design (Google M3 Expressive studies, 2025).
4. **Performance** â€” Flat surfaces and solid colors are computationally cheaper than blurs and gradients.

## 2.2 Core Design Principles

### Principle 1: Honesty Over Polish

Design elements should clearly communicate what they are. Buttons look like buttons. Cards look like containers. We don't hide structureâ€”we celebrate it.

**Do:**

- Use visible borders to define elements
- Apply hard shadows that show depth
- Display clear visual hierarchy

**Don't:**

- Use subtle hover states that users might miss
- Hide interactive elements
- Rely on animation alone to communicate state

### Principle 2: Typography as Architecture

In Neo-Brutalism, type does the heavy lifting. Large, bold headlines aren't decorationâ€”they're structure.

**Do:**

- Use oversized type for primary information
- Apply negative letter-spacing on headlines
- Treat uppercase as a design element

**Don't:**

- Use decorative fonts
- Apply text effects (shadows, gradients on text)
- Mix more than 2 font families

### Principle 3: High Contrast, Always

Every element must be immediately visible. We don't do "barely there" design.

**Do:**

- Maintain minimum 4.5:1 contrast ratio (WCAG AA)
- Use the full range of your color palette
- Make interactive elements obviously different from static content

**Don't:**

- Use low-contrast placeholder text
- Apply opacity below 60% for functional elements
- Rely on color alone to communicate state

### Principle 4: Physical Feedback

Digital interfaces should feel tactile. When users interact with elements, those elements should respond physically.

**Do:**

- Apply translate transforms on button press
- Reduce shadow depth on press states
- Use spring-based animations for natural movement

**Don't:**

- Use only color change for interaction feedback
- Apply slow, decorative animations
- Create hover states that don't work on touch devices

### Principle 5: Function Before Form

Every design decision must serve a purpose. If an element doesn't help the user accomplish their goal, remove it.

**Do:**

- Question every element: "Does this help the user?"
- Prioritize information hierarchy over visual balance
- Test designs with real users, not just stakeholders

**Don't:**

- Add elements for "visual interest"
- Sacrifice usability for aesthetics
- Design for screenshots over actual use

---

# 3. Color System

## 3.1 Color Philosophy

Our palette is intentionally limited and high-contrast. We use two primary colors (orange and yellow) plus neutrals. This constraint ensures consistency and makes the brand instantly recognizable.

## 3.2 Primary Palette

### Primary Orange

The main brand color. Used for primary actions, active states, and brand elements.

| Token                   | Light Mode | Dark Mode | Usage                                              |
| ----------------------- | ---------- | --------- | -------------------------------------------------- |
| `color-primary`         | #FF5500    | #FF6B00   | Primary buttons, active indicators, brand elements |
| `color-primary-hover`   | #E64D00    | #FF7A1A   | Hover states                                       |
| `color-primary-pressed` | #CC4400    | #E65F00   | Pressed states                                     |

### Accent Yellow

Secondary brand color. Used for category tags, highlights, and secondary emphasis.

| Token             | Light Mode | Dark Mode | Usage                                     |
| ----------------- | ---------- | --------- | ----------------------------------------- |
| `color-accent`    | #FFD600    | #FFE600   | Category tags, highlights, secondary CTAs |
| `color-accent-on` | #0D0D0D    | #0D0D0D   | Text on accent backgrounds (always dark)  |

## 3.3 Neutral Palette

### Dark Mode Neutrals

| Token                  | Value   | Usage                                         |
| ---------------------- | ------- | --------------------------------------------- |
| `color-bg`             | #0D0D0D | App background                                |
| `color-surface`        | #1A1A1A | Card backgrounds, elevated surfaces           |
| `color-surface-raised` | #242424 | Nested containers, input backgrounds          |
| `color-border`         | #333333 | Subtle borders, dividers                      |
| `color-border-strong`  | #FFFFFF | High-contrast borders, Neo-Brutalist outlines |
| `color-text`           | #FFFFFF | Primary text                                  |
| `color-text-secondary` | #A3A3A3 | Secondary text, descriptions                  |
| `color-text-muted`     | #666666 | Tertiary text, placeholders, metadata         |
| `color-shadow`         | #000000 | Drop shadows                                  |

### Light Mode Neutrals

| Token                  | Value   | Usage                                         |
| ---------------------- | ------- | --------------------------------------------- |
| `color-bg`             | #F5F5F0 | App background                                |
| `color-surface`        | #FFFFFF | Card backgrounds, elevated surfaces           |
| `color-surface-raised` | #FFFFFF | Nested containers, input backgrounds          |
| `color-border`         | #E0E0E0 | Subtle borders, dividers                      |
| `color-border-strong`  | #0D0D0D | High-contrast borders, Neo-Brutalist outlines |
| `color-text`           | #0D0D0D | Primary text                                  |
| `color-text-secondary` | #525252 | Secondary text, descriptions                  |
| `color-text-muted`     | #858585 | Tertiary text, placeholders, metadata         |
| `color-shadow`         | #0D0D0D | Drop shadows                                  |

## 3.4 Semantic Colors

| Token           | Light Mode | Dark Mode | Usage                             |
| --------------- | ---------- | --------- | --------------------------------- |
| `color-success` | #22C55E    | #4ADE80   | Success states, confirmations     |
| `color-warning` | #F59E0B    | #FBBF24   | Warning states                    |
| `color-error`   | #EF4444    | #F87171   | Error states, destructive actions |
| `color-info`    | #3B82F6    | #60A5FA   | Informational states              |

## 3.5 Color Application Rules

1. **Never use color alone to communicate meaning.** Always pair with icons, text, or patterns.
2. **Maintain contrast ratios.** Minimum 4.5:1 for normal text, 3:1 for large text (18px+ bold or 24px+ regular).
3. **Use `color-border-strong` for Neo-Brutalist elements.** This creates the characteristic high-contrast outlines.
4. **Shadows are always solid, never blurred.** Use `color-shadow` with 0 blur radius.

---

# 4. Typography

## 4.1 Type Scale

Vwa uses a constrained type system based on Apple's SF Pro family, optimized for iOS legibility while maintaining our brutalist aesthetic.

### Font Families

| Purpose     | Font           | Fallback                                      |
| ----------- | -------------- | --------------------------------------------- |
| **Display** | SF Pro Display | -apple-system, BlinkMacSystemFont, sans-serif |
| **Body**    | SF Pro Text    | -apple-system, BlinkMacSystemFont, sans-serif |
| **Mono**    | SF Mono        | ui-monospace, monospace                       |

### Type Scale

| Token             | Size    | Weight | Line Height | Letter Spacing | Usage                             |
| ----------------- | ------- | ------ | ----------- | -------------- | --------------------------------- |
| `type-display-lg` | 42px    | 900    | 1.0         | -2px           | Hero terms, primary content       |
| `type-display-md` | 36px    | 900    | 1.1         | -2px           | Screen titles                     |
| `type-display-sm` | 28px    | 800    | 1.2         | -1px           | Section headers                   |
| `type-heading`    | 20px    | 900    | 1.3         | -1px           | Card titles, navigation           |
| `type-body-lg`    | 16px    | 400    | 1.5         | 0              | Primary body text, definitions    |
| `type-body`       | 14px    | 400    | 1.5         | 0              | Secondary body text               |
| `type-body-sm`    | 13px    | 400    | 1.4         | 0              | Tertiary text, hints              |
| `type-label`      | 10-11px | 800    | 1.2         | 1px            | Labels, category tags (uppercase) |
| `type-mono`       | 12-13px | 400    | 1.4         | 0              | Metadata, technical info          |

## 4.2 Typography Rules

### Headlines

- Always use SF Pro Display
- Always use weight 800-900
- Always use negative letter-spacing (-1px to -2px)
- Consider uppercase for maximum impact

### Body Text

- Always use SF Pro Text
- Use weight 400 for readability
- Maintain 1.5 line height for comfortable reading
- Maximum line length: 65 characters

### Labels & Metadata

- Use uppercase sparingly but consistently
- Apply positive letter-spacing (0.5px - 1px) to uppercase text
- Use SF Mono for technical metadata (counts, versions, timestamps)

### Code Examples

```css
/* Display Large - Hero Terms */
.type-display-lg {
  font-family: 'SF Pro Display', -apple-system, sans-serif;
  font-size: 42px;
  font-weight: 900;
  line-height: 1;
  letter-spacing: -2px;
  text-transform: uppercase;
}

/* Body - Definitions */
.type-body-lg {
  font-family: 'SF Pro Text', -apple-system, sans-serif;
  font-size: 16px;
  font-weight: 400;
  line-height: 1.5;
  letter-spacing: 0;
}

/* Label - Category Tags */
.type-label {
  font-family: 'SF Pro Text', -apple-system, sans-serif;
  font-size: 10px;
  font-weight: 800;
  line-height: 1.2;
  letter-spacing: 1px;
  text-transform: uppercase;
}

/* Mono - Metadata */
.type-mono {
  font-family: 'SF Mono', ui-monospace, monospace;
  font-size: 12px;
  font-weight: 400;
  line-height: 1.4;
}
```

---

# 5. Spacing & Layout

## 5.1 Spacing Scale

We use an 4px base unit with a geometric progression for consistent spacing.

| Token      | Value | Usage                          |
| ---------- | ----- | ------------------------------ |
| `space-0`  | 0px   | Reset                          |
| `space-1`  | 4px   | Tight spacing, inline elements |
| `space-2`  | 8px   | Related elements, icon gaps    |
| `space-3`  | 12px  | Standard gap                   |
| `space-4`  | 16px  | Section spacing, card padding  |
| `space-5`  | 20px  | Screen margins (horizontal)    |
| `space-6`  | 24px  | Major section breaks           |
| `space-8`  | 32px  | Large gaps                     |
| `space-10` | 40px  | Extra large gaps               |

## 5.2 Layout Grid

### Mobile (375px - 428px)

- Columns: 4
- Gutter: 16px
- Margin: 20px (left and right)
- Content width: 335px - 388px

### Safe Areas

- Top: Dynamic Island clearance (36px from top of screen content)
- Bottom: Home indicator clearance (34px minimum)

## 5.3 Border Specifications

Neo-Brutalism relies heavily on visible borders. Use these consistently:

| Token             | Value                         | Usage                          |
| ----------------- | ----------------------------- | ------------------------------ |
| `border-subtle`   | 1px solid color-border        | Dividers, nested containers    |
| `border-standard` | 2px solid color-border-strong | Standard Neo-Brutalist outline |
| `border-heavy`    | 3px solid color-border-strong | Primary cards, major elements  |

## 5.4 Shadow Specifications

All shadows are hard (no blur) with solid color.

| Token            | Value (Dark Mode) | Value (Light Mode)  | Usage                  |
| ---------------- | ----------------- | ------------------- | ---------------------- |
| `shadow-sm`      | 2px 2px 0px #000  | 2px 2px 0px #0D0D0D | Small elements, inputs |
| `shadow-md`      | 4px 4px 0px #000  | 4px 4px 0px #0D0D0D | Cards, buttons         |
| `shadow-lg`      | 8px 8px 0px #000  | 8px 8px 0px #0D0D0D | Modals, overlays       |
| `shadow-pressed` | 1px 1px 0px #000  | 1px 1px 0px #0D0D0D | Pressed button state   |

## 5.5 Corner Radius

Neo-Brutalism favors sharp corners. Use radius sparingly.

| Token         | Value  | Usage                                    |
| ------------- | ------ | ---------------------------------------- |
| `radius-none` | 0px    | Most elements, true brutalist            |
| `radius-sm`   | 2px    | Subtle softening for very small elements |
| `radius-pill` | 9999px | Pills, toggles (exception to sharp rule) |

---

# 6. Iconography

## 6.1 Icon Style

Icons in Vwa are functional, not decorative. They should be immediately recognizable and consistent with our Neo-Brutalist aesthetic.

**Icon Characteristics:**

- Stroke-based (not filled) for most UI icons
- 2px - 2.5px stroke weight
- Square or rounded stroke caps depending on context
- No decorative elements

## 6.2 Icon Sizes

| Token      | Size | Stroke | Usage                              |
| ---------- | ---- | ------ | ---------------------------------- |
| `icon-sm`  | 16px | 2px    | Inline with text, tertiary actions |
| `icon-md`  | 18px | 2px    | Standard UI icons                  |
| `icon-lg`  | 20px | 2.5px  | Primary actions, navigation        |
| `icon-xl`  | 24px | 2.5px  | Playback controls                  |
| `icon-2xl` | 28px | 3px    | Hero icons, primary CTAs           |

## 6.3 Core Icon Set

**Navigation:**

- Back arrow (chevron left)
- Forward arrow (chevron right)
- Close (X)
- Search (magnifying glass)
- Menu (hamburger)

**Playback:**

- Play (triangle)
- Pause (two vertical bars)
- Skip forward
- Skip back
- Waveform (for audio visualization)

**Actions:**

- Bookmark
- Share
- Copy
- Settings

## 6.4 Icon Color

Icons inherit text color by default:

- Primary icons: `color-text`
- Secondary icons: `color-text-secondary`
- Muted icons: `color-text-muted`
- Interactive icons on buttons: White (#FFFFFF) on primary backgrounds

---

# 7. Component Library

## 7.1 Buttons

### Primary Button (CTA)

The main call-to-action button. Used for primary actions like "Play" or "Learn".

**Specifications:**

- Background: `color-primary`
- Border: 3px solid `color-border-strong`
- Shadow: `shadow-md`
- Text: White, `type-body` weight 700
- Padding: 16px 24px (standard), 20px (square icon button)
- Corner radius: `radius-none`

**States:**
| State | Transform | Shadow | Background |
|-------|-----------|--------|------------|
| Default | none | `shadow-md` | `color-primary` |
| Hover | none | `shadow-md` | `color-primary-hover` |
| Pressed | translate(2px, 2px) | `shadow-pressed` | `color-primary-pressed` |
| Disabled | none | none | `color-text-muted` (40% opacity) |

### Secondary Button

For secondary actions like "Browse" or "Skip".

**Specifications:**

- Background: `color-surface`
- Border: 2px solid `color-border-strong`
- Shadow: `shadow-sm` or `shadow-md`
- Text: `color-text`, `type-body` weight 600
- Padding: 14px 16px

**States:**
Same transform behavior as Primary Button.

### Segmented Control (Language Toggle)

A horizontal button group for mutually exclusive options.

**Container Specifications:**

- Background: `color-surface`
- Border: 2px solid `color-border-strong`
- Shadow: `shadow-sm`
- No internal gaps

**Segment Specifications:**

- Padding: 8px 16px
- Border-right: 2px solid `color-border-strong` (except last)
- Active background: `color-primary`
- Active text: White
- Inactive text: `color-text-secondary`

## 7.2 Cards

### Content Card

The main container for phrase content.

**Specifications:**

- Background: `color-surface`
- Border: 3px solid `color-border-strong`
- Shadow: `shadow-md`
- Padding: 16px (internal sections may vary)
- Corner radius: `radius-none`

**Internal Sections:**

- Header (category tag + term)
- Divider (3px height, `color-border-strong`)
- Translation section
- Example section (nested card with `border-subtle`)
- Progress indicator

### List Item Card

Used in the browse/directory view.

**Specifications:**

- Background: `color-surface`
- Border: 2px solid `color-border-strong`
- Shadow: `shadow-md`
- Padding: 16px
- Corner radius: `radius-none`

**Internal Layout:**

- Index badge (48x48px, `color-accent` background)
- Content area (term + definition)
- Chevron icon

## 7.3 Tags & Badges

### Category Tag

Displays the category of a slang term (TRUTH, PRAISE, etc.).

**Specifications:**

- Background: `color-accent`
- Border: 2px solid `color-border-strong`
- Text: #0D0D0D (always dark), `type-label`
- Padding: 4px 12px
- Corner radius: `radius-none`

### Index Badge

Displays the numerical index in lists.

**Specifications:**

- Size: 48x48px
- Background: `color-accent`
- Border: 2px solid `color-border-strong`
- Text: #0D0D0D, SF Pro Display weight 900, 18px
- Corner radius: `radius-none`

## 7.4 Progress Indicators

### Segmented Progress Bar

Shows position within a sequence of items.

**Specifications:**

- Container: flex row, 4px gap
- Inactive segment: flex 1, 4px height, `color-border`
- Active segment: flex 3, 4px height, `color-primary`
- Transition: all 200ms ease

### Counter

Displays current position as text (e.g., "01/06").

**Specifications:**

- Font: SF Mono, 11px
- Color: `color-text-muted`
- Format: Zero-padded (01, 02, etc.)

## 7.5 Audio Visualization

### Waveform

Visual representation of audio playback.

**Specifications:**

- Container: 100% width, 32px height
- Background: `color-surface`
- Border: 2px solid `color-border`
- Padding: 8px 16px
- Bars: 16 bars, 3px width, 4px gap
- Bar height (idle): 4px (uniform)
- Bar height (playing): 4px - 24px (randomized, 80ms interval)
- Bar color (idle): `color-border`
- Bar color (playing): `color-primary`
- Transition: height 80ms ease (playing), all 300ms ease (stopping)

## 7.6 Inputs

### Search Input

**Specifications:**

- Background: `color-surface`
- Border: 2px solid `color-border-strong`
- Shadow: `shadow-sm`
- Padding: 12px 16px
- Icon: Search icon, `color-text-muted`, 18px
- Text: `type-body`, weight 600
- Placeholder: Uppercase, `color-text-muted`

**Clear Button:**

- Size: 24x24px
- Background: `color-text-muted`
- Icon: X, `color-surface`, 12px

## 7.7 Navigation

### Back Button

**Specifications:**

- Icon: Chevron left, 12x20px, stroke 3px
- Text: "BACK", `type-body` weight 700
- Color: `color-primary`
- Padding: 8px (touch target expansion)

### Browse Entry Button

Full-width button linking to directory view.

**Specifications:**

- Same as Secondary Button
- Layout: Space-between with icon left, text center, chevron right
- Icon: Search, 18px
- Text: "BROWSE ALL PHRASES", weight 600

---

# 8. Animation & Interaction

## 8.1 Animation Principles

1. **Purpose Over Polish** â€” Every animation must serve a functional purpose.
2. **Quick Response** â€” Interactions should feel immediate (< 100ms for feedback).
3. **Physical Metaphor** â€” Elements should behave like physical objects.
4. **Consistent Timing** â€” Use a limited set of duration values.

## 8.2 Duration Scale

| Token              | Value | Usage                             |
| ------------------ | ----- | --------------------------------- |
| `duration-instant` | 75ms  | Button press feedback             |
| `duration-fast`    | 150ms | Toggle states, micro-interactions |
| `duration-normal`  | 200ms | Standard transitions              |
| `duration-slow`    | 300ms | Larger element transitions        |

## 8.3 Easing Functions

| Token         | Value                             | Usage                        |
| ------------- | --------------------------------- | ---------------------------- |
| `ease-out`    | cubic-bezier(0, 0, 0.2, 1)        | Elements entering view       |
| `ease-in`     | cubic-bezier(0.4, 0, 1, 1)        | Elements exiting view        |
| `ease-in-out` | cubic-bezier(0.4, 0, 0.2, 1)      | Standard state changes       |
| `ease-spring` | cubic-bezier(0.34, 1.56, 0.64, 1) | Bouncy, playful interactions |

## 8.4 Interaction Patterns

### Button Press

When a user presses a button:

1. Immediately (75ms) translate the button 2px right and 2px down
2. Reduce shadow from `shadow-md` to `shadow-pressed`
3. On release, return to original position with same timing

```css
.button {
  transition: transform 75ms ease, box-shadow 75ms ease;
}

.button:active {
  transform: translate(2px, 2px);
  box-shadow: 1px 1px 0px var(--shadow-color);
}
```

### Card Transition (Phrase Change)

When navigating between phrases:

1. Current card: Scale to 0.98, translateY 4px, opacity 0.7 (200ms)
2. Update content
3. New card: Return to scale 1, translateY 0, opacity 1 (200ms)

### Waveform Animation

During audio playback:

1. Every 80ms, generate 16 random heights between 4px and 24px
2. Apply heights to bars with 80ms transition
3. On stop, transition all bars to 4px over 300ms

### Progress Bar Update

When phrase index changes:

1. Previous active segment: Shrink flex from 3 to 1 (200ms)
2. New active segment: Grow flex from 1 to 3 (200ms)
3. Color updates immediately (no transition)

### Screen Transitions

Navigation between screens should use standard iOS patterns:

- Push: New screen slides in from right
- Pop: Current screen slides out to right
- Modal: Sheet rises from bottom

---

# 9. Accessibility

## 9.1 Color Contrast

All text must meet WCAG 2.1 AA standards:

- Normal text: 4.5:1 minimum contrast ratio
- Large text (18px+ bold, 24px+ regular): 3:1 minimum
- UI components: 3:1 minimum against adjacent colors

**Verified Contrast Ratios (Dark Mode):**
| Element | Foreground | Background | Ratio | Pass |
|---------|------------|------------|-------|------|
| Primary text | #FFFFFF | #0D0D0D | 21:1 | AAA |
| Secondary text | #A3A3A3 | #0D0D0D | 10.4:1 | AAA |
| Muted text | #666666 | #0D0D0D | 5.3:1 | AA |
| Primary button | #FFFFFF | #FF6B00 | 3.2:1 | AA Large |
| Category tag | #0D0D0D | #FFE600 | 15.4:1 | AAA |

## 9.2 Touch Targets

All interactive elements must have a minimum touch target of 44x44 points (iOS HIG).

**Implementation:**

- If visual element is smaller than 44px, expand touch target with padding
- Ensure adequate spacing between adjacent touch targets (minimum 8px)

## 9.3 Screen Reader Support

### Semantic Structure

- Use proper heading hierarchy (H1 for screen title, H2 for sections)
- Mark interactive elements with appropriate roles
- Provide labels for all form inputs

### Content Labels

- Term: Announce as heading
- Definition: Announce as paragraph
- Category: Announce as "Category: [value]"
- Progress: Announce as "Phrase [current] of [total]"
- Playback: Announce button state ("Play" / "Pause")

### Example Accessibility Labels

```jsx
// Term card
<View accessibilityRole="header" accessibilityLevel={1}>
  <Text>NO CAP</Text>
</View>

// Progress indicator
<View
  accessibilityRole="text"
  accessibilityLabel={`Phrase ${currentIndex + 1} of ${total}`}
>
  {/* Visual progress bar */}
</View>

// Play button
<TouchableOpacity
  accessibilityRole="button"
  accessibilityLabel={isPlaying ? "Pause audio" : "Play audio"}
  accessibilityState={{ selected: isPlaying }}
>
  {/* Icon */}
</TouchableOpacity>
```

## 9.4 Motion Sensitivity

Respect user's reduced motion preferences:

```css
@media (prefers-reduced-motion: reduce) {
  * {
    animation-duration: 0.01ms !important;
    transition-duration: 0.01ms !important;
  }
}
```

For waveform animation, show a static visualization when reduced motion is enabled.

## 9.5 Text Scaling

Support Dynamic Type (iOS) with the following constraints:

- Minimum: 85% of default size
- Maximum: 150% of default size (to prevent layout breaking)
- Test at both extremes

---

# 10. Screen Specifications

## 10.1 Main Screen (TTS View)

**Purpose:** Display current slang term with definition, translation, example, and playback controls.

### Layout Structure

```
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚           Status Bar                â”‚
â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
â”‚  [Logo] VWA          [ES] [FR]     â”‚  â† Header
â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
â”‚ â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â” â”‚
â”‚ â”‚ [CATEGORY TAG]                  â”‚ â”‚
â”‚ â”‚                                 â”‚ â”‚
â”‚ â”‚ TERM                            â”‚ â”‚
â”‚ â”‚ English definition              â”‚ â”‚
â”‚ â”‚ â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€ â”‚ â”‚
â”‚ â”‚ ESPAÃ‘OL/FRANÃ‡AIS                â”‚ â”‚
â”‚ â”‚ Translated definition           â”‚ â”‚
â”‚ â”‚                                 â”‚ â”‚
â”‚ â”‚ â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â” â”‚ â”‚
â”‚ â”‚ â”‚ EXAMPLE                     â”‚ â”‚ â”‚
â”‚ â”‚ â”‚ "Example sentence"          â”‚ â”‚ â”‚
â”‚ â”‚ â”‚ â†’ Translated example        â”‚ â”‚ â”‚
â”‚ â”‚ â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜ â”‚ â”‚
â”‚ â”‚                                 â”‚ â”‚
â”‚ â”‚ â–ƒ â–ƒâ–ƒâ–ƒâ–ƒâ–ƒâ–ƒâ–ƒâ–ƒâ–ƒâ–ƒâ–ƒâ–ƒ â–ƒ â–ƒ â–ƒ          â”‚ â”‚  â† Progress
â”‚ â”‚ 01/06                           â”‚ â”‚
â”‚ â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜ â”‚
â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
â”‚      [â–“â–“â–“â–“â–“â–“â–“â–“â–“â–“â–“â–“â–“â–“â–“â–“]            â”‚  â† Waveform
â”‚                                     â”‚
â”‚      [â—€â—€]    [â–¶]    [â–¶â–¶]           â”‚  â† Controls
â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
â”‚  ðŸ” BROWSE ALL PHRASES         â†’   â”‚  â† Browse CTA
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
```

### Component Specifications

**Header (64px height)**

- Horizontal padding: 20px
- Vertical padding: 8px top, 16px bottom
- Logo: 32x32px
- Brand text: 20px, weight 900
- Language toggle: As specified in Components

**Content Card (Flex: 1)**

- Margin: 20px horizontal, 16px bottom
- Border: 3px solid `color-border-strong`
- Shadow: `shadow-md`
- Internal padding: 16px

**Controls Section**

- Waveform margin-bottom: 16px
- Button row: centered, 16px gap
- Previous/Next: 48x48px
- Play/Pause: 72x72px

**Browse CTA**

- Margin: 20px horizontal, 24px bottom
- Full specifications in Components

## 10.2 Browse Screen (Directory View)

**Purpose:** Display searchable list of all available slang terms.

### Layout Structure

```
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚           Status Bar                â”‚
â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
â”‚  â† BACK                             â”‚  â† Navigation
â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
â”‚  BROWSE                             â”‚  â† Title
â”‚  6 TERMS AVAILABLE                  â”‚  â† Subtitle
â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
â”‚  ðŸ” SEARCH...                    âœ•  â”‚  â† Search
â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
â”‚ â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â” â”‚
â”‚ â”‚ [01] NO CAP                    â†’ â”‚ â”‚
â”‚ â”‚      Something is true...       â”‚ â”‚
â”‚ â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜ â”‚
â”‚ â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â” â”‚
â”‚ â”‚ [02] LOWKEY                    â†’ â”‚ â”‚
â”‚ â”‚      Subtly, secretly...        â”‚ â”‚
â”‚ â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜ â”‚
â”‚ â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â” â”‚
â”‚ â”‚ [03] SLAY                      â†’ â”‚ â”‚
â”‚ â”‚      To do something...         â”‚ â”‚
â”‚ â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜ â”‚
â”‚                 ...                 â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
```

### Component Specifications

**Back Button**

- Position: Top left, below status bar
- Padding: 8px left (expand touch target)
- Margin-bottom: 16px

**Title Section**

- Horizontal padding: 20px
- Title: 36px, weight 900, uppercase
- Subtitle: 13px, SF Mono, `color-text-muted`
- Margin-bottom: 16px

**Search Input**

- Horizontal margin: 20px
- Full width minus margins
- Margin-bottom: 16px

**List**

- Horizontal padding: 20px
- Item gap: 12px
- Bottom padding: 24px (scroll safety)

**List Item Card**

- Full specifications in Components
- Tap action: Navigate to TTS view with selected phrase

**Empty State**

- Centered in list area
- "NO RESULTS FOR '[query]'" â€” 16px, weight 700
- "TRY A DIFFERENT TERM" â€” 13px, SF Mono, muted

---

# 11. Implementation Guidelines

## 11.1 Technology Stack (Recommended)

| Layer          | Technology                     | Rationale                          |
| -------------- | ------------------------------ | ---------------------------------- |
| **Framework**  | React Native                   | Cross-platform, strong iOS support |
| **Styling**    | StyleSheet (RN) or Tailwind RN | Performance, design token mapping  |
| **State**      | Zustand or Context             | Simple, sufficient for app scope   |
| **Audio**      | expo-av                        | Reliable TTS playback              |
| **Navigation** | React Navigation               | Standard, well-documented          |

## 11.2 Design Token Implementation

Create a centralized theme file:

```typescript
// theme.ts
export const colors = {
  dark: {
    bg: '#0D0D0D',
    surface: '#1A1A1A',
    surfaceRaised: '#242424',
    border: '#333333',
    borderStrong: '#FFFFFF',
    text: '#FFFFFF',
    textSecondary: '#A3A3A3',
    textMuted: '#666666',
    primary: '#FF6B00',
    accent: '#FFE600',
    shadow: '#000000',
  },
  light: {
    bg: '#F5F5F0',
    surface: '#FFFFFF',
    surfaceRaised: '#FFFFFF',
    border: '#E0E0E0',
    borderStrong: '#0D0D0D',
    text: '#0D0D0D',
    textSecondary: '#525252',
    textMuted: '#858585',
    primary: '#FF5500',
    accent: '#FFD600',
    shadow: '#0D0D0D',
  },
}

export const spacing = {
  0: 0,
  1: 4,
  2: 8,
  3: 12,
  4: 16,
  5: 20,
  6: 24,
  8: 32,
  10: 40,
}

export const typography = {
  displayLg: {
    fontFamily: 'SF Pro Display',
    fontSize: 42,
    fontWeight: '900',
    lineHeight: 42,
    letterSpacing: -2,
  },
  // ... rest of scale
}

export const shadows = {
  sm: (isDark: boolean) => ({
    shadowColor: isDark ? '#000' : '#0D0D0D',
    shadowOffset: { width: 2, height: 2 },
    shadowOpacity: 1,
    shadowRadius: 0,
    elevation: 2,
  }),
  md: (isDark: boolean) => ({
    shadowColor: isDark ? '#000' : '#0D0D0D',
    shadowOffset: { width: 4, height: 4 },
    shadowOpacity: 1,
    shadowRadius: 0,
    elevation: 4,
  }),
}
```

## 11.3 Component Architecture

Follow atomic design principles:

```
components/
â”œâ”€â”€ atoms/
â”‚   â”œâ”€â”€ Button/
â”‚   â”œâ”€â”€ Tag/
â”‚   â”œâ”€â”€ Icon/
â”‚   â””â”€â”€ Text/
â”œâ”€â”€ molecules/
â”‚   â”œâ”€â”€ SearchInput/
â”‚   â”œâ”€â”€ ProgressBar/
â”‚   â”œâ”€â”€ Waveform/
â”‚   â””â”€â”€ LanguageToggle/
â”œâ”€â”€ organisms/
â”‚   â”œâ”€â”€ PhraseCard/
â”‚   â”œâ”€â”€ ListItem/
â”‚   â””â”€â”€ PlaybackControls/
â””â”€â”€ templates/
    â”œâ”€â”€ TTSScreen/
    â””â”€â”€ BrowseScreen/
```

## 11.4 Performance Guidelines

1. **Memoize expensive components** â€” Use `React.memo` for list items
2. **Optimize waveform animation** â€” Use `useNativeDriver: true` where possible
3. **Lazy load screens** â€” Use React Navigation's lazy loading
4. **Image optimization** â€” Pre-scale any images to exact display size
5. **Reduce re-renders** â€” Use callback refs and stable references

## 11.5 Testing Requirements

| Test Type         | Coverage Target     | Tools                 |
| ----------------- | ------------------- | --------------------- |
| Unit              | 80% for utilities   | Jest                  |
| Component         | All atoms/molecules | React Testing Library |
| Integration       | Critical user flows | Detox                 |
| Accessibility     | All screens         | axe, manual VoiceOver |
| Visual Regression | All components      | Chromatic or Percy    |

---

# 12. Voice & Tone

## 12.1 Content Guidelines

### Term Definitions

- Lead with the most common meaning
- Keep under 15 words
- Use plain language, avoid jargon

**Good:** "Something is true, no exaggeration"
**Bad:** "An emphatic declaration of veracity without hyperbolic embellishment"

### Translations

- Match the register of the original term
- Include cultural context when meanings don't translate directly
- 2-3 sentences maximum

### Examples

- Use realistic scenarios
- Reflect how the term is actually used
- Include a natural translation, not word-for-word

## 12.2 UI Copy

### Button Labels

- Use action verbs
- 1-3 words maximum
- Sentence case or ALL CAPS (consistent within context)

### Error Messages

- Be specific about what went wrong
- Suggest a solution
- Never blame the user

**Good:** "No phrases match 'xyz'. Try a different term."
**Bad:** "Error: Invalid search query."

### Empty States

- Acknowledge the situation
- Provide a next step
- Keep the tone light

---

# Appendix A: Asset Checklist

## Required Before Launch

- [ ] App icon (1024x1024 + all iOS sizes)
- [ ] Splash screen
- [ ] SF Pro font license (or system font fallback)
- [ ] Audio files for all TTS content
- [ ] Localized strings (English, Spanish content)

## Design Deliverables

- [ ] Figma component library
- [ ] Exported SVG icon set
- [ ] Color palette file (.ase or .sketchpalette)
- [ ] Typography specimen
- [ ] Motion prototypes (Principle or Figma)

---

# Appendix B: Changelog

| Version | Date       | Changes                        |
| ------- | ---------- | ------------------------------ |
| 1.0     | 2026-01-29 | Initial design system document |

---

**Document Owner:** Product Design Team
**Last Updated:** January 29, 2026
**Status:** Draft v1.0
