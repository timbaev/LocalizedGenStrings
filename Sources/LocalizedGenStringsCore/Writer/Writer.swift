//
//  Writer.swift
//  LocalizedGenStringsCore
//
//  Created by Timur Shafigullin on 21/07/2019.
//

import Foundation
import PathKit

protocol Writer {

    // MARK: - Instance Methods

    func write(toXcodeProjPath xcodeProjPath: Path, localizedStrings: LocalizedStrings) throws

    func write(toXcodeProjPath xcodeProjPath: Path,
               translatedStrings: LocalizedStrings,
               lang: String,
               originalStrings: LocalizedStrings) throws
}
