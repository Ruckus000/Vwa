⚠️ DEPRECATED: This document describes the React Native implementation. See vwa-architecture.md for current Swift implementation.
# VWA Mobile Architecture

## Version 1.0 â€” Execution-Ready Outline

---

# 1. Executive Summary

## Overview

VWA ("vwah") is an iOS mobile app that translates Gen Z slang into Spanish and French via voice input. Users speak slang terms into their phone's microphone, and the app displays the definition with translations â€” like Google Translate for slang.

**Core interaction:**

1. User taps microphone â†’ speaks "no cap"
2. App transcribes â†’ searches local dictionary
3. Displays: term, English definition, translated explanation, usage example

## Primary Users & Value Prop

| Persona                             | Need                                             | Value                                                        |
| ----------------------------------- | ------------------------------------------------ | ------------------------------------------------------------ |
| **Spanish/French speakers** (18-35) | Understand English slang in media, conversations | Instant voice-based lookup with native language explanations |
| **Parents/Educators** (35-55)       | Decode what younger people are saying            | Simple, non-judgmental explanations                          |

## MVP Scope

### In Scope (MVP)

- Voice-to-text slang lookup (tap mic â†’ speak â†’ see result)
- Browse/search all terms manually
- Spanish and French translations
- Dark/Light mode
- Full offline functionality
- Favorites (local storage)
- Settings screen

### Out of Scope (MVP)

- User accounts/authentication
- Backend/API
- Analytics
- TTS (text-to-speech) playback
- Onboarding flow (Phase 2)
- Help screen (Phase 2)
- Additional languages

---

# 2. Product Requirements (PRD)

## 2.1 Personas & Jobs-to-be-Done

### Persona A: Maria (Language Learner)

- **Age:** 28, lives in Madrid
- **Context:** Watches American YouTube/TikTok, struggles with slang
- **Job:** "When I hear slang I don't understand, I want to quickly look it up so I can follow the conversation"
- **Frustration:** Google Translate fails on slang; Urban Dictionary is confusing and English-only

### Persona B: Robert (Parent)

- **Age:** 52, French-Canadian
- **Context:** His teenage kids use slang he doesn't understand
- **Job:** "When my kids use words I don't recognize, I want to understand what they mean so I can connect with them"
- **Frustration:** Feels out of touch; asking kids directly is awkward

## 2.2 User Journeys

### Happy Path: Voice Lookup

```
1. User opens app â†’ lands on Main screen
2. User taps microphone button
3. System requests microphone permission (first time only)
4. User speaks: "no cap"
5. App transcribes â†’ shows "Listening..." â†’ shows "Searching..."
6. Match found â†’ displays term card with:
   - Term: "NO CAP"
   - Category tag
   - English definition
   - Spanish/French translation (based on toggle)
   - Example sentence with translation
7. User can tap â™¥ to favorite
```

### Happy Path: Manual Browse

```
1. User taps "Browse All Phrases" button
2. Browse screen shows searchable list of all terms
3. User types in search field â†’ list filters in real-time
4. User taps a term â†’ returns to Main screen with that term displayed
```

### Edge Case: No Match Found

```
1. User speaks term not in dictionary
2. App shows: "Term not found" state
3. Offers: "Try again" button + suggestion to browse manually
```

### Edge Case: Speech Recognition Failure

```
1. User speaks but nothing detected (silence/noise)
2. After 5 seconds timeout â†’ show "Couldn't hear you" message
3. Offer: "Try again" button
```

### Edge Case: Permission Denied

```
1. User taps mic â†’ permission prompt appears
2. User denies permission
3. App shows: "Microphone access required" with button to open Settings
```

## 2.3 Feature List (Prioritized)

### P0 â€” Must Have (MVP Launch)

| Feature               | Description                                 |
| --------------------- | ------------------------------------------- |
| Voice-to-text lookup  | Tap mic â†’ speak â†’ see matching term     |
| Term card display     | Show term, definition, translation, example |
| Language toggle       | Switch between ES/FR translations           |
| Browse screen         | Searchable list of all terms                |
| Manual search         | Type to filter terms in browse              |
| Dark/Light mode       | System preference + manual toggle           |
| Offline functionality | All content bundled, works without internet |

### P1 â€” Should Have (MVP+)

| Feature            | Description                                         |
| ------------------ | --------------------------------------------------- |
| Favorites          | Save terms locally, view in Settings                |
| Settings screen    | Theme toggle, favorites list, app info              |
| Report translation | Flag bad translations (creates local log/shareable) |

