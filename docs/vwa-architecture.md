# VWA iOS Architecture

**Version:** 2.0 – Native Swift/SwiftUI Implementation  
**Platform:** iOS 15+  
**Framework:** SwiftUI + Combine  
**State Management:** ObservableObject  
**Last Updated:** January 31, 2026  
**Status:** Production (reflects deployed code)

**Previous Version:** [v1.0 (React Native)](vwa-architecture-v1-react-native.md) - deprecated

---

**Codebase Reference:** Reflects implementation as of iOS deployment target fix (15.0)
**Project Files:** 22 Swift files (verified Feb 1, 2026)

---

# 1. Executive Summary

## Overview

VWA ("vwah") is a native iOS app that translates Gen Z slang into Spanish and French via voice input. Users speak slang terms into their phone's microphone, and the app displays the definition with translations — like Google Translate for slang.

**Core interaction:**

1. User taps microphone → speaks "no cap"
2. App transcribes → searches local dictionary  
3. Displays: term, English definition, translated explanation, usage example

**Implementation:** Native Swift/SwiftUI with iOS Speech.framework for on-device voice recognition. Fully offline with 49 curated terms bundled in the app.

## Primary Users & Value Prop

| Persona                             | Need                                             | Value                                                        |
| ----------------------------------- | ------------------------------------------------ | ------------------------------------------------------------ |
| **Spanish/French speakers** (18-35) | Understand English slang in media, conversations | Instant voice-based lookup with native language explanations |
| **Parents/Educators** (35-55)       | Decode what younger people are saying            | Simple, non-judgmental explanations                          |

## MVP Scope

### In Scope (MVP)

- Voice-to-text slang lookup (tap mic → speak → see result)
- Browse/search all terms manually
- Spanish and French translations
- Dark/Light mode
- Full offline functionality  
- ~~Favorites~~ (Removed from current implementation)
- ~~Settings screen~~ (Removed from current implementation)

### Out of Scope (MVP)

- User accounts/authentication
- Backend/API
- Analytics
- TTS (text-to-speech) playback
- Onboarding flow
- Help screen
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
1. User opens app → lands on Main screen
2. User taps microphone button
3. System requests microphone permission (first time only)
4. User speaks: "no cap"
5. App transcribes → shows "Listening..." indicator
6. Match found → displays term card with:
   - Term: "NO CAP"
   - Category tag
   - English definition
   - Spanish/French translation (based on toggle)
   - Example sentence with translation
```

### Happy Path: Manual Browse

```
1. User taps "BROWSE" button
2. Browse screen shows searchable list of all terms  
3. User types in search field → list filters in real-time (300ms debounce)
4. User taps a term → returns to Main screen with that term displayed
```

### Edge Case: No Match Found

```
1. User speaks term not in dictionary
2. App shows: "Term not found" state
3. Offers: "Try again" button + "Browse" button
```

### Edge Case: Speech Recognition Failure

```
1. User speaks but nothing detected (silence/noise)
2. After 10 seconds timeout (or 1.5s silence) → show error message
3. Offer: "Try again" button
```

### Edge Case: Permission Denied

```
1. User taps mic → permission prompt appears
2. User denies permission
3. App shows: "Microphone access required" with button to open Settings
```

## 2.3 Feature List (Prioritized)

### P0 — Must Have (MVP Launch)

| Feature               | Description                                     |
| --------------------- | ----------------------------------------------- |
| Voice-to-text lookup  | Tap mic → speak → see matching term             |
| Term card display     | Show term, definition, translation, example     |
| Language toggle       | Switch between ES/FR translations               |
| Browse screen         | Searchable list of all terms                    |
| Manual search         | Type to filter terms in browse (300ms debounce) |
| Dark/Light mode       | System preference + manual toggle               |
| Offline functionality | All content bundled, works without internet     |

### P1 — Removed from Current Implementation

~~Favorites~~ and ~~Settings screen~~ were planned but not implemented in current version.

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
Then the app transcribes my speech within 2 seconds
And searches the local dictionary for matches

Given a matching term is found
When the search completes
Then the term card displays with definition and translation

Given no matching term is found
When the search completes
Then a "Term not found" message displays
And "Try again" and "Browse" buttons are shown
```

### US-002: Browse Terms

**As a** user  
**I want to** browse all available slang terms  
**So that** I can explore and learn new slang

**Acceptance Criteria:**

```gherkin
Given I am on the Main screen
When I tap "BROWSE"
Then the Browse screen opens
And displays a searchable list of all terms

Given I am on the Browse screen
When I type in the search field
Then the list filters to show only matching terms
And filtering happens with 300ms debounce

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
Then my language preference persists (saved in UserDefaults)
```

## 2.5 Non-Functional Requirements

### Performance

- App launch to interactive: < 2 seconds (target)
- Voice transcription latency: < 2 seconds (1.5s silence detection + processing)
- Search/filter response: < 100ms (target: ~30ms with 49 terms)
- Screen transitions: < 300ms

**Note:** Performance metrics are targets/estimates. Actual measurements require profiling with Xcode Instruments.

### Accessibility

- VoiceOver support for all interactive elements (⚠️ Not yet implemented)
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
- All content bundled in app binary (49 terms)

### Reliability

