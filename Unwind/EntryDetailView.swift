//
//  EntryDetailView.swift
//  Unwind
//
//  Created by Dish Eldishnawy on 18.2.2026.
//

import SwiftData
import SwiftUI

struct EntryDetailView: View {
    @Bindable var entry: DiaryEntry
    @EnvironmentObject var audioManager: AudioManager

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                headerBlock

                contentBlocks

                needMetBlock
            }
            .padding(20)
            .padding(.bottom, 32)
        }
        .background(
            LinearGradient(
                colors: [
                    Color(.systemGroupedBackground),
                    Color(.systemGroupedBackground).opacity(0.95)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Header

    private var headerBlock: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(entry.title.isEmpty ? "Untitled" : entry.title)
                .font(.title)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 10) {
                Label(
                    entry.date.formatted(date: .abbreviated, time: .shortened),
                    systemImage: "calendar"
                )
                .font(.subheadline)
                .foregroundStyle(.secondary)

                schemaModeCapsule
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
        )
    }

    private var schemaModeCapsule: some View {
        Text(entry.schemaMode)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundStyle(schemaModeColor)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Capsule().fill(schemaModeColor.opacity(0.18)))
    }

    private var schemaModeColor: Color {
        let mode = SchemaMode(rawValue: entry.schemaMode)
        switch mode?.category {
        case .child: return .orange
        case .coping: return .purple
        case .parent: return .red
        case .healthy: return .green
        case nil: return .secondary
        }
    }

    // MARK: - Content fields

    private var contentBlocks: some View {
        VStack(alignment: .leading, spacing: 16) {
            detailField("Situation", entry.situation)
            detailField("Physical Awareness", entry.physicalAwareness)
            detailField("Thoughts", entry.thoughts)
            detailField("Feelings", entry.feelings)
            detailField("Action Taken", entry.actionTaken)
            detailField("Wants", entry.wants)
            detailField("Facts", entry.facts)
            detailField("Underlying Need", entry.underlyingNeed)
            detailField("Result", entry.result)
        }
    }

    @ViewBuilder
    private func detailField(_ label: String, _ field: ContentField?) -> some View {
        guard let field, !field.content.isEmpty else { return }

        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .tracking(0.6)

            if field.isAudio {
                HStack(spacing: 12) {
                    Button {
                        if audioManager.currentPlaybackFilename == field.content, audioManager.isPlaying {
                            audioManager.stopPlayback()
                        } else {
                            audioManager.play(filename: field.content)
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: audioManager.currentPlaybackFilename == field.content && audioManager.isPlaying ? "stop.fill" : "play.fill")
                                .font(.body)
                            Text(audioManager.currentPlaybackFilename == field.content && audioManager.isPlaying ? "Stop" : "Play recording")
                                .font(.subheadline)
                        }
                        .foregroundStyle(.primary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(Capsule().fill(Color(.tertiarySystemFill)))
                    }
                    .buttonStyle(.plain)
                }
            } else {
                Text(field.content)
                    .font(.body)
                    .foregroundStyle(.primary)
                    .lineSpacing(6)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
        )
    }

    // MARK: - Was your need met

    private var needMetBlock: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Was your need met?")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .tracking(0.6)

            Text(needMetText)
                .font(.body)
                .foregroundStyle(.primary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
        )
    }

    private var needMetText: String {
        switch entry.wasNeedMet {
        case true: return "Yes"
        case false: return "No"
        case nil: return "Unsure"
        }
    }
}

#Preview {
    NavigationStack {
        EntryDetailView(entry: DiaryEntry(
            title: "Evening reflection",
            schemaMode: SchemaMode.healthyAdult.rawValue,
            wasNeedMet: true,
            contentFields: DiaryContentFields(
                situation: ContentField(isAudio: false, content: "Had a difficult conversation with a colleague about boundaries."),
                thoughts: ContentField(isAudio: false, content: "I noticed I was in Healthy Adult mode by the end.")
            )
        ))
        .environmentObject(AudioManager())
    }
    .modelContainer(for: DiaryEntry.self, inMemory: true)
}