### P2 â€” Nice to Have (V1+)

| Feature            | Description                                |
| ------------------ | ------------------------------------------ |
| Onboarding slider  | 3-4 screens explaining app on first launch |
| Help screen        | How-to guide accessible from Settings      |
| Category filtering | Filter browse list by category             |
| Haitian Creole     | Third translation language                 |
| Share term         | Share term card as image                   |

## 2.4 User Stories + Acceptance Criteria (P0)

### US-001: Voice Lookup

**As a** user  
**I want to** speak a slang term into my phone  
**So that** I can quickly find its meaning without typing

**Acceptance Criteria:**

```gherkin
Given I am on the Main screen
When I tap the microphone button
Then the app requests microphone permission (if not granted)
And shows a "Listening..." indicator

Given the app is listening
When I speak a term clearly
Then the app transcribes my speech within 3 seconds
And searches the local dictionary for matches

Given a matching term is found
When the search completes
Then the term card displays with definition and translation

Given no matching term is found
When the search completes
Then a "Term not found" message displays
And a "Try again" button is shown
```

### US-002: Browse Terms

**As a** user  
**I want to** browse all available slang terms  
**So that** I can explore and learn new slang

**Acceptance Criteria:**

```gherkin
Given I am on the Main screen
When I tap "Browse All Phrases"
Then the Browse screen opens
And displays a searchable list of all terms

Given I am on the Browse screen
When I type in the search field
Then the list filters to show only matching terms
And filtering happens in real-time (< 100ms)

Given I am viewing filtered results
When I tap a term
Then I return to the Main screen
And that term is displayed
```

### US-003: Language Toggle

**As a** user  
**I want to** switch between Spanish and French translations  
**So that** I can read definitions in my preferred language

**Acceptance Criteria:**

```gherkin
Given I am viewing a term card
When I tap "ES" in the language toggle
Then the translation section shows Spanish text

Given I am viewing a term card
When I tap "FR" in the language toggle
Then the translation section shows French text

Given I switch languages
When I navigate to a different term
Then my language preference persists
```

## 2.5 Non-Functional Requirements

### Performance

- App launch to interactive: < 2 seconds
- Voice transcription latency: < 3 seconds
- Search/filter response: < 100ms
- Screen transitions: < 300ms

### Accessibility

- VoiceOver support for all interactive elements
- Minimum touch targets: 44x44pt
- Color contrast: WCAG AA (4.5:1 for text)
- Support Dynamic Type (85%-150% scaling)

### Localization

- UI strings in English only (MVP)
- Content translations: Spanish, French
- Right-to-left: Not required (MVP)

### Offline

- 100% offline functionality after initial install
- No network requests required for core features
- All content bundled in app binary

### Reliability

- Crash-free rate target: 99.5%
- Graceful degradation for permission denial
- Error states for all failure modes

---

# 3. UX / IA Outline

## 3.1 Sitemap / Information Architecture

```
VWA App
â”œâ”€â”€ Main Screen (Home)
â”‚   â”œâ”€â”€ Voice Lookup
â”‚   â”œâ”€â”€ Term Card Display
â”‚   â”œâ”€â”€ Language Toggle
â”‚   â””â”€â”€ Navigation to Browse
â”œâ”€â”€ Browse Screen
â”‚   â”œâ”€â”€ Search Input
â”‚   â””â”€â”€ Filterable Term List
â””â”€â”€ Settings Screen (P1)
    â”œâ”€â”€ Theme Toggle
    â”œâ”€â”€ Favorites List
    â”œâ”€â”€ About/Version
    â””â”€â”€ Help (P2)
```

## 3.2 Screen-by-Screen Specs

### Screen: Main (Home)

**Purpose:** Primary interaction screen for voice lookup and term display

**Entry Points:**

- App launch
- Back from Browse screen
- Deep link (future)

**UI Components:**
| Component | Description |
|-----------|-------------|
| Header | Logo + "VWA" wordmark + Language toggle (ES/FR) |
| Term Card | Category tag, term, definition, translation, example, progress indicator |
| Voice Button | Large central button to initiate recording |
| Waveform | Visual feedback during listening (animated bars) |
| Nav Controls | Previous/Next buttons to cycle terms |
| Browse CTA | "Browse All Phrases" button at bottom |

**States:**