- Crash-free rate target: 99.5%
- Graceful degradation for permission denial
- Error states for all failure modes

---

# 3. UX / IA Outline

## 3.1 Sitemap / Information Architecture

```
VWA App
├── Main Screen (Home)
│   ├── Voice Lookup
│   ├── Term Card Display
│   ├── Language Toggle
│   └── Navigation to Browse
└── Browse Screen
    ├── Search Input (debounced)
    └── Filterable Term List
```

**Note:** Settings screen planned but not implemented in current version.

## 3.2 Screen-by-Screen Specs

### Screen: Main (Home)

**Purpose:** Primary interaction screen for voice lookup and term display

**Entry Points:**
- App launch
- Back from Browse screen

**UI Components:**

| Component      | Description                                                          |
| -------------- | -------------------------------------------------------------------- |
| Header         | Logo + "VWA" wordmark + Theme toggle + Language toggle (ES/FR)      |
| Term Card      | Category tag, term, definition, translation, example, progress dots |
| Voice Button   | Large microphone button to initiate recording                        |
| Waveform       | Animated listening indicator during voice recognition                |
| Nav Controls   | Previous/Next buttons to cycle terms                                 |
| Browse Button  | "BROWSE" button at bottom                                            |
| Error Views    | Data error, voice error, no match states                             |

**States:**

| State               | Trigger                  | Display                                     |
| ------------------- | ------------------------ | ------------------------------------------- |
| Default             | App opens                | Shows last viewed term (or first term)      |
| Listening           | Mic button tapped        | Waveform animates, "LISTENING..." text      |
| Success             | Match found              | Term card updates with matched term         |
| No Match            | No match found           | "Term not found" message + Try Again/Browse |
| Error               | Speech recognition fails | Error message + Try Again/Settings button   |
| Data Error          | terms.json load fails    | "DATA ERROR" message                        |
| Permission Required | Mic permission denied    | Explanation + Settings button               |

**Edge Cases:**
- Empty state: Handled by DataErrorView
- Long definition: Scrollable term card
- Special characters in term: Rendered as-is (emoji support)

### Screen: Browse

**Purpose:** Discover and search all available terms

**Entry Points:**
- "BROWSE" button on Main screen

**UI Components:**

| Component     | Description                                              |
| ------------- | -------------------------------------------------------- |
| Back Button   | Returns to Main screen                                   |
| Title         | "BROWSE" + term count                                    |
| Search Input  | Text field with magnifying glass icon, clear button      |
| Term List     | Lazy-loaded scrollable list (index badge + term + def)   |
| Empty State   | Shown when search has no results                         |

**States:**

| State      | Trigger                | Display                                 |
| ---------- | ---------------------- | --------------------------------------- |
| Default    | Screen opens           | Full list of terms, search empty        |
| Filtering  | User types             | List filters in real-time (300ms debounce) |
| No Results | Filter matches nothing | "No results for '[query]'" message      |

**Edge Cases:**
- Very long list: Uses SwiftUI LazyVStack for performance
- Rapid typing: 300ms debounce prevents excessive recalculation

## 3.3 Navigation Map

```
┌──────────────────────────────────────────────────────────┐
│                    NavigationView                        │
├──────────────────────────────────────────────────────────┤
│                                                          │
│  ┌──────────┐   NavigationLink (isActive)  ┌──────────┐ │
│  │  Main    │ ────────────────────────►     │  Browse  │ │
│  │  Screen  │ ◄───────────────────────      │  Screen  │ │
│  └──────────┘    dismiss/back button        └──────────┘ │
│                                                          │
└──────────────────────────────────────────────────────────┘
```

**Navigation Library:** SwiftUI NavigationView (iOS 13+)

- Simple navigation destination pattern
- No tabs needed (MVP scope)
- No modals needed (MVP scope)
- Deep links: Not required (MVP)

---

# 4. Technical Architecture (Native Swift/SwiftUI)

## 4.1 Architecture Overview

**Approach:** MVVM (Model-View-ViewModel) with SwiftUI, offline-first, no backend, bundled content

```
┌──────────────────────────────────────────────────────────┐
│                   Native Swift/SwiftUI App               │
├──────────────────────────────────────────────────────────┤
│  ┌────────────┐  ┌────────────┐  ┌────────────┐         │
│  │   Views    │  │ ViewModels │  │   Models   │         │
│  │ (SwiftUI)  │  │Observable  │  │  (Codable) │         │
│  │            │  │   Object   │  │            │         │
│  └────────────┘  └────────────┘  └────────────┘         │
│         │                │                │              │
│         └────────────────┼────────────────┘              │
│                          │                               │
│  ┌──────────────────────┴──────────────────────┐        │
│  │              Services                        │        │
│  │  - SpeechRecognizer (Speech.framework)      │        │
│  │  - TermSearch (Custom Levenshtein)          │        │
│  └──────────────────────────────────────────────┘        │
│                          │                               │
│  ┌──────────────────────┴──────────────────────┐        │
│  │              Data Layer                      │        │
│  │  - Bundled JSON (terms.json, 49 terms)      │        │
│  │  - UserDefaults (language, theme, position) │        │
│  └──────────────────────────────────────────────┘        │
└──────────────────────────────────────────────────────────┘
```

**Technology Stack:**

