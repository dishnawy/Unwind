//
//  ContentField.swift
//  Unwind
//
//  Created by Dish Eldishnawy on 18.2.2026.
//

import Foundation

/// A single content field for diary entries. When `isAudio` is true, `content` holds the local filename.
struct ContentField: Codable, Equatable {
    var isAudio: Bool
    var content: String

    init(isAudio: Bool = false, content: String = "") {
        self.isAudio = isAudio
        self.content = content
    }
}

/// Container for all diary content fields, used for SwiftData persistence via encoding to `Data`.
struct DiaryContentFields: Codable, Equatable {
    var situation: ContentField?
    var physicalAwareness: ContentField?
    var thoughts: ContentField?
    var feelings: ContentField?
    var actionTaken: ContentField?
    var wants: ContentField?
    var facts: ContentField?
    var underlyingNeed: ContentField?
    var result: ContentField?

    init(
        situation: ContentField? = nil,
        physicalAwareness: ContentField? = nil,
        thoughts: ContentField? = nil,
        feelings: ContentField? = nil,
        actionTaken: ContentField? = nil,
        wants: ContentField? = nil,
        facts: ContentField? = nil,
        underlyingNeed: ContentField? = nil,
        result: ContentField? = nil
    ) {
        self.situation = situation
        self.physicalAwareness = physicalAwareness
        self.thoughts = thoughts
        self.feelings = feelings
        self.actionTaken = actionTaken
        self.wants = wants
        self.facts = facts
        self.underlyingNeed = underlyingNeed
        self.result = result
    }
}