| State               | Trigger                  | Display                                     |
| ------------------- | ------------------------ | ------------------------------------------- |
| Default             | App opens                | Shows last viewed term (or first term)      |
| Listening           | Mic button tapped        | Waveform animates, "Listening..." text      |
| Processing          | Speech detected          | "Searching..." text, waveform stops         |
| Success             | Match found              | Term card updates with matched term         |
| No Match            | No match found           | "Term not found" message + Try Again button |
| Error               | Speech recognition fails | "Couldn't hear you" + Try Again button      |
| Permission Required | Mic permission denied    | Explanation + Settings button               |

**Edge Cases:**

- Empty state: Should never occur (always have terms)
- Long definition: Scrollable term card
- Special characters in term: Render as-is (emoji support)

**Analytics Events:** (Future, P2)

- `voice_lookup_started`
- `voice_lookup_success` (term_id)
- `voice_lookup_no_match` (transcript)
- `term_viewed` (term_id, source: voice/browse/nav)
- `language_switched` (to: es/fr)

### Screen: Browse

**Purpose:** Discover and search all available terms

**Entry Points:**

- "Browse All Phrases" button on Main screen

**UI Components:**
| Component | Description |
|-----------|-------------|
| Back Button | Returns to Main screen |
| Title | "BROWSE" + term count |
| Search Input | Text field with search icon, clear button |
| Term List | Scrollable list of term cards (index badge + term + short def) |
| Empty State | Shown when search has no results |

**States:**

| State      | Trigger                | Display                            |
| ---------- | ---------------------- | ---------------------------------- |
| Default    | Screen opens           | Full list of terms, search empty   |
| Filtering  | User types             | List filters in real-time          |
| No Results | Filter matches nothing | "No results for '[query]'" message |

**Edge Cases:**

- Very long list (1000 items): Use virtualized/windowed list (FlatList)
- Rapid typing: Debounce search (150ms)

**Analytics Events:** (Future)

- `browse_screen_opened`
- `browse_search` (query)
- `browse_term_selected` (term_id)

### Screen: Settings (P1)

**Purpose:** App preferences and saved content

**Entry Points:**

- Settings icon on Main screen header (P1)

**UI Components:**
| Component | Description |
|-----------|-------------|
| Back Button | Returns to Main screen |
| Title | "SETTINGS" |
| Theme Toggle | Dark/Light/System options |
| Favorites Section | List of favorited terms (tap to view) |
| About Section | App version, credits |
| Help Button | Links to Help screen (P2) |

## 3.3 Navigation Map

```
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚                      Root Stack                          â”‚
â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
â”‚                                                          â”‚
â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”    push    â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”                   â”‚
â”‚  â”‚  Main    â”‚ â”€â”€â”€â”€â”€â”€â”€â”€â–º  â”‚  Browse  â”‚                   â”‚
â”‚  â”‚  Screen  â”‚ â—„â”€â”€â”€â”€â”€â”€â”€â”€  â”‚  Screen  â”‚                   â”‚
â”‚  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜    pop     â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜                   â”‚
â”‚       â”‚                                                  â”‚
â”‚       â”‚ push                                             â”‚
â”‚       â–¼                                                  â”‚
â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”                                           â”‚
â”‚  â”‚ Settings â”‚  (P1)                                     â”‚
â”‚  â”‚  Screen  â”‚                                           â”‚
â”‚  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜                                           â”‚
â”‚                                                          â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
```

**Navigation Library:** React Navigation (Native Stack)

- Simple stack navigator
- No tabs needed (MVP scope)
- No modals needed (MVP scope)
- Deep links: Not required (MVP)

---

# 4. Technical Architecture (React Native)

## 4.1 Architecture Overview

**Approach:** Offline-first, no backend, bundled content

```
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚                    React Native App                      â”‚
â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”     â”‚
â”‚  â”‚   Screens   â”‚  â”‚ Components  â”‚  â”‚   Hooks     â”‚     â”‚
â”‚  â”‚  (3 total)  â”‚  â”‚  (atoms,    â”‚  â”‚ (business   â”‚     â”‚
â”‚  â”‚             â”‚  â”‚  molecules) â”‚  â”‚  logic)     â”‚     â”‚
â”‚  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜     â”‚
â”‚         â”‚                â”‚                â”‚             â”‚
â”‚         â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¼â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜             â”‚
â”‚                          â”‚                              â”‚
â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”´â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”     â”‚
â”‚  â”‚              State (Zustand)                   â”‚     â”‚
â”‚  â”‚  - currentTerm, language, theme, favorites     â”‚     â”‚
â”‚  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜     â”‚
â”‚                          â”‚                              â”‚
â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”´â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”     â”‚
â”‚  â”‚              Data Layer                        â”‚     â”‚
â”‚  â”‚  - Bundled JSON (slang_terms.json)            â”‚     â”‚
â”‚  â”‚  - AsyncStorage (preferences, favorites)       â”‚     â”‚
â”‚  â”‚  - Fuse.js (fuzzy search)                     â”‚     â”‚
â”‚  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜     â”‚
â”‚                          â”‚                              â”‚
â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”´â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”     â”‚
â”‚  â”‚              Native Modules                    â”‚     â”‚
â”‚  â”‚  - Speech Recognition (iOS SFSpeechRecognizer)â”‚     â”‚
â”‚  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜     â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
```

