//
//  DefaultWriter.swift
//  LocalizedGenStringsCore
//
//  Created by Timur Shafigullin on 21/07/2019.
//

import Foundation
import PathKit
import XcodeProj

class DefaultWriter: Writer {

    // MARK: - Nested Types

    private enum Constants {

        // MARK: - Type Properties

        static let generatedFilename = "Localizable.strings"

        static let pattern = #"(".*?") = (".*");"#

        static let excludedPaths = ["Pods"]
    }

    // MARK: - Instance Methods

    private func findLocalizedFilePath(in xcodeProjPath: Path, lang: String) throws -> Path? {
        let xcodeproj = try XcodeProj(path: xcodeProjPath)

        guard let mainGroup = xcodeproj.pbxproj.projects.first?.mainGroup else {
            return nil
        }

        guard let mainProjectGroup = mainGroup.children.first(where: { $0.sourceTree == .group }) as? PBXGroup else {
            return nil
        }

        guard let mainProjectPath = try mainProjectGroup.fullPath(sourceRoot: xcodeProjPath.parent()) else {
            return nil
        }

        let enumerator = FileManager.default.enumerator(atPath: mainProjectPath.string)

        while let element = enumerator?.nextObject() as? String {
            if element.hasSuffix("\(lang).lproj") {
                let localizableFilePath = mainProjectPath + Path(element) + Path(Constants.generatedFilename)

                if localizableFilePath.exists, !localizableFilePath.components.intersects(with: Constants.excludedPaths) {
                    return localizableFilePath
                }
            }
        }

        return nil
    }

    private func readLocalizedStrings(from filePath: Path) throws -> [String: String] {
        var content: String = try filePath.read()

        let regex = try NSRegularExpression(pattern: Constants.pattern, options: .caseInsensitive)

        let matches = regex.matches(in: content, options: [], range: NSRange(location: 0, length: content.utf16.count))

        var fileLocalizedStrings: [String: String] = [:]

        matches.forEach { match in
            if let localizedStringRange = Swift.Range(match.range(at: 1), in: content), let valueRange = Swift.Range(match.range(at: 2), in: content) {
                let localizedString = String(content[localizedStringRange])
                let value = String(content[valueRange])

                fileLocalizedStrings[localizedString] = value
            }
        }

        return fileLocalizedStrings
    }

    private func merge(localizedStrings: LocalizedStrings, into localizedFilePath: Path) throws {
        let fileLocalizedStrings = try self.readLocalizedStrings(from: localizedFilePath)

        var content = localizedStrings.codeStrings.reduce("") { result, string in
            return "\(result)\(string) = \(fileLocalizedStrings[string] ?? string);\n"
        }

        content = localizedStrings.storyboardStrings.reduce(into: content) { result, pair in
            let storyboardNameComment = "/* \(pair.key) */\n"

            let formattedStrings = pair.value.reduce("") { result, string in
                return "\(result)\(string) = \(fileLocalizedStrings[string] ?? string);\n"
            }

            result += storyboardNameComment + formattedStrings
        }

        try localizedFilePath.write(content)
    }

    private func merge(translatedLocalizedStrings: LocalizedStrings, originalLocalizedStrings: LocalizedStrings, into localizedFilePath: Path) throws {
        let fileLocalizedStrings = try self.readLocalizedStrings(from: localizedFilePath)

        var content = translatedLocalizedStrings.codeStrings.enumerated().reduce("") { result, enumerator in
            let originalString = originalLocalizedStrings.codeStrings[enumerator.offset]

            return "\(result)\(originalString) = \(fileLocalizedStrings[originalString] ?? enumerator.element);\n"
        }

        content = translatedLocalizedStrings.storyboardStrings.enumerated().reduce(into: content) { result, enumerator in
            let storyboardNameComment = "/* \(enumerator.element.key) */\n"

            let formattedStrings = enumerator.element.value.enumerated().reduce("") { result, valueEnumerator in
                if let originalStoryboardStrings = originalLocalizedStrings.storyboardStrings[enumerator.element.key] {
                    let originalString = originalStoryboardStrings[valueEnumerator.offset]

                    return "\(result)\(originalString) = \(fileLocalizedStrings[originalString] ?? valueEnumerator.element);\n"
                } else {
                    return ""
                }
            }

            result += storyboardNameComment + formattedStrings
        }

        try localizedFilePath.write(content)
    }

