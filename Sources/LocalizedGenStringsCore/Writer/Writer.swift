//
//  Writer.swift
//  LocalizedGenStringsCore
//
//  Created by Timur Shafigullin on 21/07/2019.
//

import Foundation
import PathKit

public protocol Writer {

    // MARK: - Instance Methods

    func write(toXcodeProj xcodeProjPath: Path, localizedStrings strings: [String], lang: String, originalStrings: [String]?) throws
}

// MARK: -

extension Writer {

    // MARK: - Instance Methods

    func write(toXcodeProj xcodeProjPath: Path, localizedStrings strings: [String], lang: String = "en", originalStrings: [String]? = nil) throws {
        try self.write(toXcodeProj: xcodeProjPath, localizedStrings: strings, lang: lang, originalStrings: originalStrings)
    }
}