## 4.2 Folder Structure

```
vwa-mobile/
â”œâ”€â”€ app/                          # Expo Router (or screens/ for RN CLI)
â”‚   â”œâ”€â”€ _layout.tsx               # Root layout
â”‚   â”œâ”€â”€ index.tsx                 # Main screen
â”‚   â”œâ”€â”€ browse.tsx                # Browse screen
â”‚   â””â”€â”€ settings.tsx              # Settings screen (P1)
â”œâ”€â”€ components/
â”‚   â”œâ”€â”€ atoms/
â”‚   â”‚   â”œâ”€â”€ Button.tsx
â”‚   â”‚   â”œâ”€â”€ Tag.tsx
â”‚   â”‚   â”œâ”€â”€ Icon.tsx
â”‚   â”‚   â””â”€â”€ Text.tsx
â”‚   â”œâ”€â”€ molecules/
â”‚   â”‚   â”œâ”€â”€ SearchInput.tsx
â”‚   â”‚   â”œâ”€â”€ LanguageToggle.tsx
â”‚   â”‚   â”œâ”€â”€ Waveform.tsx
â”‚   â”‚   â””â”€â”€ ProgressBar.tsx
â”‚   â””â”€â”€ organisms/
â”‚       â”œâ”€â”€ TermCard.tsx
â”‚       â”œâ”€â”€ TermListItem.tsx
â”‚       â””â”€â”€ VoiceButton.tsx
â”œâ”€â”€ hooks/
â”‚   â”œâ”€â”€ useVoiceRecognition.ts    # Speech-to-text logic
â”‚   â”œâ”€â”€ useTermSearch.ts          # Fuzzy search logic
â”‚   â””â”€â”€ useTheme.ts               # Theme management
â”œâ”€â”€ store/
â”‚   â””â”€â”€ useAppStore.ts            # Zustand store
â”œâ”€â”€ data/
â”‚   â””â”€â”€ terms.json                # Bundled slang data (preprocessed)
â”œâ”€â”€ theme/
â”‚   â”œâ”€â”€ colors.ts
â”‚   â”œâ”€â”€ typography.ts
â”‚   â”œâ”€â”€ spacing.ts
â”‚   â””â”€â”€ index.ts
â”œâ”€â”€ utils/
â”‚   â”œâ”€â”€ normalize.ts              # Text normalization for matching
â”‚   â””â”€â”€ constants.ts
â”œâ”€â”€ types/
â”‚   â””â”€â”€ index.ts                  # TypeScript interfaces
â””â”€â”€ assets/
    â””â”€â”€ images/
```

## 4.3 State Management Strategy

**Library:** Zustand (simple, minimal boilerplate, works well with React Native)

**Store Structure:**

```typescript
// store/useAppStore.ts
interface AppState {
  // Current view state
  currentTermIndex: number
  language: 'ES' | 'FR'
  theme: 'dark' | 'light' | 'system'

  // Voice state
  isListening: boolean
  transcript: string | null
  voiceError: string | null

  // Data
  terms: SlangTerm[]
  favorites: number[] // Array of defid values

  // Actions
  setCurrentTerm: (index: number) => void
  nextTerm: () => void
  prevTerm: () => void
  setLanguage: (lang: 'ES' | 'FR') => void
  setTheme: (theme: 'dark' | 'light' | 'system') => void
  toggleFavorite: (defid: number) => void
  setListening: (listening: boolean) => void
  setTranscript: (text: string | null) => void
  setVoiceError: (error: string | null) => void
}
```

**Persistence:**

- `language`, `theme`, `favorites` persisted via AsyncStorage
- Use Zustand's `persist` middleware

## 4.4 Data Layer

### Content Data

**Source:** Preprocessed JSON bundled with app

**Preprocessing Pipeline (Build-time):**

