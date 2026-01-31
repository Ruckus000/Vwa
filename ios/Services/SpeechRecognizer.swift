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
