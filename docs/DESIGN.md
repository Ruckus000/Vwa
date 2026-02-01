# Vwa — Design Document
> American English Slang → Spanish/French Translation App

**Version:** 1.0  
**Platform:** iOS (Swift/SwiftUI)  
**Last Updated:** January 2026

---

## 1. Product Vision

**What it is:** A focused language tool that helps Spanish and French speakers understand American English slang through text-to-speech (TTS) pronunciation and contextual explanations.

**What it is not:** A full language learning platform, a flashcard app, or a gamified experience.

**Core Value Proposition:** "Hear it. Understand it. Use it."

---

## 2. ChatGPT Design Philosophy — Applied to Vwa

After deep analysis of ChatGPT's interface, these are the core principles we're adopting:

### 2.1 Radical Clarity Over Ornamentation

ChatGPT succeeds because it's **invisible**. The interface disappears so content can breathe.

| ChatGPT Pattern | Vwa Application |
|-----------------|-----------------|
| Single-column conversation | Single-column phrase display |
| Ample white space | Generous padding, no cramped elements |
| Subtle contrast via spacing, not color | User input vs. system output differentiated by position, not heavy visual borders |
| No decorative elements | Zero icons that don't serve a function |

### 2.2 System-Native Feel

ChatGPT uses **platform-native fonts and colors** to feel like part of iOS, not a foreign app.

**Vwa will:**
- Use **SF Pro** exclusively (iOS system font)
- Inherit iOS Dynamic Type for accessibility
- Use **system semantic colors** (`label`, `secondaryLabel`, `systemBackground`) as the foundation
- Apply brand accent (amber) sparingly—only for interactive elements

### 2.3 Sub-300ms Responsiveness

ChatGPT maintains a "chat illusion" by responding instantly. Anything slower breaks the spell.

**Vwa requirements:**
- TTS playback must begin within 200ms of tap
- Search results must appear as user types (debounced 150ms)
- No loading spinners for <500ms operations—use subtle shimmer if needed
- Transitions must be 250ms max (iOS standard)

### 2.4 Obvious Patterns

ChatGPT works because it banks on **two patterns everyone knows**: texting and conversation.

**Vwa banks on:**
- The **music player** mental model (play/pause, scrubber, repeat)
- The **search bar** pattern (type → filter → select)
- The **dictionary** mental model (word → definition → example)

### 2.5 Content-First Hierarchy

ChatGPT's typography creates hierarchy without heavy styling.

**Vwa typography hierarchy:**
```
Slang Term    → Title 1, Bold (28pt)
Definition   → Body, Regular (17pt)  
Example      → Body, Secondary color (17pt)
Metadata     → Caption, Tertiary (13pt)
```

---

## 3. Color System

### 3.1 Foundation (Semantic)

| Token | Light Mode | Dark Mode | Usage |
|-------|-----------|-----------|-------|
| `background` | `systemBackground` | `systemBackground` | Primary surface |
| `backgroundSecondary` | `secondarySystemBackground` | `secondarySystemBackground` | Cards, search field |
| `label` | `label` | `label` | Primary text |
| `labelSecondary` | `secondaryLabel` | `secondaryLabel` | Definitions, hints |
| `labelTertiary` | `tertiaryLabel` | `tertiaryLabel` | Metadata, timestamps |

### 3.2 Brand Accent — Amber

**Why amber:** Warm, inviting, high contrast on both light/dark, culturally neutral.

| Token | Light Mode | Dark Mode | Usage |
|-------|-----------|-----------|-------|
| `accent` | `#D97706` (amber-600) | `#F59E0B` (amber-500) | Interactive elements only |
| `accentSubtle` | `#FEF3C7` (amber-100) | `#78350F` (amber-900) | Selected states, highlights |

**Accent usage rules:**
- ✅ Play button fill
- ✅ Language toggle active state  
- ✅ Search cursor/selection
- ❌ Background fills
- ❌ Decorative elements
- ❌ Text (except links)

### 3.3 Semantic Feedback

| Token | Color | Usage |
|-------|-------|-------|
| `success` | System Green | Pronunciation complete |
| `error` | System Red | Network/playback error |

---

## 4. Typography

Using **SF Pro** with iOS Dynamic Type support.

| Style | Weight | Size | Line Height | Use |
|-------|--------|------|-------------|-----|
| `largeTitle` | Bold | 34pt | 41pt | Screen titles (if any) |
| `title1` | Bold | 28pt | 34pt | Slang term |
| `title3` | Semibold | 20pt | 25pt | Section headers |
| `body` | Regular | 17pt | 22pt | Definitions, examples |
| `callout` | Regular | 16pt | 21pt | Buttons, labels |
| `caption1` | Regular | 12pt | 16pt | Metadata, hints |

**Rules:**
- No custom fonts. Ever.
- Support Dynamic Type (accessibility)
- Line length: 65-75 characters max for readability