```
Raw Urban Dictionary JSON
         â”‚
         â–¼
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚  1. Content Filtering   â”‚  Remove explicit/low-quality entries
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
         â”‚
         â–¼
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚  2. Translation Gen     â”‚  Generate ES/FR translations via GPT API
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
         â”‚
         â–¼
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚  3. Categorization      â”‚  Auto-assign categories via GPT
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
         â”‚
         â–¼
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚  4. Final JSON          â”‚  Bundled with app
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
```

**Final Data Schema:**

```typescript
interface SlangTerm {
  id: number // defid from Urban Dictionary
  term: string // The slang word/phrase
  category: Category // TRUTH, PRAISE, QUALITY, etc.
  definition: string // English definition (cleaned)
  example: string | null // Example usage
  translations: {
    ES: {
      definition: string // Spanish explanation
      example: string | null // Spanish example translation
    }
    FR: {
      definition: string // French explanation
      example: string | null // French example translation
    }
  }
  meta: {
    thumbsUp: number
    thumbsDown: number
    author: string
    addedOn: string // ISO date
  }
}

type Category =
  | 'AGREEMENT' // bet, facts, say less
  | 'CRITICISM' // mid, sus, cringe
  | 'DEGREE' // lowkey, highkey, deadass
  | 'EMOTION' // salty, pressed, tilted
  | 'PRAISE' // slay, goated, fire
  | 'QUALITY' // bussin, slaps, hits different
  | 'TRUTH' // no cap, fr fr, on god
  | 'OTHER' // Catch-all
```

### Search Implementation

**Library:** Fuse.js (fuzzy search)

```typescript
// hooks/useTermSearch.ts
import Fuse from 'fuse.js'
import terms from '../data/terms.json'

const fuse = new Fuse(terms, {
  keys: ['term'],
  threshold: 0.3, // Allow some fuzziness
  ignoreLocation: true,
  includeScore: true,
})

export function searchTerm(query: string): SlangTerm | null {
  const normalized = normalizeText(query)
  const results = fuse.search(normalized)

  if (results.length > 0 && results[0].score < 0.3) {
    return results[0].item
  }
  return null
}

function normalizeText(text: string): string {
  return text
    .toLowerCase()
    .trim()
    .replace(/['']/g, "'") // Normalize apostrophes
    .replace(/\s+/g, ' ') // Normalize whitespace
}
```

### Local Storage

**Library:** AsyncStorage (via @react-native-async-storage/async-storage)

**Stored Keys:**
| Key | Type | Description |
|-----|------|-------------|
| `@vwa/language` | `'ES' \| 'FR'` | Preferred translation language |
| `@vwa/theme` | `'dark' \| 'light' \| 'system'` | Theme preference |
| `@vwa/favorites` | `number[]` | Array of favorited term IDs |
| `@vwa/lastTermIndex` | `number` | Resume position |

## 4.5 Speech Recognition

### Approach

**Library:** `@react-native-voice/voice` (most mature, iOS native integration)

**Alternative:** `expo-speech-recognition` (if using Expo)

**Why iOS Native (SFSpeechRecognizer):**

- Free (no API costs)
- Works offline (on-device recognition)
- Good accuracy for short phrases
- Low latency

### Implementation

```typescript
// hooks/useVoiceRecognition.ts
import Voice, {
  SpeechResultsEvent,
  SpeechErrorEvent,
} from '@react-native-voice/voice'
import { useEffect, useCallback } from 'react'
import { useAppStore } from '../store/useAppStore'

export function useVoiceRecognition() {
  const { setListening, setTranscript, setVoiceError } = useAppStore()

  useEffect(() => {
    Voice.onSpeechStart = () => setListening(true)
    Voice.onSpeechEnd = () => setListening(false)

    Voice.onSpeechResults = (e: SpeechResultsEvent) => {
      const transcript = e.value?.[0] || null
      setTranscript(transcript)
      setListening(false)
    }

    Voice.onSpeechError = (e: SpeechErrorEvent) => {
      setVoiceError(e.error?.message || 'Recognition failed')
      setListening(false)
    }

    return () => {
      Voice.destroy().then(Voice.removeAllListeners)
    }
  }, [])

  const startListening = useCallback(async () => {
    try {
      setVoiceError(null)
      setTranscript(null)
      await Voice.start('en-US')
    } catch (e) {
      setVoiceError('Could not start voice recognition')
    }
  }, [])

  const stopListening = useCallback(async () => {
    try {
      await Voice.stop()
    } catch (e) {
      // Ignore stop errors
    }
  }, [])

  return { startListening, stopListening }
}
```

