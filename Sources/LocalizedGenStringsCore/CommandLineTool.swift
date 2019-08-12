import Foundation
import Commander
import PathKit

public final class CommandLineTool {

    // MARK: - Nested Types

    enum Error: Swift.Error, CustomStringConvertible {

        // MARK: - Enumeration Cases

        case xcodeProjectNotFound
        case failedParse
        case failedSave
        case failedTranlsation

        // MARK: - Instance Properties

        var description: String {
            switch self {
            case .xcodeProjectNotFound:
                return "Xcode project (.xcodeproj) not found"

            case .failedParse:
                return "Failed to parse localized strings"

            case .failedSave:
                return "Failed to save localized strings"

            case .failedTranlsation:
                return "Failed translation"
            }
        }
    }

    // MARK: -

    private enum Constants {

        // MARK: - Type Properties

        static let excludedPaths = ["Pods"]
    }

    // MARK: - Instance Properties

    private let arguments: [String]

    // MARK: -

    private var parser: Parser = DefaultParser()
    private var writer: Writer = DefaultWriter()
    private var translator: Translator = YandexTranslator()

    // MARK: - Initializers

    public init(arguments: [String] = CommandLine.arguments) {
        self.arguments = arguments
    }

    init(arguments: [String] = CommandLine.arguments, parser: Parser, writer: Writer, translator: Translator) {
        self.arguments = arguments
        self.parser = parser
        self.writer = writer
        self.translator = translator
    }

    // MARK: - Instance Methods

    private func run(path: String, lang: String? = nil, key: String? = nil) throws {
        let enumerator = FileManager.default.enumerator(atPath: path)

        let filePaths = (enumerator?.allObjects as? [String])?.filter { filePath in
            let components = filePath.components(separatedBy: "/")

            return !components.intersects(with: Constants.excludedPaths)
        }

        guard let xcodeprojPath = filePaths?.first(where: { $0.contains(".xcodeproj") }) else {
            throw Error.xcodeProjectNotFound
        }

        let fullPath = Path(path) + Path(xcodeprojPath)

        guard let localizedStrings = try? self.parser.parseLocalizedStrings(fromPath: fullPath) else {
            throw Error.failedParse
        }

        do {
            try self.writer.write(toXcodeProjPath: fullPath, localizedStrings: localizedStrings)
        } catch {
            Log.e(error)
            throw Error.failedSave
        }

        guard let lang = lang, let translatorKey = key else {
            return
        }

        Log.i("Translating code localized strings...")

        guard let translatedCodeStrings = self.translator.translate(localizedStrings: localizedStrings.codeStrings, to: lang, key: translatorKey) else {
            throw Error.failedTranlsation
        }

        var translatedStoryboardStrings: [String: [String]] = [:]

        localizedStrings.storyboardStrings.forEach { pair in
            Log.i("Translating \(pair.key) localized strings...")

            translatedStoryboardStrings[pair.key] = self.translator.translate(localizedStrings: pair.value, to: lang, key: translatorKey)
        }

        let translatedLocalizedStrings = LocalizedStrings(codeStrings: translatedCodeStrings, storyboardStrings: translatedStoryboardStrings)

        do {
            try self.writer.write(toXcodeProjPath: fullPath, translatedStrings: translatedLocalizedStrings, lang: lang, originalStrings: localizedStrings)
        } catch {
            Log.e(error)
            throw Error.failedSave
        }
    }

    // MARK: -

    public func run() throws {
        command(
            Option("path", default: FileManager.default.currentDirectoryPath, description: "Path to Xcode project"),
            Option("lang", default: "", description: "Language code for translation"),
            Option("key", default: "", description: "API key for Yandex Translator")
        ) { path, lang, key in
            do {
                if !lang.isEmpty, !key.isEmpty {
                    Log.i("Options: --path \(path) --lang \(lang) --key \(key)")

                    try self.run(path: path, lang: lang, key: key)
                } else {
                    Log.i("Options: --path \(path)")

                    try self.run(path: path)
                }
            } catch {
                Log.e("Whoops! An error occurred: \(error)")
            }
        }.run()
    }
}
