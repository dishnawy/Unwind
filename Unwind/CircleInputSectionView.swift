//
//  CircleInputSectionView.swift
//  Unwind
//
//  Created by Dish Eldishnawy on 18.2.2026.
//

import SwiftUI

private enum InputMode: String, CaseIterable {
    case write = "Write"
    case record = "Record"
}

/// Reusable card for a diary content field with Write (text) or Record (audio) mode.
/// Provide a binding to a `ContentField` and inject `AudioManager` via environment.
struct CircleInputSectionView: View {
    @Binding var field: ContentField?
    let title: String
    @EnvironmentObject var audioManager: AudioManager

    @State private var inputMode: InputMode = .write
    @FocusState private var isTextFocused: Bool

    private var textBinding: Binding<String> {
        let bound = $field
        return Binding(
            get: {
                guard let f = bound.wrappedValue, !f.isAudio else { return "" }
                return f.content
            },
            set: { newValue in
                bound.wrappedValue = ContentField(isAudio: false, content: newValue)
            }
        )
    }

    private var hasRecording: Bool {
        guard let f = field, f.isAudio else { return false }
        return !f.content.isEmpty
    }

    private var recordingFilename: String? {
        guard hasRecording, let f = field else { return nil }
        return f.content
    }

    private var isThisRecordingPlaying: Bool {
        guard let name = recordingFilename else { return false }
        return audioManager.currentPlaybackFilename == name && audioManager.isPlaying
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            header
            switch inputMode {
            case .write:
                writeModeContent
            case .record:
                recordModeContent
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
        )
        .onChange(of: field?.isAudio) { _, isAudio in
            if isAudio == true {
                inputMode = .record
            }
        }
        .onChange(of: inputMode) { _, newMode in
            if newMode == .write, audioManager.isRecording {
                _ = audioManager.stopRecording()
            }
        }
    }

    private var header: some View {
        HStack {
            Text(title)
                .font(.headline)
                .fontWeight(.medium)
                .foregroundStyle(.primary)
                .accessibilityAddTraits(.isHeader)

            Spacer(minLength: 8)

            Picker("Input type", selection: $inputMode) {
                ForEach(InputMode.allCases, id: \.self) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            .accessibilityLabel("Switch between writing and recording")
            .frame(maxWidth: 140)
        }
    }

    private var writeModeContent: some View {
        TextField(title, text: textBinding, axis: .vertical)
            .textFieldStyle(.plain)
            .lineLimit(3 ... 8)
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color(.secondarySystemBackground))
            )
            .focused($isTextFocused)
            .accessibilityLabel("\(title), text input")
            .accessibilityHint("Double tap to edit")
    }

    private var recordModeContent: some View {
        VStack(spacing: 16) {
            if hasRecording {
                HStack(spacing: 12) {
                    playStopButton
                    deleteButton
                    Spacer(minLength: 0)
                }
                .accessibilityElement(children: .combine)
            }

            recordButton
        }
    }

    private var recordButton: some View {
        Button {
            if audioManager.isRecording {
                if let filename = audioManager.stopRecording() {
                    field = ContentField(isAudio: true, content: filename)
                }
            } else {
                audioManager.requestMicrophonePermission { granted in
                    if granted {
                        _ = audioManager.startRecording()
                    }
                }
            }
        } label: {
            ZStack {
                if audioManager.isRecording {
                    Circle()
                        .fill(Color.red.opacity(0.25))
                        .frame(width: 64, height: 64)
                        .scaleEffect(audioManager.isRecording ? 1.15 : 1.0)
                        .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: audioManager.isRecording)
                }
                Circle()
                    .fill(audioManager.isRecording ? Color.red : Color(.tertiarySystemFill))
                    .frame(width: 56, height: 56)
                Image(systemName: audioManager.isRecording ? "stop.fill" : "mic.fill")
                    .font(.title2)
                    .foregroundStyle(audioManager.isRecording ? .white : .primary)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(audioManager.isRecording ? "Stop recording" : "Start recording")
        .accessibilityHint(audioManager.isRecording ? "Double tap to stop and save" : "Double tap to record")
    }

    private var playStopButton: some View {
        Button {
            if isThisRecordingPlaying {
                audioManager.stopPlayback()
            } else if let name = recordingFilename {
                audioManager.play(filename: name)
            }
        } label: {
            Image(systemName: isThisRecordingPlaying ? "stop.fill" : "play.fill")
                .font(.title2)
                .foregroundStyle(.primary)
                .frame(width: 44, height: 44)
                .background(Circle().fill(Color(.secondarySystemBackground)))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isThisRecordingPlaying ? "Stop playback" : "Play recording")
        .accessibilityHint(isThisRecordingPlaying ? "Double tap to stop" : "Double tap to play")
    }

    private var deleteButton: some View {
        Button {
            guard let name = recordingFilename else { return }
            audioManager.deleteRecording(filename: name)
            field = nil
        } label: {
            Image(systemName: "trash")
                .font(.title2)
                .foregroundStyle(.secondary)
                .frame(width: 44, height: 44)
                .background(Circle().fill(Color(.secondarySystemBackground)))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Delete recording")
        .accessibilityHint("Double tap to remove this recording")
    }
}

// MARK: - Preview

#Preview {
    struct PreviewWrapper: View {
        @State private var field: ContentField? = ContentField(isAudio: false, content: "Sample text")
        var body: some View {
            CircleInputSectionView(field: $field, title: "Physical Awareness")
                .environmentObject(AudioManager())
                .padding()
        }
    }
    return PreviewWrapper()
}
