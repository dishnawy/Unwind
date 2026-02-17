//
//  NewEntryView.swift
//  Unwind
//
//  Created by Dish Eldishnawy on 18.2.2026.
//

import SwiftData
import SwiftUI

private enum NeedMetChoice: String, CaseIterable {
    case yes = "Yes"
    case no = "No"
    case unsure = "Unsure"

    var toBool: Bool? {
        switch self {
        case .yes: true
        case .no: false
        case .unsure: nil
        }
    }

    static func from(_ value: Bool?) -> NeedMetChoice {
        switch value {
        case true: .yes
        case false: .no
        case nil: .unsure
        }
    }
}

struct NewEntryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var audioManager: AudioManager

    @State private var title = ""
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
            .navigationTitle("New Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveEntry()
                    }
                    .accessibilityLabel("Save entry")
                }
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

    private func saveEntry() {
        var contentFields = DiaryContentFields()
        contentFields.situation = situationField
        contentFields.physicalAwareness = physicalAwarenessField
        contentFields.thoughts = thoughtsField
        contentFields.feelings = feelingsField
        contentFields.actionTaken = actionTakenField
        contentFields.wants = wantsField
        contentFields.facts = factsField
        contentFields.underlyingNeed = underlyingNeedField
        contentFields.result = resultField

        let entry = DiaryEntry(
            date: Date(),
            title: title.isEmpty ? "Untitled" : title,
            schemaMode: selectedSchemaMode.rawValue,
            wasNeedMet: needMetChoice.toBool,
            contentFields: contentFields
        )
        modelContext.insert(entry)
        dismiss()
    }
}

#Preview {
    NewEntryView()
        .modelContainer(for: DiaryEntry.self, inMemory: true)
        .environmentObject(AudioManager())
}