### Voice â†’ Search Flow

```typescript
// In Main screen component
const { startListening } = useVoiceRecognition()
const { transcript, isListening } = useAppStore()

// When transcript changes, search for term
useEffect(() => {
  if (transcript) {
    const match = searchTerm(transcript)
    if (match) {
      setCurrentTermByDefid(match.id)
    } else {
      showNoMatchState()
    }
  }
}, [transcript])
```

## 4.6 Auth & Identity

**Not applicable for MVP.** No user accounts.

## 4.7 Data Models

### TypeScript Interfaces

```typescript
// types/index.ts

export interface SlangTerm {
  id: number
  term: string
  category: Category
  definition: string
  example: string | null
  translations: Translations
  meta: TermMeta
}

export interface Translations {
  ES: Translation
  FR: Translation
}

export interface Translation {
  definition: string
  example: string | null
}

export interface TermMeta {
  thumbsUp: number
  thumbsDown: number
  author: string
  addedOn: string
}

export type Category =
  | 'AGREEMENT'
  | 'CRITICISM'
  | 'DEGREE'
  | 'EMOTION'
  | 'PRAISE'
  | 'QUALITY'
  | 'TRUTH'
  | 'OTHER'

export type Language = 'ES' | 'FR'

export type Theme = 'dark' | 'light' | 'system'
```

### Example Term Object

```json
{
  "id": 12345678,
  "term": "No cap",
  "category": "TRUTH",
  "definition": "Used to indicate that one is being honest or serious; not lying or exaggerating.",
  "example": "No cap, that concert was the best I've ever been to.",
  "translations": {
    "ES": {
      "definition": "Se usa para indicar que se estÃ¡ siendo honesto o serio; sin mentir ni exagerar. Equivalente a 'en serio' o 'sin mentir'.",
      "example": "Sin mentir, ese concierto fue el mejor al que he ido."
    },
    "FR": {
      "definition": "UtilisÃ© pour indiquer qu'on est honnÃªte ou sÃ©rieux; sans mentir ni exagÃ©rer. Ã‰quivalent Ã  'sans mentir' ou 'pour de vrai'.",
      "example": "Sans mentir, ce concert Ã©tait le meilleur auquel je suis allÃ©."
    }
  },
  "meta": {
    "thumbsUp": 15420,
    "thumbsDown": 892,
    "author": "slangmaster99",
    "addedOn": "2021-03-15T00:00:00Z"
  }
}
```

## 4.8 Security & Privacy

### Permissions

| Permission | When Requested       | Fallback                             |
| ---------- | -------------------- | ------------------------------------ |
| Microphone | First mic button tap | Explain why needed, link to Settings |

### Data Privacy

- No user data collected
- No network requests (fully offline)
- No analytics (MVP)
- Favorites stored locally only (never transmitted)

### App Transport Security

Not applicable â€” no network requests.

## 4.9 Performance Plan

### Targets

| Metric         | Target  | How to Achieve                                |
| -------------- | ------- | --------------------------------------------- |
| Cold start     | < 2s    | Minimize initial JS bundle, lazy load screens |
| Voice latency  | < 3s    | Use on-device speech recognition              |
| Search latency | < 100ms | Pre-indexed Fuse.js, memoized results         |
| List scroll    | 60fps   | Virtualized FlatList, memoized items          |
| Memory         | < 150MB | Optimize images, avoid memory leaks           |

### Optimization Strategies

1. **Bundle size:**

   - Terms JSON ~500KB (gzipped)
   - Tree-shake unused dependencies
   - Use Hermes engine

2. **List performance:**

   - `FlatList` with `getItemLayout` for fixed-height items
   - `React.memo` on list items
   - `keyExtractor` using `defid`

3. **Speech recognition:**
   - Native module (no JS bridge overhead for audio)
   - 5-second timeout to prevent hanging

---

# 5. Integrations & Services

## 5.1 Build-Time Services (Not Runtime)

### Translation Generation

**Service:** Groq API (Free Tier) â€” Llama 3.3 70B (`llama-3.3-70b-versatile`)

**Why Groq:**

- Completely free (no credit card required)
- 14,400 requests/day, 30 requests/minute
- High quality Llama 3 model
- Fast inference

**When:** During data preprocessing (one-time, before app development)

**Process:**

```bash
# Set API key (get free at https://console.groq.com)
export GROQ_API_KEY="gsk_your_key_here"

# Run preprocessing script
python translate_terms.py \
    --input data/slang_terms.json \
    --output data/processed_terms.json
```

