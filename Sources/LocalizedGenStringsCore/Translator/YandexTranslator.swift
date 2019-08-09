//
//  YandexTranslator.swift
//  LocalizedGenStringsCore
//
//  Created by Timur Shafigullin on 21/07/2019.
//

import Foundation

struct YandexTranslator: Translator {

    // MARK: - Instance Properties

    func translate(localizedStrings strings: [String], to lang: String, key: String) -> [String]? {
        let body = strings.map { string in
            let escapedValue = string.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""

            return "text=" + escapedValue
        }.joined(separator: "&")

        guard let url = URL(string: "https://translate.yandex.net/api/v1.5/tr.json/translate?lang=\(lang)&key=\(key)") else {
            return nil
        }

        var request = URLRequest(url: url)

        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"

        request.httpBody = body.data(using: .utf8)

        Log.i("Translating to \(lang) language...")

        let taskResult = URLSession.shared.synchronousDataTask(with: request)

        guard let data = taskResult?.data, let response = taskResult?.response as? HTTPURLResponse, taskResult?.error == nil else {
            return nil
        }

        guard (200 ... 299) ~= response.statusCode else {
            Log.w("StatusCode should be 2xx, but is \(response.statusCode)")
            return nil
        }

        guard let translation = try? JSONDecoder().decode(Translation.self, from: data) else {
            Log.w("Bad response from Yandex Translator")
            return nil
        }

        return translation.text
    }
}
