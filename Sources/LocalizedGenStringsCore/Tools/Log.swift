//
//  ConsoleIO.swift
//  LocalizedGenStrings
//
//  Created by Timur Shafigullin on 16/07/2019.
//  Copyright © 2019 Timbaev. All rights reserved.
//

import Foundation

// MARK: - LogEvent

private enum LogEvent: String {

    // MARK: - Enumeration Cases

    case e = "‼️" // error
    case i = "ℹ️" // info
    case d = "💬" // debug
    case v = "🔬" // verbose
    case w = "⚠️" // warning
    case s = "🔥" // severe
}

// MARK: - OutputType

private enum OutputType {

    // MARK: - Enumeration Cases

    case error
    case standart
}

// MARK: - Log

public class Log {

    // MARK: - Type Properties

    static var dateFormat = "hh:mm:ss"

    static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()

        formatter.dateFormat = Log.dateFormat
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current

        return formatter
    }

    // MARK: - Type Methods

    private class func printLog(_ object: Any, event: LogEvent, to outputType: OutputType = .standart) {
        let body = "\(Log.dateFormatter.string(from: Date())) \(event.rawValue) \(object)"

        switch outputType {
        case .standart:
            print(body)

        case .error:
            fputs(body, stderr)
        }
    }

    // MARK: -

    public class func e(_ object: Any) {
        Log.printLog(object, event: .e)
    }

    public class func d(_ object: Any) {
        Log.printLog(object, event: .d)
    }

    public class func i(_ object: Any) {
        Log.printLog(object, event: .i)
    }

    public class func v(_ object: Any) {
        Log.printLog(object, event: .v)
    }

    public class func w(_ object: Any) {
        Log.printLog(object, event: .w)
    }

    public class func s(_ object: Any) {
        Log.printLog(object, event: .s)
    }
}