**What the script does:**

1. Filters explicit/low-quality content
2. Calls Groq API to generate contextual ES/FR translations
3. Auto-categorizes each term
4. Saves progress with checkpointing (resume if interrupted)

**Estimated time:** ~2-3 hours for 1000 terms (rate limited to stay in free tier)

### Content Categorization

**Service:** Groq API (same as translations)

**Categories assigned automatically:**

- AGREEMENT (bet, facts)
- CRITICISM (mid, sus)
- DEGREE (lowkey, deadass)
- EMOTION (salty, pressed)
- PRAISE (slay, goated)
- QUALITY (bussin, fire)
- TRUTH (no cap, fr)
- OTHER (catch-all)

## 5.2 Runtime Services

**None required.** App is fully offline.

## 5.3 Future Analytics (P2)

If analytics added later, recommend:

- **PostHog** (privacy-focused, can self-host)
- Or **Expo Analytics** (if using Expo)

Event naming convention:

```
{screen}_{action}_{detail}

Examples:
- main_voice_started
- main_voice_success
- main_voice_no_match
- main_term_viewed
- main_language_changed
- browse_search_performed
- browse_term_selected
- settings_theme_changed
- settings_favorite_added
```

---

# 6. Testing & Quality

## 6.1 Testing Strategy

| Layer       | Tool                         | Coverage Target           |
| ----------- | ---------------------------- | ------------------------- |
| Unit        | Jest                         | 80% for utils, hooks      |
| Component   | React Native Testing Library | Key components            |
| Integration | Detox                        | Critical user flows       |
| Manual      | QA checklist                 | Edge cases, accessibility |

## 6.2 What to Automate First

**Priority 1: Unit tests**

- `normalizeText()` utility
- `searchTerm()` function
- Zustand store actions

**Priority 2: Component tests**

- TermCard renders correctly
- LanguageToggle switches state
- SearchInput filters correctly

**Priority 3: E2E tests**

- Happy path: tap mic â†’ speak â†’ see result (may need mocking)
- Browse â†’ search â†’ select term â†’ return

## 6.3 Test Examples

```typescript
// __tests__/utils/normalize.test.ts
import { normalizeText } from '../utils/normalize';

describe('normalizeText', () => {
  it('lowercases input', () => {
    expect(normalizeText('No Cap')).toBe('no cap');
  });

  it('normalizes apostrophes', () => {
    expect(normalizeText("bussin'")).toBe("bussin'");
    expect(normalizeText('bussin'')).toBe("bussin'");
  });

  it('trims whitespace', () => {
    expect(normalizeText('  no cap  ')).toBe('no cap');
  });
});
```

## 6.4 Release Checklist

### Pre-Release

- [ ] All P0 features implemented
- [ ] Unit tests passing
- [ ] Manual QA on physical device
- [ ] VoiceOver accessibility check
- [ ] Performance profiling (cold start < 2s)
- [ ] Memory profiling (no leaks)
- [ ] Content review (no inappropriate terms)

### App Store Submission