---

## 5. Spacing System

8pt grid, consistent with iOS HIG.

| Token | Value | Usage |
|-------|-------|-------|
| `spacing-xs` | 4pt | Icon-to-label gaps |
| `spacing-sm` | 8pt | Related element groups |
| `spacing-md` | 16pt | Section padding |
| `spacing-lg` | 24pt | Between major sections |
| `spacing-xl` | 32pt | Screen edge margins (compact) |
| `spacing-2xl` | 48pt | Screen edge margins (regular) |

---

## 6. Information Architecture

```
┌─────────────────────────────────────────┐
│                  Vwa                    │
├─────────────────────────────────────────┤
│                                         │
│  ┌─────────────────────────────────┐   │
│  │      TTS Screen (Primary)       │   │
│  │   - Current phrase display      │   │
│  │   - Audio playback controls     │   │
│  │   - Language toggle (ES/FR)     │   │
│  │   - "Browse" entry point        │   │
│  └─────────────────────────────────┘   │
│                  │                      │
│                  ▼                      │
│  ┌─────────────────────────────────┐   │
│  │   Directory Screen (Search)     │   │
│  │   - Search bar                  │   │
│  │   - Results list                │   │
│  │   - Category filters (future)   │   │
│  └─────────────────────────────────┘   │
│                                         │
└─────────────────────────────────────────┘
```

**Navigation Model:** 
- TTS is home/primary
- Directory is accessed via search icon or "Browse all" action
- Selecting from Directory returns to TTS with that phrase loaded

---

## 7. Screen Specifications

### 7.1 TTS Screen (Primary)

**Purpose:** Display a slang term with its explanation and provide audio playback.

```
┌──────────────────────────────────────────────┐
│ ○ ○ ○                              9:41 AM   │  ← Status bar
├──────────────────────────────────────────────┤
│                                              │
│                                              │
│         [ES]  [FR]                           │  ← Language toggle (pill style)
│                                              │
│                                              │
│              "No cap"                        │  ← Slang term (title1, centered)
│                                              │
│     ─────────────────────────────            │  ← Subtle divider
│                                              │
│   Significa que algo es verdad,              │  ← Definition (body, secondary)
│   sin exageración. Usado para                │
│   enfatizar sinceridad.                      │
│                                              │
│   "No cap, that movie was fire"              │  ← Example (body, tertiary, italic)
│   → Sin mentir, esa película                 │
│     estuvo increíble                         │
│                                              │
│                                              │
│                                              │
│                                              │
│         ◀◀    [ ▶ ]    ▶▶                   │  ← Playback controls
│                                              │
│                                              │
│  ┌──────────────────────────────────────┐   │
│  │  🔍  Browse all phrases...            │   │  ← Entry to Directory
│  └──────────────────────────────────────┘   │
│                                              │
└──────────────────────────────────────────────┘
```

**Components:**

1. **Language Toggle**
   - Segmented control style
   - Two options: ES (Spanish), FR (French)
   - Active state: amber fill, white text
   - Inactive state: transparent, secondary label

2. **Phrase Display**
   - Term: `title1`, bold, centered
   - Definition: `body`, `labelSecondary`, left-aligned
   - Example: `body`, `labelTertiary`, italic, indented

3. **Playback Controls**
   - Large central play/pause (48pt tap target)
   - Skip previous/next (32pt)
   - Optional: playback speed (0.75x, 1x, 1.25x) — YAGNI for MVP

4. **Directory Entry**
   - Search field style (rounded rect, secondary background)
   - Tapping opens Directory screen

**States:**
- Default (showing a phrase)
- Playing (play button → pause button, subtle pulse on term)
- Loading (shimmer on definition area, <500ms)
- Error (inline error message, retry button)
- Empty (first launch — show onboarding prompt)

---

### 7.2 Directory Screen

**Purpose:** Search and browse all available slang phrases.

```
┌──────────────────────────────────────────────┐
│ ○ ○ ○                              9:41 AM   │
├──────────────────────────────────────────────┤
│  ←  Browse Phrases                           │  ← Nav bar with back
├──────────────────────────────────────────────┤
│                                              │
│  ┌──────────────────────────────────────┐   │
│  │  🔍  Search slang...                  │   │  ← Search field
│  └──────────────────────────────────────┘   │
│                                              │
│  ┌──────────────────────────────────────┐   │
│  │  No cap                               │   │
│  │  Something is true, no exaggeration   │   │  ← Result row
│  ├──────────────────────────────────────┤   │
│  │  Lowkey                               │   │
│  │  Subtly, secretly, or moderately      │   │
│  ├──────────────────────────────────────┤   │
│  │  Slay                                 │   │
│  │  To do something exceptionally well   │   │
│  ├──────────────────────────────────────┤   │
│  │  Bussin'                              │   │
│  │  Really good, usually about food      │   │
│  └──────────────────────────────────────┘   │
│                                              │
│                                              │
└──────────────────────────────────────────────┘
```

