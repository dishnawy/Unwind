//
//  SchemaMode.swift
//  Unwind
//
//  Created by Dish Eldishnawy on 18.2.2026.
//

import Foundation

/// Schema therapy mode categories for diary entries.
enum SchemaMode: String, CaseIterable, Codable, Identifiable {
    // MARK: - Child Modes
    case vulnerable = "Vulnerable"
    case angry = "Angry"

    // MARK: - Coping Modes
    /// Freeze
    case compliantSurrenderer = "Compliant Surrenderer"
    /// Avoidance
    case detachedProtector = "Detached Protector"
    case avoidantProtector = "Avoidant Protector"
    case angryProtector = "Angry Protector"
    case detachedSelfSoother = "Detached Self-Soother"
    /// Overcompensator
    case suspiciousOverController = "Suspicious Over-Controller"
    case bullyAndAttack = "Bully and Attack"
    case selfAggrandizer = "Self-Aggrandizer"
    case perfectionism = "Perfectionism"
    case pleasing = "Pleasing"

    // MARK: - Parent Modes
    case punitiveParent = "Punitive Parent"
    case demandingParent = "Demanding Parent"

    // MARK: - Healthy Mode
    case healthyAdult = "Healthy Adult"
    case happyChild = "Happy Child"

    var id: String { rawValue }

    var category: SchemaModeCategory {
        switch self {
        case .vulnerable, .angry:
            return .child
        case .compliantSurrenderer, .detachedProtector, .avoidantProtector, .angryProtector,
             .detachedSelfSoother, .suspiciousOverController, .bullyAndAttack, .selfAggrandizer,
             .perfectionism, .pleasing:
            return .coping
        case .punitiveParent, .demandingParent:
            return .parent
        case .healthyAdult, .happyChild:
            return .healthy
        }
    }
}

enum SchemaModeCategory: String, CaseIterable {
    case child = "Child Modes"
    case coping = "Coping Modes"
    case parent = "Parent Modes"
    case healthy = "Healthy Mode"

    var modes: [SchemaMode] {
        SchemaMode.allCases.filter { $0.category == self }
    }
}
