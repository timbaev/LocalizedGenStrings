//
//  SequenceExtension.swift
//  LocalizedGenStringsCore
//
//  Created by Timur Shafigullin on 12/08/2019.
//

import Foundation

extension Sequence where Iterator.Element: Hashable {

    // MARK: - Instance Methods

    func intersects<S: Sequence>(with sequence: S) -> Bool where S.Iterator.Element == Iterator.Element {
        let sequenceSet = Set(sequence)

        return self.contains(where: sequenceSet.contains)
    }
}
