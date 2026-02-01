# VWA Implementation Plan

## For Claude Code Execution

---

# PHASE 0: Data Preparation (BLOCKING - Do First)

## Current State

- 1000 raw terms collected
- Only 70/1000 translated (7%)
- Many terms are NOT Gen Z slang (content quality issue)

## Tasks

### Task 0.1: Curate High-Quality Terms

**Priority**: CRITICAL
**Why**: Random Urban Dictionary entries â‰ Gen Z slang. Your value prop breaks without this.

```bash
cd /Users/jphilistin/Documents/Coding/Vwa

# Create a manual curation list of ACTUAL Gen Z slang
cat > data/curated_terms.txt << 'EOF'
no cap
lowkey
highkey
bet
slay
bussin
mid
sus
fire
goated
fr fr
on god
deadass
salty
pressed
cap
finna
periodt
slaps
hits different
main character
ate
understood the assignment
rent free
its giving
say less
valid
vibes
caught in 4k
stan
simp
pick me
based
cringe
W
L
ratio
ong
ngl
iykyk
EOF
```

**Action**: Instead of processing all 1000 random terms, search your `slang_terms.json` for these curated terms first. If a term isn't in your data, add it manually via Urban Dictionary search.

### Task 0.2: Filter Raw Data to Curated List

```python
# Add to translate_terms.py or create new script
CURATED_TERMS = [
    "no cap", "lowkey", "highkey", "bet", "slay", "bussin", "mid", "sus",
    "fire", "goated", "fr fr", "on god", "deadass", "salty", "pressed",
    # ... rest of list
]

def filter_to_curated(raw_terms: list) -> list:
    """Keep only terms matching our curated list."""
    curated_lower = {t.lower() for t in CURATED_TERMS}
    return [t for t in raw_terms if t.get("word", "").lower() in curated_lower]
```

### Task 0.3: Complete Translations

```bash
# Clear old checkpoint (we're starting fresh with curated data)
rm data/processed_terms.checkpoint.json
rm data/processed_terms.json

# Set API key
export GROQ_API_KEY="your-key-here"

# Run with curated filter
python translate_terms.py \
    --input data/slang_terms.json \
    --output data/processed_terms.json
```

**Time estimate**: 1-2 hours for ~50-100 curated terms

### Task 0.4: Validate Output

Manually review 10-15 translations for quality:

- Is the Spanish/French explanation accurate?
- Does it explain the MEANING, not literal translation?
- Is the example natural?

---

# PHASE 1: Project Setup (1 day)

## Task 1.1: Initialize Expo Project

```bash
# Create new project
npx create-expo-app vwa-mobile --template expo-template-blank-typescript

cd vwa-mobile

# Install core dependencies
npx expo install expo-speech expo-av @react-native-async-storage/async-storage

# Install navigation
npm install @react-navigation/native @react-navigation/native-stack
npx expo install react-native-screens react-native-safe-area-context

# Install search
npm install fuse.js

# Install state management
npm install zustand

# Install dev tools
npm install -D @types/react @types/react-native
```

## Task 1.2: Create Folder Structure

```
vwa-mobile/
â”œâ”€â”€ app/                          # Screens (using Expo Router)
â”‚   â”œâ”€â”€ _layout.tsx               # Root layout
â”‚   â”œâ”€â”€ index.tsx                 # Main screen
â”‚   â””â”€â”€ browse.tsx                # Browse screen
â”œâ”€â”€ components/
â”‚   â”œâ”€â”€ TermCard.tsx              # Main term display
â”‚   â”œâ”€â”€ LanguageToggle.tsx        # ES/FR switch
â”‚   â”œâ”€â”€ Waveform.tsx              # Audio visualization
â”‚   â”œâ”€â”€ BrutalButton.tsx          # Neo-brutalist button
â”‚   â””â”€â”€ SearchInput.tsx           # Search field
â”œâ”€â”€ hooks/
â”‚   â”œâ”€â”€ useTheme.ts               # Theme management
â”‚   â””â”€â”€ useTermSearch.ts          # Fuse.js search
â”œâ”€â”€ store/
â”‚   â””â”€â”€ useAppStore.ts            # Zustand store
â”œâ”€â”€ theme/
â”‚   â”œâ”€â”€ colors.ts                 # Color tokens
â”‚   â”œâ”€â”€ typography.ts             # Font styles
â”‚   â””â”€â”€ index.ts                  # Theme export
â”œâ”€â”€ data/
â”‚   â””â”€â”€ terms.json                # Bundled slang data (copy from preprocessing)
â””â”€â”€ types/
    â””â”€â”€ index.ts                  # TypeScript interfaces
```

