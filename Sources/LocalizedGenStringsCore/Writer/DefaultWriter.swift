//
//  DefaultWriter.swift
//  LocalizedGenStringsCore
//
//  Created by Timur Shafigullin on 21/07/2019.
//

import Foundation
import PathKit
import XcodeProj

struct DefaultWriter: Writer {

    // MARK: - Nested Types

    private enum Constants {

        // MARK: - Type Properties

        static let generatedFilename = "Localizable.strings"
    }

    // MARK: - Instance Methods

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

    func write(toXcodeProjPath xcodeProjPath: Path,
               translatedStrings: LocalizedStrings,
               lang: String,
               originalStrings: LocalizedStrings) throws {
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
