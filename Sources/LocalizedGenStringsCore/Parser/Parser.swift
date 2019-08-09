//
//  Parser.swift
//  LocalizedGenStrings
//
//  Created by Timur Shafigullin on 16/07/2019.
//  Copyright © 2019 Timbaev. All rights reserved.
//

import Foundation
import PathKit

protocol Parser {

    // MARK: - Instance Methods

    func parseLocalizedStrings(fromPath xcodeProjPath: Path) throws -> LocalizedStrings
}
