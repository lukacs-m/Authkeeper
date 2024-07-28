//
//  Item.swift
//  AuthKeeper
//
//  Created by Martin Lukacs on 28/07/2024.
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