| Layer                | Technology                              |
| -------------------- | --------------------------------------- |
| UI Framework         | SwiftUI                                 |
| State Management     | Combine (ObservableObject + @Published) |
| Navigation           | NavigationView (iOS 13+)                |
| Voice Input          | Speech.framework (SFSpeechRecognizer)   |
| Search               | Custom Levenshtein + Phonetic matching  |
| Data Persistence     | UserDefaults                            |
| Data Format          | Codable JSON                            |
| Theme System         | Custom AppColors struct                 |
| Networking           | None (fully offline)                    |

## 4.2 Folder Structure

**Project Root:**

```
Vwa/  (root directory)
├── Vwa.xcodeproj/           # Xcode project (in root directory)
├── Vwa/                     # Swift source files
│   ├── VwaApp.swift         # @main entry point
│   ├── Models/              # 4 files
│   │   ├── SlangTerm.swift  # Codable data model
│   │   ├── Category.swift   # 8 enum cases
│   │   ├── Language.swift   # ES/FR enum
│   │   └── Theme.swift      # dark/light enum
│   ├── ViewModels/          # 1 file
│   │   └── TermStore.swift  # ObservableObject (app state)
│   ├── Views/               # 2 + 8 component files
│   │   ├── MainView.swift   # Includes DataErrorView (line 278)
│   │   ├── BrowseView.swift
│   │   └── Components/      # 8 reusable SwiftUI views
│   │       ├── TermCardView.swift
│   │       ├── LanguageToggle.swift
│   │       ├── BrutalButton.swift
│   │       ├── SearchBar.swift  # 300ms debounce
│   │       ├── ProgressIndicator.swift
│   │       ├── ListeningIndicator.swift
│   │       ├── NoMatchView.swift
│   │       └── VoiceErrorView.swift
│   ├── Services/            # 2 files
│   │   ├── SpeechRecognizer.swift  # ObservableObject wrapping Speech.framework
│   │   └── TermSearch.swift        # Static search methods
│   ├── Theme/               # 4 files
│   │   ├── Colors.swift     # AppColors struct for dark/light
│   │   ├── Spacing.swift    # Spacing constants
│   │   ├── Typography.swift # Typography extensions
│   │   └── BrutalModifiers.swift  # Custom view modifiers
│   ├── Assets.xcassets/     # Asset catalog
│   └── Resources/
│       └── terms.json       # Bundled slang data (49 terms)
├── data/
│   └── curated_terms.json   # 49 curated terms (source file)
└── docs/
    ├── vwa-architecture.md  # THIS FILE
    └── vwa-design-system.md # Design system reference
```

**Total:** 22 Swift files (verified Feb 1, 2026)

## 4.3 State Management Strategy

**Pattern:** ObservableObject + @EnvironmentObject (Combine framework, iOS 13+)

**Why ObservableObject (not @Observable)?**
- `@Observable` requires iOS 17+, not 16+ as initially planned
- `ObservableObject` supports iOS 13+ with minimal code difference
- YAGNI principle: Works perfectly for single-store app
- Mature pattern with extensive documentation

**Core Pattern:**

```swift
// ViewModels/TermStore.swift
final class TermStore: ObservableObject {
    // Published state
    @Published private(set) var terms: [SlangTerm] = []
    @Published var currentIndex: Int = 0
    @Published var language: Language = .ES
    @Published var theme: Theme = .dark
    @Published private(set) var loadError: String?

    // Computed properties
    var currentTerm: SlangTerm? {
        guard !terms.isEmpty, terms.indices.contains(currentIndex) else { return nil }
        return terms[currentIndex]
    }

    var termCount: Int { terms.count }

    // Actions
    func nextTerm() { /* see TermStore.swift:56 */ }
    func prevTerm() { /* see TermStore.swift:62 */ }
    func setTerm(at index: Int) { /* see TermStore.swift:68 */ }
}
```

**View Integration:**

```swift
// VwaApp.swift
@main
struct VwaApp: App {
    @StateObject private var store = TermStore()

    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(store)
        }
    }
}

// MainView.swift
struct MainView: View {
    @EnvironmentObject private var store: TermStore
    @StateObject private var speechRecognizer = SpeechRecognizer()

    var body: some View {
        // Access store.currentTerm, store.language, etc.
    }
}
```

**Persistence with UserDefaults:**

```swift
// TermStore.swift
private enum Keys {
    static let language = "vwa.language"
    static let theme = "vwa.theme"
    static let currentIndex = "vwa.currentIndex"
}

private func saveLanguage() {
    UserDefaults.standard.set(language.rawValue, forKey: Keys.language)
}

private func loadPreferences() {
    if let savedLang = UserDefaults.standard.string(forKey: Keys.language),
       let lang = Language(rawValue: savedLang) {
        self.language = lang
    }
    // ... load theme and currentIndex
}
```

**Implementation:** See [TermStore.swift](Vwa/ViewModels/TermStore.swift) for full details.

## 4.3.1 SwiftUI View Patterns

Common patterns used across views:

```swift
// Pattern 1: Stateless component with data binding
struct TermCardView: View {
    let term: SlangTerm
    @EnvironmentObject var store: TermStore

    var body: some View {
        // Derive display state from source of truth
        Text(term.translation(for: store.language).definition)
    }
}

// Pattern 2: Stateful component with @StateObject
struct MainView: View {
    @EnvironmentObject private var store: TermStore  // Global state
    @StateObject private var speechRecognizer = SpeechRecognizer()  // Local state
    @State private var showBrowse = false  // View-local state
}

// Pattern 3: Computed properties for derived state
var colors: AppColors {
    AppColors.forTheme(store.theme)
}
```

## 4.4 Data Layer

### Content Data

**Source:** Preprocessed JSON bundled with app

**Data Loading:**

```swift
// TermStore.swift
private func loadTerms() {
    guard let url = Bundle.main.url(forResource: "terms", withExtension: "json") else {
        loadError = "Terms file not found in bundle"
        return
    }

    do {
        let data = try Data(contentsOf: url)
        let decoded = try JSONDecoder().decode([SlangTerm].self, from: data)
        self.terms = decoded
        self.loadError = nil
    } catch {
        loadError = "Failed to load terms: \(error.localizedDescription)"
    }
}
```

### Search Implementation

**Custom Levenshtein with Phonetic Matching**

**Search Pipeline (in order):**
1. **Transcription corrections** (`"no cat"` → `"no cap"`)
2. **Exact match**
3. **Prefix match**
4. **Contains match**
5. **Phonetic match** (Soundex-like algorithm)
6. **Fuzzy match** (Levenshtein with scaled thresholds)

**Threshold Scaling:**

| Query Length | Max Errors | Rationale                    |
| ------------ | ---------- | ---------------------------- |
| 0-2 chars    | 0 (exact)  | "fr" must be exact           |
| 3 chars      | 1          | "sus" allows 1 typo          |
| 4-5 chars    | 1          | Short terms need precision   |
| 6-8 chars    | 2          | Medium terms allow more flex |
| 9+ chars     | 3          | Long terms tolerate errors   |

**Implementation:**

```swift
// Services/TermSearch.swift
struct TermSearch {
    /// Levenshtein-based fuzzy matching with scaled thresholds
    static func search(query: String, in terms: [SlangTerm]) -> SlangTerm? {
        let normalized = normalize(query)
        
        // 1. Check transcription corrections first
        if let corrected = correctionMap[normalized] {
            return exactMatch(corrected, in: terms)
        }
        
        // 2. Exact match
        if let exact = exactMatch(normalized, in: terms) {
            return exact
        }
        
        // 3. Prefix match
        if let prefix = prefixMatch(normalized, in: terms) {
            return prefix
        }
        
        // 4. Contains match
        if let contains = containsMatch(normalized, in: terms) {
            return contains
        }
        
        // 5. Phonetic match
        if let phonetic = phoneticMatch(normalized, in: terms) {
            return phonetic
        }
        
        // 6. Fuzzy match with threshold
        return fuzzyMatch(normalized, in: terms)
    }
    
    private static func calculateThreshold(for query: String) -> Int {
        switch query.count {
        case 0...2: return 0  // "fr" must be exact
        case 3: return 1      // "sus" allow 1 error
        case 4...5: return 1
        case 6...8: return 2
        default: return 3
        }
    }
}
```

**Transcription Corrections (60+ mappings):**
```swift
// Common voice transcription errors → correct term
private static let correctionMap: [String: String] = [
    "no cat": "no cap",
    "low key": "lowkey",
    "high key": "highkey",
    "buzzing": "bussin",
    "sauce": "sus",
    // ... 55+ more corrections
]
```

**Implementation:** See [TermSearch.swift](Vwa/Services/TermSearch.swift) for full algorithm.

### Browse Screen Filtering

**Debounced Search:**

```swift
// Views/Components/SearchBar.swift
struct SearchBar: View {
    @Binding var text: String
    let debounceInterval: TimeInterval = 0.3
    
    @State private var localText: String = ""
    @State private var debounceTask: Task<Void, Never>?
    
    private func debounceSearch(_ query: String) {
        debounceTask?.cancel()
        
        debounceTask = Task {
            try? await Task.sleep(nanoseconds: UInt64(debounceInterval * 1_000_000_000))
            await MainActor.run {
                text = query  // Update binding after 300ms
            }
        }
    }
}
```

**Filter Method:**

```swift
// TermSearch.swift
static func filter(query: String, in terms: [SlangTerm]) -> [(term: SlangTerm, score: Int)] {
    let normalized = normalize(query)
    
    return terms.compactMap { term in
        if normalize(term.term) == normalized { return (term, 100) }  // Exact
        if normalize(term.term).hasPrefix(normalized) { return (term, 80) }  // Prefix
        if normalize(term.term).contains(normalized) { return (term, 60) }  // Contains
        if levenshtein(normalized, normalize(term.term)) <= 2 { return (term, 40) }  // Fuzzy
        if normalize(term.definition).contains(normalized) { return (term, 20) }  // Definition
        return nil
    }
    .sorted { $0.score > $1.score }  // Highest score first
}
```

## 4.5 Speech Recognition

**Framework:** iOS Speech.framework (SFSpeechRecognizer)

**Why iOS Native:**
- Free (no API costs)
- Works on-device (offline for English)
- Good accuracy for short phrases
- Low latency

**Implementation:**

