//
//  URLSessionExtension.swift
//  LocalizedGenStringsCore
//
//  Created by Timur Shafigullin on 21/07/2019.
//

import Foundation

extension URLSession {

    // MARK: - Instance Methods

    func synchronousDataTask(with urlRequest: URLRequest) -> (data: Data?, response: URLResponse?, error: Error?)? {
        var data: Data?
        var response: URLResponse?
        var error: Error?

        let semaphore = DispatchSemaphore(value: 0)

        let dataTask = self.dataTask(with: urlRequest, completionHandler: {
            data = $0
            response = $1
            error = $2

            semaphore.signal()
        })

        dataTask.resume()

        let timeoutResult = semaphore.wait(timeout: .distantFuture)

        switch timeoutResult {
        case .success:
            return (data, response, error)

        case .timedOut:
            return nil
        }
    }
}