    // MARK: -

    private func write(content: String, toXcodeProjPath xcodeProjPath: Path, lang: String = "en") throws {
        let xcodeproj = try XcodeProj(path: xcodeProjPath)

        guard let mainGroup = xcodeproj.pbxproj.projects.first?.mainGroup else {
            return
        }

        guard let mainProjectGroup = mainGroup.children.first(where: { $0.sourceTree == .group }) as? PBXGroup else {
            return
        }

        guard let mainProjectPath = try mainProjectGroup.fullPath(sourceRoot: xcodeProjPath.parent()) else {
            return
        }

        let localizableFolderPath = mainProjectPath + Path("\(lang).lproj")
        let localizableFilePath = localizableFolderPath + Path(Constants.generatedFilename)

        do {
            if !localizableFolderPath.exists {
                try localizableFolderPath.mkpath()
            }

            try localizableFilePath.write(content, encoding: .utf8)
        } catch {
            Log.e(error)
            throw error
        }

        do {
            let localizableGroup: PBXVariantGroup

            if let existsLocalizableGroup = mainProjectGroup.group(named: Constants.generatedFilename) as? PBXVariantGroup {
                localizableGroup = existsLocalizableGroup
            } else {
                localizableGroup = try mainProjectGroup.addVariantGroup(named: Constants.generatedFilename, options: .withoutFolder).first!
            }

            try localizableGroup.addFile(at: localizableFilePath, sourceRoot: xcodeProjPath.parent())

            try xcodeproj.pbxproj.nativeTargets.filter { $0.dependencies.isEmpty }.forEach { nativeTarget in
                _ = try nativeTarget.buildPhases.first(where: { $0.type() == .resources })?.add(file: localizableGroup)
            }
        } catch {
            Log.e(error)
            throw error
        }

        try xcodeproj.write(path: xcodeProjPath)
    }

    // MARK: - Writer

    func write(toXcodeProjPath xcodeProjPath: Path, localizedStrings: LocalizedStrings) throws {
        if let localizableFilePath = try self.findLocalizedFilePath(in: xcodeProjPath, lang: "en") {
            try self.merge(localizedStrings: localizedStrings, into: localizableFilePath)
        } else {
            var content = localizedStrings.codeStrings.reduce("") { result, string in
                return "\(result)\(string) = \(string);\n"
            }

            content = localizedStrings.storyboardStrings.reduce(into: content) { result, pair in
                let storyboardNameComment = "/* \(pair.key) */\n"

                let formattedStrings = pair.value.reduce("") { result, string in
                    return "\(result)\(string) = \(string);\n"
                }

                result += storyboardNameComment + formattedStrings
            }

            try self.write(content: content, toXcodeProjPath: xcodeProjPath)
        }
    }

    func write(toXcodeProjPath xcodeProjPath: Path,
               translatedStrings: LocalizedStrings,
               lang: String,
               originalStrings: LocalizedStrings) throws {
        if let localizableFilePath = try self.findLocalizedFilePath(in: xcodeProjPath, lang: lang) {
            try self.merge(translatedLocalizedStrings: translatedStrings, originalLocalizedStrings: originalStrings, into: localizableFilePath)
        } else {
            var content = translatedStrings.codeStrings.enumerated().reduce("") { result, enumerator in
                return "\(result)\(originalStrings.codeStrings[enumerator.offset]) = \(enumerator.element);\n"
            }

            content = translatedStrings.storyboardStrings.enumerated().reduce(into: content) { result, enumerator in
                let storyboardNameComment = "/* \(enumerator.element.key) */\n"

                let formattedStrings = enumerator.element.value.enumerated().reduce("") { result, valueEnumerator in
                    if let originalStoryboardStrings = originalStrings.storyboardStrings[enumerator.element.key] {
                        return "\(result)\(originalStoryboardStrings[valueEnumerator.offset]) = \(enumerator.element);\n"
                    } else {
                        return ""
                    }
                }

                result += storyboardNameComment + formattedStrings
            }

            try self.write(content: content, toXcodeProjPath: xcodeProjPath, lang: lang)
        }
    }
}
