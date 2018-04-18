//
//  Item.swift
//  Todoey
//
//  Created by david ladowitz on 4/17/18.
//  Copyright © 2018 LittleCatLabs. All rights reserved.
//

import Foundation

class Item: Codable {
    var title: String
    var done: Bool

    init(title: String, done: Bool) {
        self.title = title
        self.done = done
    }
}
