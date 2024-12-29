//
//  StorageItems.swift
//  Solstice
//
//  Created by Milind Contractor on 28/12/24.
//

import Foundation

struct Todo: Identifiable, Codable {
    var id = UUID()
    var task: String
    var priority: Int
    var completed: Bool = false
}
