//
//  AudioManager.swift
//  Unwind
//
//  Created by Dish Eldishnawy on 18.2.2026.
//

import AVFoundation
import Combine
import Foundation

/// Manages microphone permission, recording, and playback of audio for diary entries.
/// Recordings are stored in the app's Document Directory. Use the returned filename
/// in `ContentField(isAudio: true, content: filename)` when saving a DiaryEntry.
final class AudioManager: NSObject, ObservableObject {
    // MARK: - Published state

    @Published private(set) var isRecording = false
    @Published private(set) var isPlaying = false
    @Published private(set) var currentPlaybackFilename: String?

    // MARK: - Private

    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    private var currentRecordingURL: URL?

    private let fileExtension = "m4a"
    private let recordingsSubdirectory = "UnwindRecordings"

    /// Directory where recordings are stored (Document Directory / UnwindRecordings).
    var recordingsDirectory: URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dir = documents.appendingPathComponent(recordingsSubdirectory, isDirectory: true)
        if !FileManager.default.fileExists(atPath: dir.path) {
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true, attributes: [.posixPermissions: 0o700])
        }
        return dir
    }

    // MARK: - Microphone permission

    /// Requests microphone access. Call before starting a recording.
    /// - Parameter completion: Called on main queue with true if authorized (or already granted).
    func requestMicrophonePermission(completion: @escaping (Bool) -> Void) {
        if #available(iOS 17.0, *) {
            switch AVAudioApplication.shared.recordPermission {
            case .granted:
                DispatchQueue.main.async { completion(true) }
            case .denied:
                DispatchQueue.main.async { completion(false) }
            case .undetermined:
                AVAudioApplication.requestRecordPermission { allowed in
                    DispatchQueue.main.async { completion(allowed) }
                }
            @unknown default:
                DispatchQueue.main.async { completion(false) }
            }
        } else {
            let session = AVAudioSession.sharedInstance()
            switch session.recordPermission {
            case .granted:
                DispatchQueue.main.async { completion(true) }
            case .denied:
                DispatchQueue.main.async { completion(false) }
            case .undetermined:
                session.requestRecordPermission { allowed in
                    DispatchQueue.main.async { completion(allowed) }
                }
            @unknown default:
                DispatchQueue.main.async { completion(false) }
            }
        }
    }

    /// Current microphone permission status.
    var microphonePermissionStatus: AVAudioSession.RecordPermission {
        if #available(iOS 17.0, *) {
            switch AVAudioApplication.shared.recordPermission {
            case .granted: return .granted
            case .denied: return .denied
            default: return .undetermined
            }
        } else {
            return AVAudioSession.sharedInstance().recordPermission
        }
    }

    // MARK: - Recording

    /// Configures the audio session and starts recording. Creates a new file with a unique name.
    /// - Returns: `true` if recording started; `false` if session setup or start failed.
    @discardableResult
    func startRecording() -> Bool {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetoothHFP])
            try session.setActive(true)
        } catch {
            return false
        }

        let filename = "\(UUID().uuidString).\(fileExtension)"
        let url = recordingsDirectory.appendingPathComponent(filename)

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: url, settings: settings)
            audioRecorder?.record()
            currentRecordingURL = url
            isRecording = true
            return true
        } catch {
            return false
        }
    }

    /// Stops the current recording and returns the filename to store in the diary entry.
    /// - Returns: The filename (e.g. `"UUID.m4a"`) to save in `ContentField(content:)`, or `nil` if no recording was in progress.
    func stopRecording() -> String? {
        guard let recorder = audioRecorder, let url = currentRecordingURL else { return nil }
        recorder.stop()
        audioRecorder = nil
        currentRecordingURL = nil
        isRecording = false
        return url.lastPathComponent
    }

    // MARK: - Playback

    /// Returns the full file URL for a filename previously returned from `stopRecording()`.
    func url(forFilename filename: String) -> URL {
        recordingsDirectory.appendingPathComponent(filename)
    }

    /// Plays the recording identified by `filename` (the value stored in `ContentField.content`).
    /// - Parameter filename: Filename returned from `stopRecording()` (e.g. `"UUID.m4a"`).
    func play(filename: String) {
        let url = self.url(forFilename: filename)
        play(url: url, filename: filename)
    }

    /// Plays the recording at the given URL (e.g. from `url(forFilename:)`).
    func play(url: URL, filename: String? = nil) {
        stopPlayback()
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)
        } catch {
            return
        }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.play()
            isPlaying = true
            currentPlaybackFilename = filename ?? url.lastPathComponent
        } catch {
            isPlaying = false
            currentPlaybackFilename = nil
        }
    }

    /// Stops playback if active.
    func stopPlayback() {
        audioPlayer?.stop()
        audioPlayer = nil
        isPlaying = false
        currentPlaybackFilename = nil
    }

    /// Pauses playback. Call `resumePlayback()` to continue.
    func pausePlayback() {
        audioPlayer?.pause()
        isPlaying = false
    }

    /// Resumes playback after `pausePlayback()`.
    func resumePlayback() {
        audioPlayer?.play()
        isPlaying = true
    }

    /// Deletes the recording file from disk. Call before clearing the filename from your model.
    /// - Parameter filename: The filename returned from `stopRecording()` (e.g. `"UUID.m4a"`).
    func deleteRecording(filename: String) {
        if currentPlaybackFilename == filename {
            stopPlayback()
        }
        let url = self.url(forFilename: filename)
        try? FileManager.default.removeItem(at: url)
    }
}

// MARK: - AVAudioPlayerDelegate

extension AudioManager: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async { [weak self] in
            self?.stopPlayback()
        }
    }
}