## Task 1.3: Copy Design Tokens

Create `theme/colors.ts`:

```typescript
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
```

## Task 1.4: Define Types

Create `types/index.ts`:

```typescript
export interface SlangTerm {
  id: number
  term: string
  category: Category
  definition: string
  example: string | null
  translations: {
    ES: Translation
    FR: Translation
  }
  meta: TermMeta
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
export type Theme = 'dark' | 'light'
```

---

# PHASE 2: Core Components (2-3 days)

## Task 2.1: Create Zustand Store

Create `store/useAppStore.ts`:

```typescript
import { create } from 'zustand'
import { persist, createJSONStorage } from 'zustand/middleware'
import AsyncStorage from '@react-native-async-storage/async-storage'
import { Language, Theme, SlangTerm } from '../types'
import terms from '../data/terms.json'

interface AppState {
  // Data
  terms: SlangTerm[]
  currentIndex: number

  // Preferences
  language: Language
  theme: Theme

  // Actions
  setCurrentIndex: (index: number) => void
  nextTerm: () => void
  prevTerm: () => void
  setLanguage: (lang: Language) => void
  setTheme: (theme: Theme) => void
  setTermBySearch: (searchResult: SlangTerm) => void
}

export const useAppStore = create<AppState>()(
  persist(
    (set, get) => ({
      terms: terms as SlangTerm[],
      currentIndex: 0,
      language: 'ES',
      theme: 'dark',

      setCurrentIndex: (index) => set({ currentIndex: index }),

      nextTerm: () =>
        set((state) => ({
          currentIndex: (state.currentIndex + 1) % state.terms.length,
        })),

      prevTerm: () =>
        set((state) => ({
          currentIndex:
            (state.currentIndex - 1 + state.terms.length) % state.terms.length,
        })),

      setLanguage: (language) => set({ language }),

      setTheme: (theme) => set({ theme }),

      setTermBySearch: (term) => {
        const index = get().terms.findIndex((t) => t.id === term.id)
        if (index !== -1) {
          set({ currentIndex: index })
        }
      },
    }),
    {
      name: 'vwa-storage',
      storage: createJSONStorage(() => AsyncStorage),
      partialize: (state) => ({
        language: state.language,
        theme: state.theme,
        currentIndex: state.currentIndex,
      }),
    }
  )
)
```

## Task 2.2: Create Theme Hook

Create `hooks/useTheme.ts`:

```typescript
import { useAppStore } from '../store/useAppStore'
import { colors } from '../theme/colors'

export function useTheme() {
  const theme = useAppStore((state) => state.theme)
  return colors[theme]
}
```

## Task 2.3: Create BrutalButton Component

Create `components/BrutalButton.tsx`:

```typescript
import React, { useState } from 'react'
import { Pressable, StyleSheet, ViewStyle } from 'react-native'
import { useTheme } from '../hooks/useTheme'

interface Props {
  onPress: () => void
  children: React.ReactNode
  style?: ViewStyle
  small?: boolean
}

export function BrutalButton({ onPress, children, style, small }: Props) {
  const [pressed, setPressed] = useState(false)
  const theme = useTheme()

  const shadowOffset = small ? 2 : 4
  const pressedOffset = 1

  return (
    <Pressable
      onPress={onPress}
      onPressIn={() => setPressed(true)}
      onPressOut={() => setPressed(false)}
      style={[
        styles.button,
        {
          transform: [
            { translateX: pressed ? pressedOffset : 0 },
            { translateY: pressed ? pressedOffset : 0 },
          ],
          shadowColor: theme.shadow,
          shadowOffset: {
            width: pressed ? pressedOffset : shadowOffset,
            height: pressed ? pressedOffset : shadowOffset,
          },
          shadowOpacity: 1,
          shadowRadius: 0,
        },
        style,
      ]}
    >
      {children}
    </Pressable>
  )
}

const styles = StyleSheet.create({
  button: {
    alignItems: 'center',
    justifyContent: 'center',
  },
})
```

