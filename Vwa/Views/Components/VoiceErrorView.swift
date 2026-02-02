import SwiftUI

struct VoiceErrorView: View {
    let error: SpeechRecognizer.SpeechError
    let colors: AppColors
    let onRetry: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: errorIcon)
                .font(.system(size: 32))
                .foregroundColor(colors.primary)

            Text(error.errorDescription ?? "An error occurred")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(colors.text)
                .multilineTextAlignment(.center)

            HStack(spacing: 12) {
                if error.requiresSettings {
                    Button("Open Settings") {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(colors.primary)
                }

                Button("Try Again") {
                    onRetry()
                }
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(colors.primary)
                .overlay(Rectangle().stroke(colors.borderStrong, lineWidth: 2))
            }
        }
        .padding(20)
        .background(colors.surface)
        .overlay(Rectangle().stroke(colors.border, lineWidth: 2))
    }

    private var errorIcon: String {
        switch error {
        case .notAuthorized, .microphonePermissionDenied:
            return "mic.slash"
        case .noSpeechDetected:
            return "ear.trianglebadge.exclamationmark"
        default:
            return "exclamationmark.triangle"
        }
    }
}
