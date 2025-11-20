//
//  Logger.swift
//  RumTime
//
//  Created by James Maguire on 20/11/2025.
//

import Foundation
import os.log

/// Centralized logging for the RumTime application.
///
/// Uses Apple's unified logging system for consistent, performant logging
/// across the app. Logs can be viewed in Console.app filtered by subsystem.
enum AppLogger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.jvm986.RumTime"

    static let audio = Logger(subsystem: subsystem, category: "Audio")
    static let persistence = Logger(subsystem: subsystem, category: "Persistence")
    static let timer = Logger(subsystem: subsystem, category: "Timer")
    static let ui = Logger(subsystem: subsystem, category: "UI")
}