## Task 2.4: Create TermCard Component

Create `components/TermCard.tsx`:

```typescript
import React from 'react'
import { View, Text, StyleSheet, ScrollView } from 'react-native'
import { useTheme } from '../hooks/useTheme'
import { useAppStore } from '../store/useAppStore'

export function TermCard() {
  const theme = useTheme()
  const { terms, currentIndex, language } = useAppStore()
  const term = terms[currentIndex]

  if (!term) return null

  const translation = term.translations[language]

  return (
    <View
      style={[
        styles.card,
        {
          backgroundColor: theme.surface,
          borderColor: theme.borderStrong,
          shadowColor: theme.shadow,
        },
      ]}
    >
      {/* Category Tag */}
      <View
        style={[
          styles.tag,
          {
            backgroundColor: theme.accent,
            borderColor: theme.borderStrong,
          },
        ]}
      >
        <Text style={styles.tagText}>{term.category}</Text>
      </View>

      {/* Term */}
      <Text style={[styles.term, { color: theme.text }]}>
        {term.term.toUpperCase()}
      </Text>

      <Text style={[styles.definition, { color: theme.textMuted }]}>
        {term.definition}
      </Text>

      {/* Divider */}
      <View style={[styles.divider, { backgroundColor: theme.borderStrong }]} />

      {/* Translation */}
      <Text style={[styles.langLabel, { color: theme.primary }]}>
        {language === 'ES' ? 'ESPAÃ‘OL' : 'FRANÃ‡AIS'}
      </Text>

      <Text style={[styles.translationText, { color: theme.text }]}>
        {translation.definition}
      </Text>

      {/* Example */}
      {term.example && (
        <View
          style={[
            styles.exampleBox,
            {
              backgroundColor: theme.surfaceRaised,
              borderColor: theme.border,
            },
          ]}
        >
          <Text style={[styles.exampleLabel, { color: theme.textMuted }]}>
            EXAMPLE
          </Text>
          <Text style={[styles.exampleText, { color: theme.textSecondary }]}>
            "{term.example}"
          </Text>
          {translation.example && (
            <>
              <View
                style={[styles.exampleDivider, { borderColor: theme.border }]}
              />
              <View style={styles.translatedExample}>
                <Text style={[styles.arrow, { color: theme.primary }]}>
                  â†’
                </Text>
                <Text style={[styles.exampleText, { color: theme.text }]}>
                  {translation.example}
                </Text>
              </View>
            </>
          )}
        </View>
      )}

      {/* Progress */}
      <View style={styles.progress}>
        {terms.map((_, idx) => (
          <View
            key={idx}
            style={[
              styles.progressBar,
              {
                flex: idx === currentIndex ? 3 : 1,
                backgroundColor:
                  idx === currentIndex ? theme.primary : theme.border,
              },
            ]}
          />
        ))}
      </View>

      <Text style={[styles.counter, { color: theme.textMuted }]}>
        {String(currentIndex + 1).padStart(2, '0')}/
        {String(terms.length).padStart(2, '0')}
      </Text>
    </View>
  )
}

const styles = StyleSheet.create({
  card: {
    flex: 1,
    borderWidth: 3,
    shadowOffset: { width: 4, height: 4 },
    shadowOpacity: 1,
    shadowRadius: 0,
    padding: 16,
  },
  tag: {
    alignSelf: 'flex-start',
    paddingHorizontal: 12,
    paddingVertical: 4,
    borderWidth: 2,
    marginBottom: 12,
  },
  tagText: {
    fontSize: 10,
    fontWeight: '800',
    color: '#0D0D0D',
    letterSpacing: 1,
  },
  term: {
    fontSize: 42,
    fontWeight: '900',
    letterSpacing: -2,
    lineHeight: 42,
  },
  definition: {
    fontSize: 13,
    fontFamily: 'monospace',
    marginTop: 8,
  },
  divider: {
    height: 3,
    marginVertical: 12,
  },
  langLabel: {
    fontSize: 10,
    fontWeight: '800',
    letterSpacing: 1,
    marginBottom: 8,
  },
  translationText: {
    fontSize: 16,
    lineHeight: 24,
  },
  exampleBox: {
    marginTop: 16,
    padding: 16,
    borderWidth: 2,
  },
  exampleLabel: {
    fontSize: 9,
    fontWeight: '800',
    letterSpacing: 1,
    fontFamily: 'monospace',
    marginBottom: 6,
  },
  exampleText: {
    fontSize: 14,
    fontStyle: 'italic',
    flex: 1,
  },
  exampleDivider: {
    borderTopWidth: 1,
    marginVertical: 12,
  },
  translatedExample: {
    flexDirection: 'row',
    alignItems: 'flex-start',
    gap: 8,
  },
  arrow: {
    fontWeight: '900',
    fontSize: 14,
    fontFamily: 'monospace',
  },
  progress: {
    flexDirection: 'row',
    gap: 4,
    marginTop: 16,
  },
  progressBar: {
    height: 4,
  },
  counter: {
    fontSize: 11,
    fontFamily: 'monospace',
    marginTop: 8,
  },
})
```