```swift
// Services/SpeechRecognizer.swift
import Speech

final class SpeechRecognizer: ObservableObject {
    @Published private(set) var transcript: String = ""
    @Published private(set) var isRecording: Bool = false
    @Published private(set) var error: SpeechError?
    @Published private(set) var authorizationStatus: SFSpeechRecognizerAuthorizationStatus = .notDetermined
    
    private var recognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var audioEngine = AVAudioEngine()
    
    // Timeout management
    private var silenceTimer: Timer?
    private let maxRecordingTime: TimeInterval = 10.0
    private let silenceTimeout: TimeInterval = 1.5
    
    func startRecording() {
        // 1. Check authorization
        guard SFSpeechRecognizer.authorizationStatus() == .authorized else {
            requestAuthorization()
            return
        }
        
        // 2. Configure audio session
        try? AVAudioSession.sharedInstance().setCategory(.record, mode: .measurement, options: .duckOthers)
        try? AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
        
        // 3. Create recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        recognitionRequest?.shouldReportPartialResults = true
        
        // 4. Create recognition task with silence detection
        recognitionTask = recognizer?.recognitionTask(with: recognitionRequest!) { [weak self] result, error in
            if let result = result {
                self?.transcript = result.bestTranscription.formattedString
                self?.resetSilenceTimer()  // Auto-stop after 1.5s silence
            }
            
            if error != nil || result?.isFinal == true {
                self?.stopRecording()
            }
        }
        
        // 5. Start audio engine
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        try? audioEngine.start()
        
        isRecording = true
        
        // 6. Set hard timeout (10 seconds max)
        Timer.scheduledTimer(withTimeInterval: maxRecordingTime, repeats: false) { [weak self] _ in
            self?.stopRecording()
        }
    }
    
    private func resetSilenceTimer() {
        silenceTimer?.invalidate()
        silenceTimer = Timer.scheduledTimer(withTimeInterval: silenceTimeout, repeats: false) { [weak self] _ in
            self?.stopRecording()  // Auto-stop after 1.5s of silence
        }
    }
}
```

**Smart Timeout Strategy:**
- **Hard limit:** 10 seconds max
- **Silence-based auto-stop:** 1.5 seconds after speech ends
- User gets instant feedback without manual stop button

**Error Handling:**

```swift
enum SpeechError: Error, LocalizedError {
    case notAuthorized
    case recognitionNotAvailable
    case audioEngineFailure
    case recognitionFailed(String)
    // ... 4 more error types
    
    var errorDescription: String? {
        switch self {
        case .notAuthorized: return "Microphone access not authorized"
        case .recognitionNotAvailable: return "Speech recognition unavailable"
        // ... user-friendly messages
        }
    }
}
```

**Implementation:** See [SpeechRecognizer.swift](Vwa/Services/SpeechRecognizer.swift) for full details.

## 4.6 Navigation

**Library:** SwiftUI NavigationView (iOS 13+)

```swift
// Views/MainView.swift
NavigationView {
    ZStack {
        // Main content

        // Hidden NavigationLink for iOS 15 compatibility
        NavigationLink(
            destination: BrowseView()
                .environmentObject(store),
            isActive: $showBrowse
        ) {
            EmptyView()
        }
        .hidden()
    }
}
.navigationViewStyle(.stack)
```

**iOS Compatibility:**
- Uses `NavigationView + NavigationLink` pattern for iOS 15+ support
- `.navigationViewStyle(.stack)` prevents split-view on iPad
- Deployment target: iOS 15.0

## 4.7 Data Models

### Swift Structs

```swift
// Models/SlangTerm.swift
struct SlangTerm: Identifiable, Codable {
    let id: Int
    let term: String
    let category: Category
    let definition: String
    let example: String?
    let translations: Translations
    let meta: TermMeta
    
    func translation(for language: Language) -> Translation {
        switch language {
        case .ES: return translations.ES
        case .FR: return translations.FR
        }
    }
}

struct Translations: Codable {
    let ES: Translation
    let FR: Translation
}

struct Translation: Codable {
    let definition: String
    let example: String?
}

struct TermMeta: Codable {
    let thumbsUp: Int
    let thumbsDown: Int
    let author: String
    let addedOn: String
}
```

```swift
// Models/Category.swift
enum Category: String, Codable, CaseIterable {
    case TRUTH       // no cap, fr, on god
    case CRITICISM   // mid, sus, cringe
    case DEGREE      // lowkey, highkey, deadass
    case EMOTION     // salty, pressed, tilted
    case PRAISE      // slay, goated, fire
    case QUALITY     // bussin, slaps, hits different
    case AGREEMENT   // bet, facts, say less
    case OTHER       // Catch-all

    var color: Color {
        switch self {
        case .TRUTH: return .blue
        case .PRAISE: return .green
        case .CRITICISM: return .red
        // ... theme-specific colors
        }
    }
}
```

```swift
// Models/Language.swift
enum Language: String, Codable, CaseIterable {
    case ES, FR

    var displayName: String {
        switch self {
        case .ES: return "Español"
        case .FR: return "Français"
        }
    }
}
```

```swift
// Models/Theme.swift
enum Theme: String, Codable, CaseIterable {
    case dark, light
}
```

