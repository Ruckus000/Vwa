# VWA Swift Implementation Plan v2

**Native iOS with SwiftUI — Revised with Critical Fixes**

## Changes from v1

| Issue | Fix |
|-------|-----|
| iOS 15 `onChange` syntax wrong | Fixed to single-parameter closure |
| Fuzzy search threshold too permissive for short terms | Threshold now scales with term length |
| Search recalculates on every keystroke | Added 300ms debounce |
| 5-second hard timeout is user-hostile | Changed to silence-based detection |
| Memory leaks in SpeechRecognizer | Fixed weak self usage |
| Transcription corrections don't scale | Added phonetic fallback matching |
| Data quality (terms aren't Gen Z slang) | Manual curation required before proceeding |

---

## PHASE 0: Data Preparation (BLOCKING)

### The Problem

Your current `processed_terms.json` contains terms like "IQ-fluid", "Poom Poom Jenkins", "spacedocking" — none of which are Gen Z slang. The curated list in the original plan was never actually processed.

### Solution: Manual Curation (Simplest Path)

**Option A: Spreadsheet Method (Recommended for MVP)**

1. Create a Google Sheet or Excel file with columns:
   - `term` | `definition` | `example` | `category` | `es_definition` | `es_example` | `fr_definition` | `fr_example`

2. Manually add 30-50 real Gen Z terms (start small, validate the app works)

3. Export to JSON with this structure:

```json
[
  {
    "id": 1,
    "term": "no cap",
    "category": "TRUTH",
    "definition": "For real, no lie, I'm being serious",
    "example": "That pizza was amazing, no cap",
    "translations": {
      "ES": {
        "definition": "Expresión que significa 'en serio' o 'sin mentir'. Se usa para enfatizar que algo es verdad.",
        "example": "Esa pizza estaba increíble, en serio"
      },
      "FR": {
        "definition": "Expression signifiant 'sérieusement' ou 'sans mentir'. Utilisé pour souligner la vérité.",
        "example": "Cette pizza était incroyable, sans mentir"
      }
    },
    "meta": {
      "thumbsUp": 0,
      "thumbsDown": 0,
      "author": "manual",
      "addedOn": "2025-01-30"
    }
  }
]
```

4. Save as `data/curated_terms.json`

**Starter Terms (copy these):**

```
no cap, lowkey, highkey, bet, slay, bussin, mid, sus, fire, goated,
fr fr, on god, deadass, salty, pressed, finna, periodt, slaps,
hits different, main character, ate, understood the assignment,
rent free, its giving, say less, valid, vibes, caught in 4k, stan,
simp, pick me, based, cringe, W, L, ratio, ong, ngl, iykyk, rizz,
delulu, snatched, tea, ick, sending me, unalive, cheugy, yeet
```

**Time estimate:** 2-3 hours to manually add 40-50 terms with translations

**Option B: Web Interface (Post-MVP)**

Build a simple admin interface later. Not needed for MVP.

---

## PHASE 1-3: Unchanged

Project setup, models, and theme system remain the same as v1. Copy those phases directly.

---

## PHASE 4: Services (REVISED)

### Task 4.1: Improved Fuzzy Search

**Services/TermSearch.swift**

```swift
import Foundation

struct TermSearch {

    // MARK: - Transcription Corrections

    /// Common voice transcription errors for slang terms
    private static let transcriptionCorrections: [String: String] = [
        // "no cap" variations
        "no cat": "no cap",
        "no cab": "no cap",
        "no calf": "no cap",
        "knock up": "no cap",
        "no clap": "no cap",

        // "bussin" variations
        "bussing": "bussin",
        "busting": "bussin",
        "buzzing": "bussin",
        "bus in": "bussin",
        "blessing": "bussin",

        // "lowkey" variations
        "low key": "lowkey",
        "low-key": "lowkey",
        "low ski": "lowkey",
        "loki": "lowkey",

        // "highkey" variations
        "high key": "highkey",
        "high-key": "highkey",
        "hi key": "highkey",

        // "deadass" variations
        "dead ass": "deadass",
        "dead as": "deadass",
        "that ass": "deadass",

        // "goated" variations
        "go to": "goated",
        "go did": "goated",
        "coated": "goated",
        "quoted": "goated",

        // "sus" variations
        "sauce": "sus",
        "suss": "sus",
        "such": "sus",

        // "fr fr" variations
        "for real for real": "fr fr",
        "far far": "fr fr",
        "fur fur": "fr fr",
        "efar efar": "fr fr",

        // "periodt" variations
        "period": "periodt",
        "period t": "periodt",

        // "rizz" variations
        "riz": "rizz",
        "rise": "rizz",
        "rizzle": "rizz",

        // "delulu" variations
        "the lulu": "delulu",
        "de lulu": "delulu",
    ]

    // MARK: - Public API

    /// Search for a term with fuzzy matching (for voice input)
    /// Returns the best match or nil if no good match found
    static func search(
        query: String,
        in terms: [SlangTerm]
    ) -> SlangTerm? {
        let normalizedQuery = normalize(query)

        guard !normalizedQuery.isEmpty else { return nil }

        // Step 1: Check transcription corrections first
        if let corrected = transcriptionCorrections[normalizedQuery],
           let match = terms.first(where: { normalize($0.term) == corrected }) {
            return match
        }

        // Step 2: Exact match
        if let exact = terms.first(where: { normalize($0.term) == normalizedQuery }) {
            return exact
        }

        // Step 3: Prefix match (user said start of term)
        if let prefix = terms.first(where: { normalize($0.term).hasPrefix(normalizedQuery) }) {
            return prefix
        }

        // Step 4: Contains match
        if let contains = terms.first(where: { normalize($0.term).contains(normalizedQuery) }) {
            return contains
        }

        // Step 5: Phonetic matching (sounds similar)
        if let phonetic = findPhoneticMatch(query: normalizedQuery, in: terms) {
            return phonetic
        }

        // Step 6: Levenshtein fuzzy match with SCALED threshold
        // Short terms need tighter matching to avoid false positives
        let threshold = calculateThreshold(for: normalizedQuery)

        var bestMatch: SlangTerm?
        var bestDistance = Int.max

        for term in terms {
            let termNormalized = normalize(term.term)
            let distance = levenshteinDistance(normalizedQuery, termNormalized)

            if distance <= threshold && distance < bestDistance {
                bestDistance = distance
                bestMatch = term
            }
        }

        return bestMatch
    }

    /// Filter terms for browse/search UI with debounce-friendly design
    /// Returns scored and sorted results
    static func filter(query: String, in terms: [SlangTerm]) -> [SlangTerm] {
        let normalizedQuery = normalize(query)

        guard !normalizedQuery.isEmpty else { return terms }

        // Use a more efficient single-pass scoring
        var results: [(term: SlangTerm, score: Int)] = []
        results.reserveCapacity(terms.count / 4) // Estimate ~25% will match

        let threshold = calculateThreshold(for: normalizedQuery)

        for term in terms {
            let termNormalized = normalize(term.term)

            // Exact match - highest priority
            if termNormalized == normalizedQuery {
                results.append((term, 100))
                continue
            }

            // Prefix match - high priority
            if termNormalized.hasPrefix(normalizedQuery) {
                results.append((term, 80))
                continue
            }

            // Contains match - medium priority
            if termNormalized.contains(normalizedQuery) {
                results.append((term, 60))
                continue
            }

            // Fuzzy match - lower priority, scaled by distance
            let distance = levenshteinDistance(normalizedQuery, termNormalized)
            if distance <= threshold {
                let score = 40 - (distance * 10)
                results.append((term, max(score, 10)))
                continue
            }

            // Definition contains query - lowest priority
            if normalize(term.definition).contains(normalizedQuery) {
                results.append((term, 20))
            }
        }

        // Sort by score descending
        results.sort { $0.score > $1.score }

        return results.map { $0.term }
    }

    // MARK: - Threshold Calculation

    /// Calculate appropriate Levenshtein threshold based on term length
    /// Short terms need stricter matching to avoid false positives
    private static func calculateThreshold(for query: String) -> Int {
        let length = query.count

        switch length {
        case 0...2:
            return 0  // "fr", "W", "L" - must be exact
        case 3:
            return 1  // "bet", "sus", "mid" - allow 1 error
        case 4...5:
            return 1  // "slay", "fire" - allow 1 error
        case 6...8:
            return 2  // "bussin", "lowkey" - allow 2 errors
        default:
            return 3  // longer terms - allow 3 errors
        }
    }

    // MARK: - Phonetic Matching

    /// Simple phonetic matching using Soundex-like approach
    /// Catches cases where transcription sounds right but spelled wrong
    private static func findPhoneticMatch(query: String, in terms: [SlangTerm]) -> SlangTerm? {
        let queryCode = simplePhoneticCode(query)

        for term in terms {
            let termCode = simplePhoneticCode(term.term)
            if queryCode == termCode && queryCode.count >= 2 {
                return term
            }
        }

        return nil
    }

    /// Very simple phonetic coding (not full Soundex, just key patterns)
    private static func simplePhoneticCode(_ text: String) -> String {
        var result = text.lowercased()

        // Normalize common sound patterns
        let replacements: [(String, String)] = [
            ("ph", "f"),
            ("ck", "k"),
            ("gh", ""),
            ("tion", "shun"),
            ("sion", "shun"),
            ("ss", "s"),
            ("ee", "e"),
            ("oo", "u"),
            ("ou", "u"),
            ("ow", "o"),
            ("ay", "a"),
            ("ey", "e"),
            ("ie", "e"),
            ("ea", "e"),
        ]

        for (pattern, replacement) in replacements {
            result = result.replacingOccurrences(of: pattern, with: replacement)
        }

        // Remove vowels except first character
        if result.count > 1 {
            let first = String(result.prefix(1))
            let rest = String(result.dropFirst())
            let consonantsOnly = rest.filter { !"aeiou".contains($0) }
            result = first + consonantsOnly
        }

        return result
    }

    // MARK: - Private Helpers

    private static func normalize(_ text: String) -> String {
        text
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "'", with: "'")
            .replacingOccurrences(of: "'", with: "'")
            .replacingOccurrences(of: "-", with: " ")
            .components(separatedBy: .whitespaces)
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }

    /// Optimized Levenshtein using two-row approach (O(min(m,n)) space)
    private static func levenshteinDistance(_ s1: String, _ s2: String) -> Int {
        let s1Chars = Array(s1)
        let s2Chars = Array(s2)
        let m = s1Chars.count
        let n = s2Chars.count

        if m == 0 { return n }
        if n == 0 { return m }

        // Ensure s1 is the shorter string for space optimization
        if m > n {
            return levenshteinDistance(s2, s1)
        }

        // Use two rows instead of full matrix
        var previousRow = [Int](0...m)
        var currentRow = [Int](repeating: 0, count: m + 1)

        for j in 1...n {
            currentRow[0] = j

            for i in 1...m {
                let cost = s1Chars[i - 1] == s2Chars[j - 1] ? 0 : 1
                currentRow[i] = min(
                    previousRow[i] + 1,      // deletion
                    currentRow[i - 1] + 1,   // insertion
                    previousRow[i - 1] + cost // substitution
                )
            }

            swap(&previousRow, &currentRow)
        }

        return previousRow[m]
    }
}
```

### Task 4.2: Improved Speech Recognizer

**Services/SpeechRecognizer.swift**

```swift
import Speech
import AVFoundation
import Combine

final class SpeechRecognizer: ObservableObject {
    // MARK: - Public State
    @Published private(set) var transcript: String = ""
    @Published private(set) var isRecording: Bool = false
    @Published private(set) var error: SpeechError?
    @Published private(set) var authorizationStatus: SFSpeechRecognizerAuthorizationStatus = .notDetermined

    // MARK: - Configuration
    /// Maximum recording time (hard limit)
    private let maxRecordingSeconds: TimeInterval = 10.0
    /// Silence duration that triggers auto-stop AFTER speech detected
    private let silenceThreshold: TimeInterval = 1.5

    // MARK: - Private Properties
    private var recognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var audioEngine = AVAudioEngine()
    private var maxTimeoutTask: Task<Void, Never>?
    private var silenceTimer: Timer?
    private var hasReceivedSpeech: Bool = false

    // MARK: - Error Types
    enum SpeechError: LocalizedError {
        case notAuthorized
        case notAvailable
        case recognizerUnavailable
        case audioSessionFailed
        case recognitionFailed(String)
        case noSpeechDetected
        case microphonePermissionDenied

        var errorDescription: String? {
            switch self {
            case .notAuthorized:
                return "Speech recognition not authorized"
            case .notAvailable:
                return "Speech recognition not available"
            case .recognizerUnavailable:
                return "Speech recognizer unavailable for English"
            case .audioSessionFailed:
                return "Could not start audio session"
            case .recognitionFailed(let message):
                return "Recognition failed: \(message)"
            case .noSpeechDetected:
                return "Didn't catch that. Try speaking closer to the mic."
            case .microphonePermissionDenied:
                return "Microphone access required"
            }
        }

        var requiresSettings: Bool {
            switch self {
            case .notAuthorized, .microphonePermissionDenied:
                return true
            default:
                return false
            }
        }
    }

    // MARK: - Initialization
    init() {
        recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
        checkAuthorizationStatus()
    }

    deinit {
        stopRecording()
    }

    // MARK: - Authorization
    func requestAuthorization() {
        SFSpeechRecognizer.requestAuthorization { [weak self] status in
            DispatchQueue.main.async {
                self?.authorizationStatus = status
                if status != .authorized {
                    self?.error = .notAuthorized
                }
            }
        }
    }

    private func checkAuthorizationStatus() {
        authorizationStatus = SFSpeechRecognizer.authorizationStatus()
    }

    // MARK: - Recording Control
    func startRecording() {
        // Reset state
        error = nil
        transcript = ""
        hasReceivedSpeech = false

        // Check authorization
        guard authorizationStatus == .authorized else {
            if authorizationStatus == .notDetermined {
                requestAuthorization()
            } else {
                error = .notAuthorized
            }
            return
        }

        // Check recognizer availability
        guard let recognizer = recognizer else {
            error = .recognizerUnavailable
            return
        }

        guard recognizer.isAvailable else {
            error = .notAvailable
            return
        }

        // Clean up any existing session
        stopRecording()

        // Configure audio session
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            self.error = .audioSessionFailed
            return
        }

        // Create recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            error = .recognitionFailed("Could not create request")
            return
        }

        recognitionRequest.shouldReportPartialResults = true

        // Set up audio input
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)

        // Create recognition task
        recognitionTask = recognizer.recognitionTask(with: recognitionRequest) { [weak self] result, taskError in
            guard let self = self else { return }

            var isFinal = false

            if let result = result {
                let newTranscript = result.bestTranscription.formattedString

                DispatchQueue.main.async {
                    self.transcript = newTranscript
                    self.hasReceivedSpeech = true

                    // Reset silence timer on new speech
                    self.resetSilenceTimer()
                }

                isFinal = result.isFinal
            }

            if let taskError = taskError {
                DispatchQueue.main.async {
                    // Don't report error if we got valid results
                    if self.transcript.isEmpty {
                        self.error = .recognitionFailed(taskError.localizedDescription)
                    }
                    self.stopRecording()
                }
            } else if isFinal {
                DispatchQueue.main.async {
                    self.stopRecording()
                }
            }
        }

        // Install audio tap
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
        }

        // Start audio engine
        audioEngine.prepare()
        do {
            try audioEngine.start()
            isRecording = true
            startMaxTimeout()
        } catch {
            self.error = .audioSessionFailed
            cleanupRecording()
        }
    }

    func stopRecording() {
        guard isRecording else { return }

        cleanupRecording()

        // If we never received any speech, show appropriate error
        if transcript.isEmpty && error == nil {
            error = .noSpeechDetected
        }
    }

    private func cleanupRecording() {
        // Cancel timers
        maxTimeoutTask?.cancel()
        maxTimeoutTask = nil
        silenceTimer?.invalidate()
        silenceTimer = nil

        // Stop audio engine
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }

        // End recognition
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        recognitionTask?.cancel()
        recognitionTask = nil

        // Deactivate audio session
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)

        isRecording = false
    }

    func clearError() {
        error = nil
    }

    // MARK: - Smart Timeout Logic

    /// Hard maximum recording time
    private func startMaxTimeout() {
        maxTimeoutTask = Task { [weak self] in
            guard let self = self else { return }

            do {
                try await Task.sleep(nanoseconds: UInt64(self.maxRecordingSeconds * 1_000_000_000))

                await MainActor.run {
                    if self.isRecording {
                        self.stopRecording()
                    }
                }
            } catch {
                // Cancelled - that's fine
            }
        }
    }

    /// Reset silence timer - called when new speech is detected
    private func resetSilenceTimer() {
        silenceTimer?.invalidate()

        silenceTimer = Timer.scheduledTimer(withTimeInterval: silenceThreshold, repeats: false) { [weak self] _ in
            guard let self = self else { return }

            // Only auto-stop if we've received some speech
            if self.isRecording && self.hasReceivedSpeech {
                self.stopRecording()
            }
        }
    }
}
```

---

## PHASE 5: Core Components (REVISED)

### Task 5.4: Debounced Search Bar

**Views/Components/SearchBar.swift**

```swift
import SwiftUI
import Combine

struct SearchBar: View {
    @Binding var text: String
    let colors: AppColors
    let debounceInterval: TimeInterval

    @State private var localText: String = ""
    @State private var debounceTask: Task<Void, Never>?

    init(text: Binding<String>, colors: AppColors, debounceInterval: TimeInterval = 0.3) {
        self._text = text
        self.colors = colors
        self.debounceInterval = debounceInterval
        self._localText = State(initialValue: text.wrappedValue)
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(colors.textMuted)

            TextField("SEARCH...", text: $localText)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(colors.text)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .onChange(of: localText) { newValue in
                    debounceSearch(newValue)
                }

            if !localText.isEmpty {
                Button {
                    localText = ""
                    text = ""
                    debounceTask?.cancel()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(colors.surface)
                        .frame(width: 24, height: 24)
                        .background(colors.textMuted)
                }
            }
        }
        .padding(12)
        .background(colors.surface)
        .overlay(Rectangle().stroke(colors.borderStrong, lineWidth: 2))
        .shadow(color: colors.shadow, radius: 0, x: 2, y: 2)
    }

    private func debounceSearch(_ query: String) {
        debounceTask?.cancel()

        debounceTask = Task {
            do {
                try await Task.sleep(nanoseconds: UInt64(debounceInterval * 1_000_000_000))

                await MainActor.run {
                    text = query
                }
            } catch {
                // Cancelled - that's fine
            }
        }
    }
}
```

---

## PHASE 6: Main Screens (REVISED)

### Task 6.1: MainView with iOS 15 Compatibility

**Views/MainView.swift**

Key fix: `onChange` uses single-parameter closure for iOS 15 compatibility.

```swift
import SwiftUI

struct MainView: View {
    @EnvironmentObject private var store: TermStore
    @StateObject private var speechRecognizer = SpeechRecognizer()

    @State private var showBrowse = false
    @State private var showNoMatch = false
    @State private var lastSearchQuery = ""

    var colors: AppColors {
        AppColors.forTheme(store.theme)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                colors.bg.ignoresSafeArea()

                VStack(spacing: 0) {
                    headerView
                    contentArea
                    controlsView
                    browseButton
                }
            }
            .navigationDestination(isPresented: $showBrowse) {
                BrowseView()
                    .environmentObject(store)
            }
            .onAppear {
                if speechRecognizer.authorizationStatus == .notDetermined {
                    speechRecognizer.requestAuthorization()
                }
            }
            // iOS 15 compatible syntax (single parameter)
            .onChange(of: speechRecognizer.transcript) { newValue in
                handleTranscript(newValue)
            }
            .onChange(of: speechRecognizer.isRecording) { isRecording in
                // Clear no-match state when starting new recording
                if isRecording {
                    showNoMatch = false
                }
            }
        }
    }

    // MARK: - Header

    private var headerView: some View {
        HStack {
            // Logo
            HStack(spacing: 8) {
                ZStack {
                    Rectangle()
                        .fill(colors.primary)
                        .frame(width: 32, height: 32)
                        .overlay(Rectangle().stroke(colors.borderStrong, lineWidth: 2))

                    Text("V")
                        .font(.system(size: 16, weight: .black))
                        .foregroundColor(.white)
                }
                .shadow(color: colors.shadow, radius: 0, x: 2, y: 2)

                Text("VWA")
                    .font(.system(size: 20, weight: .black))
                    .foregroundColor(colors.text)
                    .tracking(-1)
            }

            Spacer()

            // Theme toggle
            Button {
                store.theme = store.theme == .dark ? .light : .dark
            } label: {
                Image(systemName: store.theme == .dark ? "sun.max.fill" : "moon.fill")
                    .font(.system(size: 18))
                    .foregroundColor(colors.text)
            }
            .padding(.trailing, 12)

            // Language Toggle
            LanguageToggle(
                language: $store.language,
                colors: colors
            )
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
    }

    // MARK: - Content Area

    private var contentArea: some View {
        ZStack {
            // Default: Term Card
            if let term = store.currentTerm,
               !showNoMatch,
               !speechRecognizer.isRecording,
               speechRecognizer.error == nil,
               store.loadError == nil {
                TermCardView(
                    term: term,
                    language: store.language,
                    colors: colors,
                    currentIndex: store.currentIndex,
                    totalTerms: store.termCount
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            }

            // Listening
            if speechRecognizer.isRecording {
                ListeningIndicator(colors: colors)
                    .padding(.horizontal, 20)
            }

            // Voice error
            if let error = speechRecognizer.error {
                VoiceErrorView(
                    error: error,
                    colors: colors,
                    onRetry: {
                        speechRecognizer.clearError()
                        speechRecognizer.startRecording()
                    },
                    onDismiss: {
                        speechRecognizer.clearError()
                    }
                )
                .padding(.horizontal, 20)
            }

            // No match
            if showNoMatch {
                NoMatchView(
                    searchedTerm: lastSearchQuery,
                    colors: colors,
                    onBrowse: {
                        showNoMatch = false
                        showBrowse = true
                    },
                    onRetry: {
                        showNoMatch = false
                        speechRecognizer.startRecording()
                    }
                )
                .padding(.horizontal, 20)
            }

            // Load error
            if let loadError = store.loadError {
                DataErrorView(
                    message: loadError,
                    colors: colors
                )
                .padding(.horizontal, 20)
            }
        }
        .frame(maxHeight: .infinity)
    }

    // MARK: - Controls

    private var controlsView: some View {
        HStack(spacing: 16) {
            // Previous
            BrutalButton(colors: colors, small: true) {
                store.prevTerm()
            } content: {
                Image(systemName: "backward.fill")
                    .font(.system(size: 18))
                    .foregroundColor(colors.text)
                    .frame(width: 48, height: 48)
                    .background(colors.surface)
                    .overlay(Rectangle().stroke(colors.borderStrong, lineWidth: 2))
            }

            // Microphone
            BrutalButton(colors: colors) {
                if speechRecognizer.isRecording {
                    speechRecognizer.stopRecording()
                } else {
                    showNoMatch = false
                    speechRecognizer.clearError()
                    speechRecognizer.startRecording()
                }
            } content: {
                Image(systemName: speechRecognizer.isRecording ? "stop.fill" : "mic.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.white)
                    .frame(width: 72, height: 72)
                    .background(speechRecognizer.isRecording ? Color.red : colors.primary)
                    .overlay(Rectangle().stroke(colors.borderStrong, lineWidth: 3))
            }

            // Next
            BrutalButton(colors: colors, small: true) {
                store.nextTerm()
            } content: {
                Image(systemName: "forward.fill")
                    .font(.system(size: 18))
                    .foregroundColor(colors.text)
                    .frame(width: 48, height: 48)
                    .background(colors.surface)
                    .overlay(Rectangle().stroke(colors.borderStrong, lineWidth: 2))
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 12)
    }

    // MARK: - Browse Button

    private var browseButton: some View {
        BrutalButton(colors: colors) {
            showBrowse = true
        } content: {
            HStack {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(colors.textMuted)

                Text("BROWSE ALL PHRASES")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(colors.textSecondary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(colors.textMuted)
            }
            .padding(14)
            .frame(maxWidth: .infinity)
            .background(colors.surface)
            .overlay(Rectangle().stroke(colors.borderStrong, lineWidth: 2))
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 24)
    }

    // MARK: - Voice Handling

    private func handleTranscript(_ transcript: String) {
        guard !transcript.isEmpty else { return }

        lastSearchQuery = transcript

        if let match = TermSearch.search(query: transcript, in: store.terms) {
            store.setTerm(match)
            showNoMatch = false
        } else {
            showNoMatch = true
        }
    }
}

// MARK: - Data Error View

struct DataErrorView: View {
    let message: String
    let colors: AppColors

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 32))
                .foregroundColor(colors.primary)

            Text("DATA ERROR")
                .font(.system(size: 12, weight: .heavy, design: .monospaced))
                .foregroundColor(colors.textMuted)
                .tracking(1)

            Text(message)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(colors.text)
                .multilineTextAlignment(.center)

            Text("Try reinstalling the app")
                .font(.system(size: 12))
                .foregroundColor(colors.textSecondary)
        }
        .padding(24)
        .background(colors.surface)
        .overlay(Rectangle().stroke(colors.border, lineWidth: 2))
    }
}
```

---

## Revised File Checklist

```
Core Files:
✓ VwaApp.swift
✓ Models/Category.swift
✓ Models/Language.swift
✓ Models/Theme.swift
✓ Models/SlangTerm.swift
✓ ViewModels/TermStore.swift

Views:
✓ Views/MainView.swift              ← REVISED (iOS 15 onChange)
✓ Views/BrowseView.swift
✓ Views/Components/BrutalButton.swift
✓ Views/Components/LanguageToggle.swift
✓ Views/Components/SearchBar.swift   ← REVISED (debounced)
✓ Views/Components/ProgressIndicator.swift
✓ Views/Components/TermCardView.swift
✓ Views/Components/ListeningIndicator.swift
✓ Views/Components/VoiceErrorView.swift
✓ Views/Components/NoMatchView.swift

Services:
✓ Services/SpeechRecognizer.swift    ← REVISED (silence detection)
✓ Services/TermSearch.swift          ← REVISED (scaled threshold, phonetic)

Theme:
✓ Theme/Colors.swift
✓ Theme/BrutalModifiers.swift

Resources:
✓ Resources/terms.json               ← MUST BE CURATED DATA
```

---

## Revised Time Estimate

| Phase | Time | Notes |
|-------|------|-------|
| Phase 0: Data curation | 2-3 hours | Manual, cannot be skipped |
| Phase 1: Setup | 30 min | |
| Phase 2: Models | 45 min | |
| Phase 3: Theme | 30 min | |
| Phase 4: Services | 1.5 hours | Revised implementations |
| Phase 5: Components | 1.5 hours | |
| Phase 6: Screens | 1.5 hours | |
| Phase 7: App entry | 15 min | |
| Phase 8: Device testing | 1 hour | |
| **Total** | **9-11 hours** | |

---

## Post-MVP Backlog

Items deferred per YAGNI:

1. **Testing** - Add after MVP validates concept
2. **Web admin interface** - For ongoing term management
3. **Localized UI strings** - Spanish/French UI
4. **iPad support**
5. **Analytics**
6. **Favorites/history**
7. **Share functionality**
8. **TTS playback**
9. **Architectural refactor** (split TermStore)

---

## Next Steps

1. **TODAY: Curate 40-50 real Gen Z terms** (spreadsheet → JSON)
2. Copy revised code from this plan
3. Test on physical iOS 15 device
4. Ship to TestFlight
