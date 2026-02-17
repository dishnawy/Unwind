//
//  Item.swift
//  Unwind
//
//  Created by Dish Eldishnawy on 18.2.2026.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