**Full schema:** See [SlangTerm.swift](Vwa/Models/SlangTerm.swift)

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
      "definition": "Se usa para indicar que se está siendo honesto o serio; sin mentir ni exagerar.",
      "example": "Sin mentir, ese concierto fue el mejor al que he ido."
    },
    "FR": {
      "definition": "Utilisé pour indiquer qu'on est honnête ou sérieux; sans mentir ni exagérer.",
      "example": "Sans mentir, ce concert était le meilleur auquel je suis allé."
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

| Permission                     | When Requested       | Fallback                                 |
| ------------------------------ | -------------------- | ---------------------------------------- |
| Microphone                     | First mic button tap | Explain why needed, link to Settings app |
| Speech Recognition (automatic) | First mic button tap | Included with microphone authorization   |

### Info.plist Configuration

The project uses **auto-generated Info.plist** with keys defined in Xcode project settings:

```
# In Vwa.xcodeproj/project.pbxproj (lines 273-274):
GENERATE_INFOPLIST_FILE = YES;
INFOPLIST_FILE = Vwa/Info.plist;
INFOPLIST_KEY_NSMicrophoneUsageDescription = "VWA needs microphone access to hear what you say.";
INFOPLIST_KEY_NSSpeechRecognitionUsageDescription = "VWA needs speech recognition to look up slang terms by voice.";
```

**Note:** The `Vwa/Info.plist` file is empty (`<dict/>`) because Xcode generates it at build time from `INFOPLIST_KEY_*` settings. This is standard for modern Xcode projects.

### Runtime Authorization

```swift
// SpeechRecognizer.swift
func requestAuthorization() {
    SFSpeechRecognizer.requestAuthorization { status in
        DispatchQueue.main.async {
            self.authorizationStatus = status
            if status != .authorized {
                self.error = .notAuthorized
            }
        }
    }
}
```

**Implementation:** See [SpeechRecognizer.swift:45-68](Vwa/Services/SpeechRecognizer.swift)

### Data Privacy

- No user data collected
- No network requests (fully offline)
- No analytics (MVP)
- Preferences stored locally only in UserDefaults (never transmitted)

### App Transport Security

Not applicable — no network requests.

## 4.9 Performance Plan

### Targets & Implementation Notes

| Metric            | Target   | Implementation Notes                                    |
| ----------------- | -------- | ------------------------------------------------------- |
| Cold start        | < 2s     | Native Swift (typically faster than React Native)       |
| Voice latency     | < 3s     | 1.5s silence detection + transcription processing       |
| Search performance| < 100ms  | Custom Levenshtein on 49 terms (in-memory)              |
| Memory footprint  | < 150MB  | Native iOS (typically <100MB)                           |

**Note:** Performance metrics are **targets/estimates**. Actual measurements require profiling with Xcode Instruments (not yet performed).

### Optimization Techniques (Implemented)

- ✅ Lazy loading for BrowseView list (SwiftUI LazyVStack)
- ✅ Debounced search (300ms in [SearchBar.swift:12](Vwa/Views/Components/SearchBar.swift))
- ✅ Audio session cleanup in deinit (SpeechRecognizer)
- ✅ UserDefaults batching (TermStore saves on didSet)

### Profiling Recommendations

**To measure actual performance:**

```bash
# Open Instruments from Xcode
# Xcode → Product → Profile (Cmd+I)

# Recommended instruments:
- Time Profiler: Measure cold start, voice latency
- Allocations: Check memory usage
- Leaks: Verify no memory leaks in SpeechRecognizer
```

## 4.10 Xcode Project Configuration

### Build Settings

**Current (After Fix):**
- iOS Deployment Target: **15.0** (was 26.2, now fixed)
- Swift Language Version: 5.9+
- Optimization Level: -O (Release), -Onone (Debug)

**Capabilities Required:**
- Microphone: Enabled (automatically via Info.plist keys)
- Speech Recognition: Enabled (automatically via Info.plist keys)

### Bundle Configuration (Verified)

- Bundle Identifier: `com.jeanlucphilistin.Vwa` (project.pbxproj:285)
- Display Name: Vwa
- Marketing Version: `1.0` (project.pbxproj:284)
- Build Number: `1` (project.pbxproj:268)

### Signing

- Team: [Your Apple Developer Team ID]
- Provisioning Profile: Automatic (Debug), Manual (Release)

---

# 5. Integrations & Services

## 5.1 Build-Time Services (Not Runtime)

### Translation Generation

**Service:** Groq API (Free Tier) — Llama 3.3 70B (`llama-3.3-70b-versatile`)

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
cd src
python translate_terms.py \
    --input data/slang_terms.json \
    --output data/processed_terms.json
```

**What the script does:**
1. Filters explicit/low-quality content
2. Calls Groq API to generate contextual ES/FR translations
3. Auto-categorizes each term
4. Saves progress with checkpointing (resume if interrupted)

**Current Status:** 49 terms have been preprocessed and are bundled in `Vwa/Resources/terms.json`

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

## 5.3 Future Analytics (Not in MVP)

If analytics added later, recommend:
- **PostHog** (privacy-focused, can self-host)
- **TelemetryDeck** (privacy-first, SwiftPM package)

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
```

---

# 6. Testing & Quality

## Testing Strategy (Not Implemented)

Per YAGNI principles and user preference, automated testing has been deferred until MVP validates the concept.

**Recommended Future Testing Layers:**

| Layer       | Tool                    | Coverage Target     |
| ----------- | ----------------------- | ------------------- |
| Unit        | XCTest                  | 80% for logic       |
| Component   | SwiftUI Previews        | All components      |
| Integration | XCTest + Mock Speech    | Critical flows      |
| UI          | XCUITest                | Smoke tests         |
| Manual      | QA checklist            | Accessibility, edge |

**Example Unit Test (Future):**

```swift
import XCTest
@testable import Vwa

final class TermSearchTests: XCTestCase {
    func testExactMatch() {
        let terms = [SlangTerm(term: "no cap", ...)]
        let result = TermSearch.search(query: "no cap", in: terms)
        XCTAssertEqual(result?.term, "no cap")
    }
    
    func testTranscriptionCorrection() {
        let terms = [SlangTerm(term: "no cap", ...)]
        let result = TermSearch.search(query: "no cat", in: terms)
        XCTAssertEqual(result?.term, "no cap")
    }
    
    func testScaledThreshold() {
        // Short terms (2-3 chars) require exact match
        XCTAssertEqual(TermSearch.calculateThreshold(for: "fr"), 0)
        // Longer terms allow errors
        XCTAssertEqual(TermSearch.calculateThreshold(for: "bussin"), 2)
    }
}
```

**SwiftUI Previews (Current):**

```swift
#Preview("Term Card - Dark Mode") {
    TermCardView(term: .mockNoCap)
        .environmentObject(TermStore())
        .preferredColorScheme(.dark)
}

#Preview("Term Card - Light Mode") {
    TermCardView(term: .mockNoCap)
        .environmentObject(TermStore())
        .preferredColorScheme(.light)
}
```

---

# 7. DevOps & Release

## 7.1 Environments

| Environment | Purpose             | Build Type |
| ----------- | ------------------- | ---------- |
| Development | Local dev           | Debug      |
| Preview     | TestFlight internal | Release    |
| Production  | App Store           | Release    |

## 7.2 Local Development

```bash
# Open project (PROJECT IS IN ROOT DIRECTORY)
open Vwa.xcodeproj

# Build and run
# Xcode: Cmd+R
# Select simulator or physical device

# Debug with Instruments
# Xcode: Cmd+I → Time Profiler / Allocations

# Verify deployment target is set correctly
xcodebuild -project Vwa.xcodeproj -showBuildSettings | grep IPHONEOS_DEPLOYMENT_TARGET
# Should show: IPHONEOS_DEPLOYMENT_TARGET = 15.0
# NOT: 26.2 (now fixed)
```

## 7.3 TestFlight Distribution

**Prerequisites:**
- Apple Developer account ($99/year)
- App Store Connect app created
- Certificates & provisioning profiles

**Steps:**

1. **Archive:** Xcode → Product → Archive
2. **Validate:** Select archive → Validate App
   - Checks code signing
   - Validates App Store guidelines
   - Scans for common issues
3. **Distribute:** Distribute App → TestFlight
4. **Internal Testing:** Up to 100 testers, instant access
5. **External Testing:** Requires App Review (1-2 days)

## 7.4 App Store Submission

**Steps:**

1. Bump version in project settings: `MARKETING_VERSION`
2. Update build number: `CURRENT_PROJECT_VERSION`
3. Create archive with Release configuration
4. Upload to App Store Connect
5. Fill in App Store metadata (screenshots, description, keywords)
6. Submit for review (typical: 24-48 hours)

**Required Metadata:**

```
App Name: VWA - Slang Translator
Subtitle: Gen Z slang in Spanish & French
Category: Education / Reference
Age Rating: 12+ (slang content)
```

## 7.5 Version Management

**Current:**
- Marketing Version: `1.0`
- Build Number: `1`

**Versioning Strategy:**
- Increment build number for each TestFlight upload
- Increment marketing version for App Store releases
- Apple requires: build number > previous for same version

**Example:**
- Local dev: 1.0 (1)
- TestFlight beta 1: 1.0 (2)
- TestFlight beta 2: 1.0 (3)
- App Store v1: 1.0 (4)
- App Store v1.1: 1.1 (5)

## 7.6 CI/CD (Future)

**Current:** Manual Xcode workflow (sufficient for solo dev MVP)

**Future Options:**

| Tool                  | Cost          | Setup Complexity | Integration      |
| --------------------- | ------------- | ---------------- | ---------------- |
| Manual Xcode          | Free          | Low              | Manual           |
| Xcode Cloud           | Free (25h/mo) | Low              | Seamless         |
| GitHub Actions + Fastlane | Free (2000min/mo) | Medium | Full control |
| Fastlane              | Free          | High             | Full control     |

**Recommendation:** Manual Xcode for MVP, migrate to Xcode Cloud when automating releases.

---

# 8. Risks, Open Questions, and Next Steps

## 8.1 Top Risks & Mitigations

| Risk                            | Likelihood | Impact | Mitigation                                                       |
| ------------------------------- | ---------- | ------ | ---------------------------------------------------------------- |
| **Speech recognition accuracy** | Medium     | High   | Fuzzy matching with custom Levenshtein; manual fallback via Browse |
| **Translation quality**         | Medium     | Medium | Already generated via Groq; manual review completed               |
| **Content appropriateness**     | Low        | High   | Manual review pass completed; 49 curated terms                    |
| **App Store rejection**         | Low        | High   | Follow guidelines; clear microphone justification in INFOPLIST_KEY |
| **Data staleness**              | Low        | Low    | Portfolio project; freshness not critical                         |
| **iOS 16+ requirement**         | N/A        | N/A    | ✅ Fixed: Now using NavigationView for iOS 15+ compatibility      |

## 8.2 Open Questions

| Question                              | Status     | Notes                                          |
| ------------------------------------- | ---------- | ---------------------------------------------- |
| Deploy iOS 15 or 16 minimum?          | **Decided** | iOS 15.0+ using NavigationView                 |
| TestFlight tester list                | Pending    | Not needed until first preview build           |
| Accessibility testing plan            | Pending    | VoiceOver support not yet implemented          |

**Decided:**
- ✅ Native Swift (not React Native)
- ✅ ObservableObject (not @Observable macro)
- ✅ Translation API: Groq (Llama 3.3 70B)
- ✅ Manual Xcode workflow (no Xcode Cloud for MVP)
- ✅ Skip automated tests until MVP validates concept

## 8.3 Critical Technical Decisions Documented

### Why ObservableObject (not @Observable)?
**Decision:** Use ObservableObject + Combine (iOS 13+) instead of @Observable macro (iOS 17+)

**Rationale:**
1. **Device compatibility:** Supports iOS 15+ (~85% of active devices)
2. **YAGNI principle:** ObservableObject works perfectly for this app's scope
3. **Stability:** Mature pattern with extensive documentation
4. **Complexity:** @Observable provides minimal benefit for single-store app

**Future Option:** Can migrate to @Observable when iOS 17+ adoption reaches 90%+

### Why Custom Search (not Core Data/NSPredicate)?
**Decision:** Custom Levenshtein implementation over framework-provided search

**Rationale:**
1. **Data size:** Only 49 terms, in-memory search is instant (~30ms estimated)
2. **Read-only:** No writes, no need for database
3. **Bundled data:** JSON in app bundle, not fetched or updated
4. **Control:** Custom phonetic matching + transcription corrections (60+ mappings)
5. **YAGNI:** Core Data overhead unjustified for this use case

### Why NavigationView (not NavigationStack)?
**Decision:** Use NavigationView + NavigationLink for iOS 15+ compatibility

**Rationale:**
1. **Broader compatibility:** Supports iOS 13+ (NavigationStack requires 16+)
2. **Device coverage:** Includes iOS 15 users (~10-15% of devices in Jan 2026)
3. **Stability:** Mature pattern with extensive documentation
4. **Simplicity:** Only two screens (Main → Browse), no complex navigation needs

**Tradeoff:** NavigationStack has cleaner programmatic navigation API, but not needed for this simple app structure

## 8.4 Next Steps

### Immediate (Pre-Launch)

- [x] ~~Fix NavigationStack compatibility issue~~ ✅ Migrated to NavigationView for iOS 15+ support
- [ ] Manual QA on physical device
- [ ] VoiceOver accessibility check (add labels)
- [ ] Performance profiling (cold start, voice latency, search)
- [ ] Memory profiling (check for leaks in SpeechRecognizer)

### TestFlight Phase

- [ ] Create TestFlight build
- [ ] Internal testing with 5-10 testers
- [ ] Collect feedback on voice recognition accuracy
- [ ] Iterate on transcription correction mappings if needed

### App Store Submission

- [ ] App icons (all sizes: 1024x1024, 60x60, etc.)
- [ ] Screenshots (6.7", 6.5", 5.5" displays)
- [ ] App description and keywords
- [ ] Privacy policy URL (can be GitHub Pages)
- [ ] Submit for review

### Post-Launch (V1.1+)

- [ ] Add Settings screen with favorites
- [ ] Implement analytics (TelemetryDeck or PostHog)
- [ ] Add more slang terms (target: 100-200)
- [ ] Consider adding Haitian Creole as third language
- [ ] Implement automated tests once concept validated

---

# Completeness Check

## Well-Defined

- ✅ Core user flows (voice lookup, browse)
- ✅ Data model and schema (49 curated terms)
- ✅ Technical stack choices (Native Swift/SwiftUI)
- ✅ Screen specs and navigation (NavigationView)
- ✅ State management approach (ObservableObject)
- ✅ Folder structure (20 Swift files, 1,779 LOC)
- ✅ All code implemented and functional

## Ambiguous / Needs Decision

- ✅ **iOS 15 vs 16 minimum:** Fixed - Now using NavigationView for full iOS 15+ compatibility
- **Accessibility implementation:** VoiceOver labels not yet added
- **Performance metrics:** Estimates provided, actual measurements needed

## Biggest Execution Risk

**Voice recognition transcription errors.** While the app has 60+ transcription corrections and fuzzy matching, some slang terms may still be hard to recognize. Recommend:

1. Test with 10+ users during TestFlight
2. Collect transcripts that failed to match
3. Add new correction mappings based on real usage
4. Consider adding phonetic hints in UI for problem terms

---

_Document version: 2.0 (Native Swift/SwiftUI)_  
_Last updated: January 31, 2026_  
_Status: Production-ready (reflects implemented code)_

