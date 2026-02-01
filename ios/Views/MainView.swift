import SwiftUI
import Speech

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
        NavigationView {
            ZStack {
                colors.bg.ignoresSafeArea()

                VStack(spacing: 0) {
                    headerView
                    contentArea
                    controlsView
                    browseButton
                }

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
            .onAppear {
                if speechRecognizer.authorizationStatus == .notDetermined {
                    speechRecognizer.requestAuthorization()
                }
            }
            .onChangeCompat(of: speechRecognizer.transcript) { newValue in
                handleTranscript(newValue)
            }
            .onChangeCompat(of: speechRecognizer.isRecording) { isRecording in
                if isRecording {
                    showNoMatch = false
                }
            }
        }
        .navigationViewStyle(.stack)
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