## Task 2.5: Create LanguageToggle Component

Create `components/LanguageToggle.tsx`:

```typescript
import React from 'react'
import { View, Text, Pressable, StyleSheet } from 'react-native'
import { useTheme } from '../hooks/useTheme'
import { useAppStore } from '../store/useAppStore'

export function LanguageToggle() {
  const theme = useTheme()
  const { language, setLanguage } = useAppStore()

  return (
    <View
      style={[
        styles.container,
        {
          borderColor: theme.borderStrong,
          backgroundColor: theme.surface,
          shadowColor: theme.shadow,
        },
      ]}
    >
      {(['ES', 'FR'] as const).map((lang, index) => (
        <Pressable
          key={lang}
          onPress={() => setLanguage(lang)}
          style={[
            styles.button,
            {
              backgroundColor:
                language === lang ? theme.primary : 'transparent',
              borderRightWidth: index === 0 ? 2 : 0,
              borderRightColor: theme.borderStrong,
            },
          ]}
        >
          <Text
            style={[
              styles.text,
              { color: language === lang ? '#FFFFFF' : theme.textSecondary },
            ]}
          >
            {lang}
          </Text>
        </Pressable>
      ))}
    </View>
  )
}

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    borderWidth: 2,
    shadowOffset: { width: 2, height: 2 },
    shadowOpacity: 1,
    shadowRadius: 0,
  },
  button: {
    paddingHorizontal: 16,
    paddingVertical: 8,
  },
  text: {
    fontSize: 14,
    fontWeight: '700',
  },
})
```

---

# PHASE 3: Screens (2 days)

## Task 3.1: Create Main Screen

Create `app/index.tsx`:

```typescript
import React from 'react'
import { View, StyleSheet, SafeAreaView } from 'react-native'
import { useRouter } from 'expo-router'
import { useTheme } from '../hooks/useTheme'
import { useAppStore } from '../store/useAppStore'
import { TermCard } from '../components/TermCard'
import { LanguageToggle } from '../components/LanguageToggle'
import { BrutalButton } from '../components/BrutalButton'
import { Header } from '../components/Header'
import { PlaybackControls } from '../components/PlaybackControls'

export default function MainScreen() {
  const theme = useTheme()
  const router = useRouter()
  const { nextTerm, prevTerm } = useAppStore()

  return (
    <SafeAreaView style={[styles.container, { backgroundColor: theme.bg }]}>
      {/* Header */}
      <View style={styles.header}>
        <Header />
        <LanguageToggle />
      </View>

      {/* Term Card */}
      <View style={styles.cardContainer}>
        <TermCard />
      </View>

      {/* Controls */}
      <View style={styles.controls}>
        <View style={styles.buttonRow}>
          <BrutalButton
            small
            onPress={prevTerm}
            style={[
              styles.navButton,
              {
                backgroundColor: theme.surface,
                borderColor: theme.borderStrong,
              },
            ]}
          >
            {/* Previous icon */}
          </BrutalButton>

          {/* Play button - placeholder for voice */}
          <BrutalButton
            onPress={() => {
              /* TODO: Voice input */
            }}
            style={[
              styles.playButton,
              {
                backgroundColor: theme.primary,
                borderColor: theme.borderStrong,
              },
            ]}
          >
            {/* Mic icon */}
          </BrutalButton>

          <BrutalButton
            small
            onPress={nextTerm}
            style={[
              styles.navButton,
              {
                backgroundColor: theme.surface,
                borderColor: theme.borderStrong,
              },
            ]}
          >
            {/* Next icon */}
          </BrutalButton>
        </View>
      </View>

      {/* Browse CTA */}
      <View style={styles.browseContainer}>
        <BrutalButton
          onPress={() => router.push('/browse')}
          style={[
            styles.browseButton,
            {
              backgroundColor: theme.surface,
              borderColor: theme.borderStrong,
            },
          ]}
        >
          {/* Browse text */}
        </BrutalButton>
      </View>
    </SafeAreaView>
  )
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: 20,
    paddingVertical: 8,
  },
  cardContainer: {
    flex: 1,
    paddingHorizontal: 20,
    paddingBottom: 16,
  },
  controls: {
    paddingHorizontal: 20,
    paddingBottom: 12,
  },
  buttonRow: {
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center',
    gap: 16,
  },
  navButton: {
    width: 48,
    height: 48,
    borderWidth: 2,
  },
  playButton: {
    width: 72,
    height: 72,
    borderWidth: 3,
  },
  browseContainer: {
    paddingHorizontal: 20,
    paddingBottom: 24,
  },
  browseButton: {
    width: '100%',
    paddingVertical: 14,
    paddingHorizontal: 16,
    borderWidth: 2,
  },
})
```

## Task 3.2: Create Browse Screen

Create `app/browse.tsx`:

```typescript
import React, { useState, useMemo } from 'react'
import {
  View,
  Text,
  FlatList,
  Pressable,
  StyleSheet,
  SafeAreaView,
} from 'react-native'
import { useRouter } from 'expo-router'
import Fuse from 'fuse.js'
import { useTheme } from '../hooks/useTheme'
import { useAppStore } from '../store/useAppStore'
import { SearchInput } from '../components/SearchInput'
import { BrutalButton } from '../components/BrutalButton'
import { SlangTerm } from '../types'

export default function BrowseScreen() {
  const theme = useTheme()
  const router = useRouter()
  const { terms, setTermBySearch } = useAppStore()
  const [query, setQuery] = useState('')

  const fuse = useMemo(
    () =>
      new Fuse(terms, {
        keys: ['term'],
        threshold: 0.3,
      }),
    [terms]
  )

  const filteredTerms = useMemo(() => {
    if (!query.trim()) return terms
    return fuse.search(query).map((result) => result.item)
  }, [query, fuse, terms])

  const handleSelectTerm = (term: SlangTerm) => {
    setTermBySearch(term)
    router.back()
  }

  const renderItem = ({ item, index }: { item: SlangTerm; index: number }) => (
    <BrutalButton
      onPress={() => handleSelectTerm(item)}
      style={[
        styles.listItem,
        {
          backgroundColor: theme.surface,
          borderColor: theme.borderStrong,
        },
      ]}
    >
      <View
        style={[
          styles.indexBadge,
          {
            backgroundColor: theme.accent,
            borderColor: theme.borderStrong,
          },
        ]}
      >
        <Text style={styles.indexText}>
          {String(index + 1).padStart(2, '0')}
        </Text>
      </View>
      <View style={styles.itemContent}>
        <Text style={[styles.itemTerm, { color: theme.text }]}>
          {item.term.toUpperCase()}
        </Text>
        <Text
          style={[styles.itemDef, { color: theme.textMuted }]}
          numberOfLines={1}
        >
          {item.definition}
        </Text>
      </View>
    </BrutalButton>
  )

  return (
    <SafeAreaView style={[styles.container, { backgroundColor: theme.bg }]}>
      {/* Back Button */}
      <Pressable onPress={() => router.back()} style={styles.backButton}>
        <Text style={[styles.backText, { color: theme.primary }]}>â† BACK</Text>
      </Pressable>

      {/* Title */}
      <Text style={[styles.title, { color: theme.text }]}>BROWSE</Text>
      <Text style={[styles.subtitle, { color: theme.textMuted }]}>
        {terms.length} TERMS AVAILABLE
      </Text>

      {/* Search */}
      <View style={styles.searchContainer}>
        <SearchInput value={query} onChange={setQuery} />
      </View>

      {/* List */}
      <FlatList
        data={filteredTerms}
        renderItem={renderItem}
        keyExtractor={(item) => String(item.id)}
        contentContainerStyle={styles.listContent}
        showsVerticalScrollIndicator={false}
        ListEmptyComponent={
          <View style={[styles.empty, { backgroundColor: theme.surface }]}>
            <Text style={[styles.emptyTitle, { color: theme.textSecondary }]}>
              NO RESULTS FOR "{query}"
            </Text>
            <Text style={[styles.emptySubtitle, { color: theme.textMuted }]}>
              TRY A DIFFERENT TERM
            </Text>
          </View>
        }
      />
    </SafeAreaView>
  )
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  backButton: {
    paddingHorizontal: 20,
    paddingTop: 8,
    paddingBottom: 16,
  },
  backText: {
    fontSize: 16,
    fontWeight: '700',
  },
  title: {
    fontSize: 36,
    fontWeight: '900',
    letterSpacing: -2,
    paddingHorizontal: 20,
  },
  subtitle: {
    fontSize: 13,
    fontFamily: 'monospace',
    paddingHorizontal: 20,
    marginTop: 4,
  },
  searchContainer: {
    paddingHorizontal: 20,
    paddingVertical: 16,
  },
  listContent: {
    paddingHorizontal: 20,
    paddingBottom: 24,
    gap: 12,
  },
  listItem: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: 16,
    borderWidth: 2,
    gap: 12,
  },
  indexBadge: {
    width: 48,
    height: 48,
    borderWidth: 2,
    alignItems: 'center',
    justifyContent: 'center',
  },
  indexText: {
    fontSize: 18,
    fontWeight: '900',
    color: '#0D0D0D',
  },
  itemContent: {
    flex: 1,
  },
  itemTerm: {
    fontSize: 18,
    fontWeight: '800',
    letterSpacing: -0.5,
  },
  itemDef: {
    fontSize: 12,
    fontFamily: 'monospace',
    marginTop: 4,
  },
  empty: {
    padding: 24,
    alignItems: 'center',
    borderWidth: 2,
  },
  emptyTitle: {
    fontSize: 16,
    fontWeight: '700',
    textAlign: 'center',
  },
  emptySubtitle: {
    fontSize: 13,
    fontFamily: 'monospace',
    marginTop: 8,
  },
})
```

---

# PHASE 4: Voice Input (Optional - MVP can skip)

## Why You Might Skip This Initially

- Voice recognition for slang is unreliable
- Manual browse + search covers 80% of use cases
- You can add voice in v1.1

## If You Do Implement Voice

### Task 4.1: Install Voice Package

```bash
npx expo install expo-speech-recognition
```

### Task 4.2: Create Voice Hook

Create `hooks/useVoiceInput.ts`:

```typescript
import { useState, useCallback } from 'react'
import * as SpeechRecognition from 'expo-speech-recognition'
import { useTermSearch } from './useTermSearch'

export function useVoiceInput() {
  const [isListening, setIsListening] = useState(false)
  const [transcript, setTranscript] = useState<string | null>(null)
  const [error, setError] = useState<string | null>(null)
  const { search } = useTermSearch()

  const startListening = useCallback(async () => {
    try {
      const { granted } = await SpeechRecognition.requestPermissionsAsync()
      if (!granted) {
        setError('Microphone permission required')
        return
      }

      setIsListening(true)
      setError(null)
      setTranscript(null)

      // TODO: Implement actual speech recognition
      // This is a placeholder - actual implementation depends on expo-speech-recognition API
    } catch (e) {
      setError('Could not start voice recognition')
      setIsListening(false)
    }
  }, [])

  const stopListening = useCallback(() => {
    setIsListening(false)
    // TODO: Stop recognition
  }, [])

  return {
    isListening,
    transcript,
    error,
    startListening,
    stopListening,
  }
}
```

### Task 4.3: Add Fuzzy Matching for Transcription Errors

Create `utils/transcriptMatching.ts`:

```typescript
// Common transcription errors for slang
const TRANSCRIPTION_CORRECTIONS: Record<string, string[]> = {
  'no cap': ['no cat', 'no cab', 'no calf', 'knock up'],
  bussin: ['bussing', 'busting', 'buzzing', 'bus in'],
  lowkey: ['low key', 'low-key', 'locky'],
  highkey: ['high key', 'high-key', 'hike he'],
  deadass: ['dead ass', 'dead as', 'deadas'],
  bet: ['bat', 'but', 'bed'],
  slay: ['sleigh', 'slate', 'slave'],
  goated: ['go to', 'goaded', 'coated'],
  sus: ['sauce', 'suss', 'such'],
}

export function correctTranscript(transcript: string): string {
  const lower = transcript.toLowerCase().trim()

  for (const [correct, variants] of Object.entries(TRANSCRIPTION_CORRECTIONS)) {
    if (variants.includes(lower)) {
      return correct
    }
  }

  return lower
}
```

---

# PHASE 5: Polish & Ship (2-3 days)

## Task 5.1: Add Icons

Use `@expo/vector-icons` or inline SVGs for:

- Play/Pause (mic) icon
- Previous/Next icons
- Search icon
- Back arrow
- Chevron right

## Task 5.2: Add Dark Mode Toggle

Either in settings or header - simple `setTheme('dark' | 'light')` call.

## Task 5.3: Test on Physical Device

```bash
npx expo start --dev-client
# Scan QR with Expo Go app
```

## Task 5.4: Build for TestFlight

```bash
# Install EAS CLI
npm install -g eas-cli

# Configure
eas build:configure

# Build iOS
eas build --platform ios --profile preview
```

## Task 5.5: App Store Assets

- [ ] App icon (1024x1024)
- [ ] Screenshots (6.7", 5.5")
- [ ] Privacy policy (simple markdown hosted on GitHub Pages)
- [ ] App description

---

# What To Skip (YAGNI)

Per your development principles, these are explicitly OUT for MVP:

1. **Unit tests** - Add after MVP ships, not before
2. **Component library** - Just build the components you need
3. **Atomic design structure** - Flat components folder is fine
4. **Settings screen** - Theme toggle in header, no separate screen needed
5. **Favorites** - Post-MVP feature
6. **Onboarding** - App is simple enough without it
7. **Analytics** - Add when you have users
8. **Help screen** - App is self-explanatory
9. **Haitian Creole** - Future language addition

---

# Success Criteria

MVP is done when:

- [ ] 50+ curated terms with quality ES/FR translations
- [ ] Main screen displays terms with translations
- [ ] Can navigate prev/next between terms
- [ ] Can toggle ES/FR language
- [ ] Browse screen with search works
- [ ] Dark/Light mode works
- [ ] Runs on physical iOS device
- [ ] Submitted to TestFlight

---

# Time Estimate

| Phase               | Days          | Blocker? |
| ------------------- | ------------- | -------- |
| Phase 0: Data prep  | 1             | YES      |
| Phase 1: Setup      | 1             |          |
| Phase 2: Components | 2-3           |          |
| Phase 3: Screens    | 2             |          |
| Phase 4: Voice      | 2+            | Optional |
| Phase 5: Polish     | 2-3           |          |
| **Total**           | **8-12 days** |          |

Voice input adds 2-4 days and significant complexity. Consider shipping without it first.
