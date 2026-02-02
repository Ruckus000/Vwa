import SwiftUI
import Speech
import UIKit

// MARK: - iOS 15/17 onChange Compatibility
extension View {
    @ViewBuilder
    func onChangeCompat<V: Equatable>(of value: V, perform action: @escaping (V) -> Void) -> some View {
        if #available(iOS 17.0, *) {
            self.onChange(of: value) { _, newValue in
                action(newValue)
            }
        } else {
            self.onChange(of: value, perform: action)
        }
    }
}

// MARK: - Voice State

enum VoiceState: Equatable {
    case idle
    case listening
    case result
}

// MARK: - Main View

struct MainView: View {
    @EnvironmentObject private var store: TermStore
    @StateObject private var speechRecognizer = SpeechRecognizer()

    @State private var voiceState: VoiceState = .idle
    @State private var showBrowse = false
    @State private var browseDidSelectTerm = false
    @State private var lastSearchQuery = ""
    @State private var showNoMatch = false

    var colors: AppColors {
        AppColors.forTheme(store.theme)
    }

    var body: some View {
        NavigationView {
            ZStack {
                colors.bg.ignoresSafeArea()

                VStack(spacing: 0) {
                    headerView

                    switch voiceState {
                    case .idle:
                        idleView
                    case .listening:
                        listeningView
                    case .result:
                        resultView
                    }
                }

                // Hidden NavigationLink for iOS 15 compatibility
                NavigationLink(
                    destination: BrowseView(didSelectTerm: $browseDidSelectTerm)
                        .environmentObject(store),
                    isActive: $showBrowse
                ) {
                    EmptyView()
                }
                .hidden()
            }
            .onAppear {
                if speechRecognizer.authorizationStatus == .notDetermined {
                    speechRecognizer.requestAuthorization()
                }
            }
            .onChangeCompat(of: speechRecognizer.transcript) { handleTranscript($0) }
            .onChangeCompat(of: speechRecognizer.isRecording) { handleRecordingChange($0) }
            .onChangeCompat(of: showBrowse) { handleBrowseDismiss($0) }
        }
        .navigationViewStyle(.stack)
    }

    // MARK: - State Transitions

    private func transition(to newState: VoiceState) {
        guard newState != voiceState else { return }
        voiceState = newState
        announceStateChange(to: newState)
    }

    private func announceStateChange(to state: VoiceState) {
        let announcement: String
        switch state {
        case .idle:
            announcement = "Ready. Tap microphone and speak a slang term."
        case .listening:
            announcement = "Listening. Tap to cancel."
        case .result:
            announcement = showNoMatch ? "No match found." : "Result found."
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            UIAccessibility.post(notification: .announcement, argument: announcement)
        }
    }

    // MARK: - Event Handlers

    private func handleMicTap() {
        switch voiceState {
        case .idle:
            guard speechRecognizer.isAvailable else {
                // Speech recognition unavailable - could show alert here
                return
            }
            showNoMatch = false
            speechRecognizer.clearError()
            speechRecognizer.startRecording()
            transition(to: .listening)

        case .listening:
            speechRecognizer.stopRecording()
            transition(to: .idle)

        case .result:
            showNoMatch = false
            speechRecognizer.clearError()
            speechRecognizer.startRecording()
            transition(to: .listening)
        }
    }

    private func handleRecordingChange(_ isRecording: Bool) {
        if !isRecording && voiceState == .listening {
            transition(to: .result)
        }
    }

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

    private func handleBrowseDismiss(_ isShowing: Bool) {
        if !isShowing && browseDidSelectTerm {
            showNoMatch = false
            transition(to: .result)
            browseDidSelectTerm = false
        }
    }

    private func resetToIdle() {
        showNoMatch = false
        speechRecognizer.clearError()
        transition(to: .idle)
    }

    // MARK: - Header

    private var headerView: some View {
        HStack(alignment: .center) {
            // Logo + Wordmark (tap to toggle theme)
            Button {
                store.theme = store.theme == .dark ? .light : .dark
            } label: {
                HStack(spacing: .space2) {
                    ZStack {
                        Rectangle()
                            .fill(colors.primary)
                            .frame(width: .space8, height: .space8)
                            .overlay(Rectangle().stroke(colors.borderStrong, lineWidth: .borderStandard))

                        Text("V")
                            .font(.system(size: 16, weight: .black))
                            .foregroundColor(.white)
                    }
                    .brutalShadowSm(colors)

                    Text("VWA")
                        .font(.typeHeading)
                        .foregroundColor(colors.text)
                        .tracking(.trackingNormal)
                }
            }
            .accessibilityLabel("VWA. Tap to toggle theme. Current: \(store.theme == .dark ? "dark" : "light")")
            .accessibilityHint("Switches between light and dark mode")

            Spacer()

            // Language Toggle
            LanguageToggle(
                language: $store.language,
                colors: colors
            )
        }
        .frame(height: 44)  // Constrain header height
        .padding(.horizontal, .space5)
        .padding(.vertical, .space2)
    }

    // MARK: - Idle View