**Components:**

1. **Search Field**
   - Placeholder: "Search slang..."
   - Clear button appears when text entered
   - Results filter as user types (150ms debounce)

2. **Results List**
   - Term: `callout`, bold
   - Preview: `caption1`, `labelSecondary`, single line, truncated
   - Row height: 60pt
   - Tap → dismiss Directory, load phrase in TTS screen

3. **Empty State**
   - No results: "No phrases match '[query]'"
   - Encourage browsing: "Try a different term or browse all"

**Behavior:**
- List shows all phrases by default (alphabetical)
- Search filters client-side (data is local)
- Pull-to-refresh not needed (static data)

---

## 8. Interaction Patterns

### 8.1 Playback Gesture

| Gesture | Action |
|---------|--------|
| Tap play | Start TTS playback |
| Tap pause | Pause playback |
| Tap skip next | Load next phrase (alphabetical or random — TBD) |
| Tap skip previous | Load previous phrase |
| Long press play | Loop current phrase (accessibility) |

### 8.2 Language Switch

- Instant switch, no confirmation
- Definition updates immediately
- Audio does NOT auto-play on switch (user controls playback)

### 8.3 Search

- Focus search → keyboard appears
- Type → results filter live
- Tap result → keyboard dismisses, screen closes, phrase loads
- Tap outside / swipe down → dismiss without selection

---

## 9. Accessibility

Following WCAG 2.1 AA and iOS Accessibility guidelines.

| Requirement | Implementation |
|-------------|----------------|
| Dynamic Type | All text scales with system settings |
| VoiceOver | All controls labeled, logical reading order |
| Color contrast | 4.5:1 minimum for text (amber on white passes) |
| Reduce Motion | Disable animations if system setting enabled |
| Haptics | Light haptic on playback start/stop |
| Minimum tap target | 44pt × 44pt |

---

## 10. Data Model (UI Layer)

```swift
struct SlangPhrase: Identifiable {
    let id: String          // Urban Dictionary defid
    let term: String        // "No cap"
    let definition: String  // English definition
    let example: String     // Usage example
    let spanishDefinition: String
    let spanishExample: String
    let frenchDefinition: String
    let frenchExample: String
}

enum Language: String, CaseIterable {
    case spanish = "ES"
    case french = "FR"
}
```

---

## 11. MVP Scope (YAGNI Applied)

### In Scope (Build Now)
- [x] TTS screen with single phrase display
- [x] Play/pause audio playback
- [x] Spanish/French toggle
- [x] Directory screen with search
- [x] Light/dark mode support
- [x] Basic accessibility (VoiceOver, Dynamic Type)

### Out of Scope (Build Later, If Needed)
- [ ] Favorites/bookmarks
- [ ] Playback speed control
- [ ] Offline TTS
- [ ] Categories/tags
- [ ] Usage statistics
- [ ] Onboarding tutorial
- [ ] Share functionality
- [ ] Widget

---

## 12. Open Questions

1. **TTS Engine:** System `AVSpeechSynthesizer` or third-party (ElevenLabs, etc.)?
   - Recommendation: Start with system TTS (KISS), upgrade if quality insufficient

2. **Skip Behavior:** Next phrase alphabetically, or random?
   - Recommendation: Random (discovery-focused UX)

3. **Translation Source:** Pre-translated in JSON, or API-based?
   - Recommendation: Pre-translated static JSON (offline-first, KISS)

4. **First Launch:** Empty TTS screen or pre-loaded phrase?
   - Recommendation: Pre-load a popular phrase ("No cap" or "Slay")

---

## 13. Design Checklist (Pre-Implementation)

- [ ] Color tokens defined in SwiftUI `Color` extension
- [ ] Typography styles defined as `Font` extension  
- [ ] Spacing tokens defined as `CGFloat` constants
- [ ] Component library: Button, TextField, SegmentedControl, ListRow
- [ ] Dark mode tested on all screens
- [ ] VoiceOver audit completed
- [ ] Figma/Sketch file exported (if applicable)

---

## Appendix A: ChatGPT Design Principles Summary

| Principle | Description |
|-----------|-------------|
| **Invisible Interface** | UI should disappear; content is the star |
| **System-Native** | Use platform fonts, colors, and patterns |
| **Instant Feedback** | <300ms response for all interactions |
| **Obvious Patterns** | Bank on mental models users already have |
| **Typographic Hierarchy** | Differentiate with size/weight, not decoration |
| **Purposeful Accent** | Brand color only for interactive elements |
| **Distraction-Free** | No ornamental elements that don't serve function |

---

*Document authored for Vwa project. Design decisions follow YAGNI > KISS > SRP > DRY priority.*
