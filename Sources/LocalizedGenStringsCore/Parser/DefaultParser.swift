//
//  DefaultParser.swift
//  LocalizedGenStrings
//
//  Created by Timur Shafigullin on 16/07/2019.
//  Copyright © 2019 Timbaev. All rights reserved.
//

import Foundation
import PathKit
import XcodeProj
import IBDecodable

struct DefaultParser: Parser {

    // MARK: - Nested Types

    private enum Constants {

        // MARK: - Type Properties

        static let pattern = #"("[^"]*?").localized\(\)"#

        static let tempStringsFilename = "temp.strings"
    }

    // MARK: - Parser

    func parseLocalizedStrings(fromPath xcodeProjPath: Path) throws -> LocalizedStrings {
        let xcodeproj = try XcodeProj(path: xcodeProjPath)

        var localizedStrings: [String] = []
        var storyboardLocalizedStrings: [String: [String]] = [:]

        try xcodeproj.pbxproj.nativeTargets.forEach { nativeTarget in
            try nativeTarget.sourceFiles().forEach { sourceFile in
                guard let path = sourceFile.path, path.hasSuffix("swift") else {
                    return
                }

                guard let filePath = try sourceFile.fullPath(sourceRoot: xcodeProjPath.parent()) else {
                    return
                }

                let content = try filePath.read(.utf8)
                let regex = try NSRegularExpression(pattern: Constants.pattern, options: .caseInsensitive)

                let matches = regex.matches(in: content, options: [], range: NSRange(location: 0, length: content.utf16.count))

                matches.forEach { match in
                    if let localizedStringRange = Swift.Range(match.range(at: 1), in: content) {
                        let localizedString = String(content[localizedStringRange])

                        if !localizedStrings.contains(localizedString) {
                            localizedStrings.append(localizedString)
                        }
                    }
                }
            }

            try nativeTarget.resourcesBuildPhase()?.files?.forEach { fileReference in
                guard let path = fileReference.file?.path, path.hasSuffix("storyboard") else {
                    return
                }

                guard let filePath = try fileReference.file?.fullPath(sourceRoot: xcodeProjPath.parent()) else {
                    return
                }

                let task = Process()

                task.launchPath = filePath.parent().string
                task.arguments = [path, "--generate-strings-file", Constants.tempStringsFilename]
                task.launch()
                task.waitUntilExit()

                let tempStringFilePath = filePath.parent() + Path(Constants.tempStringsFilename)

                guard let stringsDictionary = NSDictionary(contentsOf: tempStringFilePath.url) as? [String: String] else {
                    return
                }

                stringsDictionary.values.forEach { value in
                    if !localizedStrings.contains(value) {
                        storyboardLocalizedStrings[path, default: []].append(value)
                    }
                }

                try FileManager.default.removeItem(at: tempStringFilePath.url)
            }
        }

        // ibtool Avatar.storyboard --generate-strings-file temp.strings

        return LocalizedStrings(codeStrings: localizedStrings, storyboardStrings: storyboardLocalizedStrings)
    }
}
