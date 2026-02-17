//
//  ContentView.swift
//  Unwind
//
//  Created by Dish Eldishnawy on 18.2.2026.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \DiaryEntry.date, order: .reverse) private var entries: [DiaryEntry]
    @StateObject private var audioManager = AudioManager()
    @State private var showNewEntry = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                List {
                    ForEach(entries) { entry in
                        DiaryRowView(entry: entry)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    deleteEntry(entry)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                }
                .overlay {
                    if entries.isEmpty {
                        ContentUnavailableView {
                            Label("No entries yet", systemImage: "book.closed")
                        } description: {
                            Text("Take a deep breath. Log your first circle when you are ready.")
                        }
                    }
                }
            }
            .navigationTitle("Diary")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showNewEntry = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                    .accessibilityLabel("New entry")
                }
            }
            .sheet(isPresented: $showNewEntry) {
                NewEntryView()
                    .environmentObject(audioManager)
            }
        }
    }

    private func deleteEntry(_ entry: DiaryEntry) {
        for filename in entry.audioFilenames {
            audioManager.deleteRecording(filename: filename)
        }
        modelContext.delete(entry)
    }
}

// MARK: - Row

private struct DiaryRowView: View {
    let entry: DiaryEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(entry.title.isEmpty ? "Untitled" : entry.title)
                .font(.headline)
                .foregroundStyle(.primary)

            HStack(spacing: 8) {
                Text(entry.date, format: Date.FormatStyle(date: .abbreviated, time: .shortened))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text(entry.schemaMode)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(schemaModeCapsuleColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(schemaModeCapsuleColor.opacity(0.2)))
            }
        }
        .padding(.vertical, 4)
    }

    private var schemaModeCapsuleColor: Color {
        let mode = SchemaMode(rawValue: entry.schemaMode)
        switch mode?.category {
        case .child: return .orange
        case .coping: return .purple
        case .parent: return .red
        case .healthy: return .green
        case nil: return .secondary
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: DiaryEntry.self, inMemory: true)
}