    private var idleView: some View {
        VStack(spacing: 0) {
            Spacer()

            // Dormant waveform
            WaveformView(colors: colors, isActive: false)
                .padding(.bottom, .space6)

            // Hero mic button (88x88)
            Button(action: handleMicTap) {
                Image(systemName: "mic.fill")
                    .font(.system(size: 36))
                    .foregroundColor(.white)
                    .frame(width: 88, height: 88)
                    .background(colors.primary)
                    .overlay(Rectangle().stroke(colors.borderStrong, lineWidth: .borderHeavy))
            }
            .buttonStyle(BrutalButtonStyle(colors: colors, small: false))
            .accessibilityLabel("Start voice search")
            .accessibilityHint("Tap and speak a slang term to look up")
            .padding(.bottom, .space5)

            // Prompt text
            Text("TAP AND SPEAK")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(colors.textSecondary)
                .tracking(1.5)

            Text("\(store.termCount) SLANG TERMS AVAILABLE")
                .font(.typeMono)
                .foregroundColor(colors.textMuted)
                .padding(.top, .space2)

            Spacer()

            // Browse CTA (full width)
            browseCTA(dimmed: false)
                .padding(.horizontal, .space5)
                .padding(.bottom, .space4)
        }
    }

    // MARK: - Listening View

    private var listeningView: some View {
        VStack(spacing: 0) {
            Spacer()

            // Active waveform
            WaveformView(colors: colors, isActive: true)
                .padding(.bottom, .space6)

            // Pause/cancel button with glow
            Button(action: handleMicTap) {
                Image(systemName: "pause.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.white)
                    .frame(width: 88, height: 88)
                    .background(colors.primary)
                    .overlay(Rectangle().stroke(colors.accent, lineWidth: .borderHeavy))
            }
            .buttonStyle(BrutalButtonStyle(colors: colors, small: false))
            .shadow(color: colors.primary.opacity(0.4), radius: 8, x: 0, y: 0)
            .accessibilityLabel("Cancel voice search")
            .padding(.bottom, .space5)

            // Status text
            Text("LISTENING...")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(colors.primary)
                .tracking(1.5)

            Text("TAP TO CANCEL")
                .font(.typeMono)
                .foregroundColor(colors.textMuted)
                .padding(.top, .space2)

            Spacer()

            // Browse CTA (dimmed)
            browseCTA(dimmed: true)
                .padding(.horizontal, .space5)
                .padding(.bottom, .space4)
        }
    }

    // MARK: - Result View

    private var resultView: some View {
        VStack(spacing: 0) {
            // Reset button (top-right)
            HStack {
                Spacer()
                Button(action: resetToIdle) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(colors.textMuted)
                        .frame(width: 32, height: 32)
                }
                .accessibilityLabel("Return to start")
                .accessibilityHint("Go back to the main voice search screen")
            }
            .padding(.horizontal, .space5)
            .padding(.top, .space2)

            // Content
            if let error = speechRecognizer.error {
                VoiceErrorView(
                    error: error,
                    colors: colors,
                    onRetry: handleMicTap,
                    onDismiss: resetToIdle
                )
                .padding(.horizontal, .space5)
            } else if showNoMatch {
                NoMatchView(
                    searchedTerm: lastSearchQuery,
                    colors: colors,
                    onBrowse: { showBrowse = true },
                    onRetry: handleMicTap
                )
                .padding(.horizontal, .space5)
            } else if let term = store.currentTerm {
                TermCardView(
                    term: term,
                    language: store.language,
                    colors: colors
                )
                .padding(.horizontal, .space5)
            }

            Spacer(minLength: .space3)

            // Bottom action bar
            HStack(spacing: .space3) {
                // Browse (secondary)
                BrutalButton(colors: colors) {
                    showBrowse = true
                } content: {
                    HStack(spacing: .space2) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 15))
                        Text("BROWSE")
                            .font(.system(size: 12, weight: .bold))
                    }
                    .foregroundColor(colors.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(colors.surface)
                    .overlay(Rectangle().stroke(colors.borderStrong, lineWidth: .borderStandard))
                }
                .accessibilityLabel("Browse all terms")

                // Try Another (primary)
                BrutalButton(colors: colors) {
                    handleMicTap()
                } content: {
                    HStack(spacing: .space2) {
                        Image(systemName: "mic.fill")
                            .font(.system(size: 15))
                        Text("TRY ANOTHER")
                            .font(.system(size: 12, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(colors.primary)
                    .overlay(Rectangle().stroke(colors.borderStrong, lineWidth: .borderStandard))
                }
                .accessibilityLabel("Try another voice search")
            }
            .padding(.horizontal, .space5)
            .padding(.bottom, .space4)
        }
    }

    // MARK: - Browse CTA Helper

    @ViewBuilder
    private func browseCTA(dimmed: Bool) -> some View {
        BrutalButton(colors: colors) {
            if !dimmed { showBrowse = true }
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
            .overlay(Rectangle().stroke(dimmed ? colors.border : colors.borderStrong, lineWidth: .borderStandard))
        }
        .opacity(dimmed ? 0.3 : 1.0)
        .disabled(dimmed)
        .accessibilityLabel("Browse all phrases")
        .accessibilityHint(dimmed ? "Disabled while listening" : "View searchable list of all slang terms")
    }
}

// MARK: - Data Error View

struct DataErrorView: View {
    let message: String
    let colors: AppColors

    var body: some View {
        VStack(spacing: .space4) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 32))
                .foregroundColor(colors.primary)

            Text("DATA ERROR")
                .font(.system(size: 12, weight: .heavy, design: .monospaced))
                .foregroundColor(colors.textMuted)
                .tracking(.trackingLoose)

            Text(message)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(colors.text)
                .multilineTextAlignment(.center)

            Text("Try reinstalling the app")
                .font(.system(size: 12))
                .foregroundColor(colors.textSecondary)
        }
        .padding(.space6)
        .background(colors.surface)
        .overlay(Rectangle().stroke(colors.border, lineWidth: .borderStandard))
    }
}
