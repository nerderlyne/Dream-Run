//
//  Item.swift
//  Dream Again
//
//  Created by Shivanshi Tyagi on 13/09/26.
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
