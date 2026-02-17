//
//  DiaryEntry.swift
//  Unwind
//
//  Created by Dish Eldishnawy on 18.2.2026.
//

import Foundation
import SwiftData

@Model
final class DiaryEntry {
    var id: UUID
    var date: Date
    var title: String
    var schemaMode: String
    var wasNeedMet: Bool?

    /// Persisted as encoded `DiaryContentFields` so SwiftData can store the value.
    private var contentFieldsData: Data?

    /// Content fields (situation, physicalAwareness, thoughts, etc.). Encode/decode via `contentFieldsData`.
    var contentFields: DiaryContentFields {
        get {
            guard let data = contentFieldsData,
                  let decoded = try? JSONDecoder().decode(DiaryContentFields.self, from: data) else {
                return DiaryContentFields()
            }
            return decoded
        }
        set {
            contentFieldsData = try? JSONEncoder().encode(newValue)
        }
    }

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        title: String = "",
        schemaMode: String,
        wasNeedMet: Bool? = nil,
        contentFields: DiaryContentFields = DiaryContentFields()
    ) {
        self.id = id
        self.date = date
        self.title = title
        self.schemaMode = schemaMode
        self.wasNeedMet = wasNeedMet
        self.contentFieldsData = try? JSONEncoder().encode(contentFields)
    }
}

// MARK: - Content field accessors

extension DiaryEntry {
    var situation: ContentField? {
        get { contentFields.situation }
        set { var f = contentFields; f.situation = newValue; contentFields = f }
    }
    var physicalAwareness: ContentField? {
        get { contentFields.physicalAwareness }
        set { var f = contentFields; f.physicalAwareness = newValue; contentFields = f }
    }
    var thoughts: ContentField? {
        get { contentFields.thoughts }
        set { var f = contentFields; f.thoughts = newValue; contentFields = f }
    }
    var feelings: ContentField? {
        get { contentFields.feelings }
        set { var f = contentFields; f.feelings = newValue; contentFields = f }
    }
    var actionTaken: ContentField? {
        get { contentFields.actionTaken }
        set { var f = contentFields; f.actionTaken = newValue; contentFields = f }
    }
    var wants: ContentField? {
        get { contentFields.wants }
        set { var f = contentFields; f.wants = newValue; contentFields = f }
    }
    var facts: ContentField? {
        get { contentFields.facts }
        set { var f = contentFields; f.facts = newValue; contentFields = f }
    }
    var underlyingNeed: ContentField? {
        get { contentFields.underlyingNeed }
        set { var f = contentFields; f.underlyingNeed = newValue; contentFields = f }
    }
    var result: ContentField? {
        get { contentFields.result }
        set { var f = contentFields; f.result = newValue; contentFields = f }
    }

    /// All audio filenames stored in this entry’s content fields (for cleanup when deleting).
    var audioFilenames: [String] {
        let fields: [ContentField?] = [
            situation, physicalAwareness, thoughts, feelings, actionTaken,
            wants, facts, underlyingNeed, result,
        ]
        return fields.compactMap { f in
            guard let f = f, f.isAudio, !f.content.isEmpty else { return nil }
            return f.content
        }
    }
}
