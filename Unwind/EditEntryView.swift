//
//  EditEntryView.swift
//  Unwind
//
//  Created by Dish Eldishnawy on 18.2.2026.
//

import SwiftData
import SwiftUI

/// Wrapper so we can use .sheet(item:) with a DiaryEntry.
struct EditEntryItem: Identifiable {
    let entry: DiaryEntry
    var id: UUID { entry.id }
}

struct EditEntryView: View {
    @Bindable var entry: DiaryEntry
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var audioManager: AudioManager

    @State private var title: String = ""
    @State private var situationField: ContentField?
    @State private var physicalAwarenessField: ContentField?
    @State private var thoughtsField: ContentField?
    @State private var feelingsField: ContentField?
    @State private var actionTakenField: ContentField?
    @State private var selectedSchemaMode: SchemaMode = .healthyAdult
    @State private var wantsField: ContentField?
    @State private var factsField: ContentField?
    @State private var underlyingNeedField: ContentField?
    @State private var resultField: ContentField?
    @State private var needMetChoice: NeedMetChoice = .unsure

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Title", text: $title)
                        .accessibilityLabel("Entry title")
                } header: {
                    Text("Title")
                }

                Section {
                    CircleInputSectionView(field: $situationField, title: "Situation")
                }

                Section {
                    CircleInputSectionView(field: $physicalAwarenessField, title: "Physical Awareness")
                }

                Section {
                    CircleInputSectionView(field: $thoughtsField, title: "Thoughts")
                }

                Section {
                    CircleInputSectionView(field: $feelingsField, title: "Feelings")
                }

                Section {
                    CircleInputSectionView(field: $actionTakenField, title: "Action Taken")
                }

                Section {
                    schemaModePicker
                } header: {
                    Text("Schema Mode")
                }

                Section {
                    CircleInputSectionView(field: $wantsField, title: "Wants")
                }

                Section {
                    CircleInputSectionView(field: $factsField, title: "Facts")
                }

                Section {
                    CircleInputSectionView(field: $underlyingNeedField, title: "Underlying Need")
                }

                Section {
                    CircleInputSectionView(field: $resultField, title: "Result")
                }

                Section {
                    Picker("Was your need met?", selection: $needMetChoice) {
                        ForEach(NeedMetChoice.allCases, id: \.self) { choice in
                            Text(choice.rawValue).tag(choice)
                        }
                    }
                    .pickerStyle(.segmented)
                    .accessibilityLabel("Was your need met?")
                } header: {
                    Text("Was your need met?")
                }
            }
            .navigationTitle("Edit Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveEntry()
                    }
                    .accessibilityLabel("Save changes")
                }
            }
            .onAppear {
                loadEntry()
            }
        }
    }

    private var schemaModePicker: some View {
        Picker("Schema Mode", selection: $selectedSchemaMode) {
            ForEach(SchemaModeCategory.allCases, id: \.rawValue) { category in
                Section(category.rawValue) {
                    ForEach(category.modes) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
            }
        }
        .pickerStyle(.menu)
    }

    private func loadEntry() {
        title = entry.title.isEmpty ? "" : entry.title
        situationField = entry.situation
        physicalAwarenessField = entry.physicalAwareness
        thoughtsField = entry.thoughts
        feelingsField = entry.feelings
        actionTakenField = entry.actionTaken
        selectedSchemaMode = SchemaMode(rawValue: entry.schemaMode) ?? .healthyAdult
        wantsField = entry.wants
        factsField = entry.facts
        underlyingNeedField = entry.underlyingNeed
        resultField = entry.result
        needMetChoice = NeedMetChoice.from(entry.wasNeedMet)
    }

    private func saveEntry() {
        let oldAudioFilenames = Set(entry.audioFilenames)

        entry.title = title.isEmpty ? "Untitled" : title
        entry.schemaMode = selectedSchemaMode.rawValue
        entry.wasNeedMet = needMetChoice.toBool
        entry.situation = situationField
        entry.physicalAwareness = physicalAwarenessField
        entry.thoughts = thoughtsField
        entry.feelings = feelingsField
        entry.actionTaken = actionTakenField
        entry.wants = wantsField
        entry.facts = factsField
        entry.underlyingNeed = underlyingNeedField
        entry.result = resultField

        let newAudioFilenames = Set(entry.audioFilenames)
        for filename in oldAudioFilenames where !newAudioFilenames.contains(filename) {
            audioManager.deleteRecording(filename: filename)
        }

        dismiss()
    }
}