- [ ] App icons (all sizes)
- [ ] Screenshots (6.7", 6.5", 5.5")
- [ ] App description
- [ ] Privacy policy URL
- [ ] Microphone usage description
- [ ] Age rating: 12+ (slang content)

---

# 7. DevOps & Release

## 7.1 Environments

| Environment | Purpose             | Build Type |
| ----------- | ------------------- | ---------- |
| Development | Local dev           | Debug      |
| Preview     | TestFlight internal | Release    |
| Production  | App Store           | Release    |

## 7.2 CI/CD Outline

**Recommended:** GitHub Actions + EAS Build (if Expo) or Fastlane (if bare RN)

```yaml
# .github/workflows/ci.yml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
      - run: npm ci
      - run: npm run lint
      - run: npm run typecheck
      - run: npm test

  build-ios:
    needs: test
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
      - run: npm ci
      - run: cd ios && pod install
      - run: npm run build:ios
```

## 7.3 App Store Considerations

### Required

- [ ] Apple Developer Account ($99/year)
- [ ] App ID + Bundle Identifier
- [ ] Provisioning profiles
- [ ] Privacy Policy (simple, hosted on GitHub Pages)

### Review Guidelines Compliance

- **Microphone usage:** Clear explanation in `Info.plist` (`NSMicrophoneUsageDescription`)
- **Content:** Age-appropriate (12+ due to slang definitions)
- **Functionality:** App must work without network

### Metadata

```
App Name: VWA - Slang Translator
Subtitle: Gen Z slang in Spanish & French
Category: Education / Reference
```

---

# 8. Risks, Open Questions, and Next Steps

## 8.1 Top Risks & Mitigations

| Risk                            | Likelihood | Impact | Mitigation                                                       |
| ------------------------------- | ---------- | ------ | ---------------------------------------------------------------- |
| **Speech recognition accuracy** | Medium     | High   | Fuzzy matching with Fuse.js; manual fallback via Browse          |
| **Translation quality**         | Medium     | Medium | Review sample translations; add "Report" feature                 |
| **Content appropriateness**     | Medium     | High   | Manual review pass; filter explicit content during preprocessing |
| **App Store rejection**         | Low        | High   | Follow guidelines; provide clear microphone justification        |
| **Data staleness**              | Low        | Low    | Portfolio project; freshness not critical                        |

## 8.2 Open Questions

| Question                              | Owner   | Decision Needed By         |
| ------------------------------------- | ------- | -------------------------- |
| Which RN template? (Expo vs bare)     | Dev     | Before coding starts       |
| Content filtering criteria refinement | Product | Before preprocessing       |
| Category taxonomy final list          | Design  | Before preprocessing       |
| TestFlight tester list                | Product | Before first preview build |

**Decided:**

- âœ… Translation API: Groq (free tier, Llama 3.3 70B via `llama-3.3-70b-versatile`)

## 8.3 Data Preprocessing Requirements

**Critical Path Item:** The current raw data lacks translations and categories. Before app development can use real content:

1. **Filter content** â€” Remove explicit/inappropriate entries
2. **Generate translations** â€” Run Groq API (Llama 3.3 70B) over all terms
3. **Assign categories** â€” Auto-classify via Groq
4. **Validate output** â€” Spot-check 50+ entries for quality

**Preprocessing Script:** `translate_terms.py` â€” Ready to use

- Location: `/Users/jphilistin/Documents/Coding/Vwa/translate_terms.py`
- Model: `llama-3.3-70b-versatile` (Groq free tier)
- Features: Content filtering, ES/FR translations, auto-categorization, checkpoint/resume

**Usage:**

```bash
export GROQ_API_KEY="your-key-here"
python translate_terms.py \
    -i data/slang_terms.json \
    -o data/processed_terms.json \
    --limit 10  # test first, then remove limit for full run
```

**Estimated effort:** ~2-3 hours runtime for 1000 terms (rate limited)

## 8.4 Suggested Sprint Plan

### Sprint 0: Setup (3-5 days)

- [ ] Initialize React Native project
- [ ] Set up folder structure per architecture
- [ ] Configure TypeScript, ESLint, Prettier
- [ ] Create theme system (colors, typography, spacing)
- [ ] Data preprocessing script (filter + translate + categorize)
- [ ] Generate final `terms.json`

### Sprint 1: Core Features (1 week)

- [ ] Implement Main screen layout
- [ ] Build TermCard component
- [ ] Build LanguageToggle component
- [ ] Implement Zustand store
- [ ] Manual navigation between terms (prev/next)
- [ ] Dark/Light theme toggle

### Sprint 2: Voice + Browse (1 week)

- [ ] Integrate speech recognition
- [ ] Implement Fuse.js search
- [ ] Voice â†’ search â†’ display flow
- [ ] Build Browse screen
- [ ] Search input with filtering
- [ ] Term selection â†’ return to Main

### Sprint 3: Polish + Release (1 week)

- [ ] Settings screen with favorites
- [ ] Error states and edge cases
- [ ] Accessibility audit
- [ ] Performance optimization
- [ ] TestFlight build
- [ ] App Store submission

---

# Completeness Check

## Well-Defined

- Core user flows (voice lookup, browse)
- Data model and schema
- Technical stack choices
- Screen specs and navigation
- State management approach

## Ambiguous / Needs Decision

- **Expo vs bare React Native** â€” Recommend Expo for faster dev, but either works
- **Content filtering rules** â€” Need explicit criteria for what's "inappropriate" (script has defaults)
- **Category taxonomy** â€” Current list is draft; may need refinement after seeing real data

## Biggest Execution Risk

**Data preprocessing quality.** The app is only as good as its content. If translations are awkward or categories are wrong, the UX suffers. Recommend:

1. Generate translations for 50 terms first
2. Have native speakers review
3. Iterate on prompts before full batch

---

_Document generated: January 2026_
_Status: Ready for implementation_
