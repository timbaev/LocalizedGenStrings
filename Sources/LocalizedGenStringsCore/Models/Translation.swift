//
//  Translation.swift
//  LocalizedGenStrings
//
//  Created by Timur Shafigullin on 16/07/2019.
//  Copyright © 2019 Timbaev. All rights reserved.
//

import Foundation

struct Translation: Codable {

    // MARK: - Instance Properties

    let code: Int
    let lang: String
    let text: [String]
}
