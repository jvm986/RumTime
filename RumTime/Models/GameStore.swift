//
//  GameStore.swift
//  RumTime
//
//  Created by James Maguire on 14/10/2022.
//

import Foundation
import SwiftUI

class GameStore: ObservableObject {
    @Published var games: [Game] = []
    
    private static func fileURL() throws -> URL {
        try FileManager.default.url(for: .documentDirectory,
                                       in: .userDomainMask,
                                       appropriateFor: nil,
                                       create: false)
            .appendingPathComponent("games.data")
    }
    
    static func load() async throws -> [Game] {
        try await withCheckedThrowingContinuation { continuation in
            load { result in
                switch result {
                case .failure(let error):
                    continuation.resume(throwing: error)
                case .success(let games):
                    continuation.resume(returning: games)
                }
            }
        }
    }
    
    static func load(completion: @escaping @Sendable (Result<[Game], Error>) -> Void) {
        DispatchQueue.global(qos: .background).async {
            do {
                let fileURL = try fileURL()
                guard let file = try? FileHandle(forReadingFrom: fileURL) else {
                    DispatchQueue.main.async {
                        completion(.success([]))
                    }
                    return
                }
                let games = try JSONDecoder().decode([Game].self, from: file.availableData)
                DispatchQueue.main.async {
                    completion(.success(games))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    @discardableResult
    static func save(games: [Game]) async throws -> Int {
        try await withCheckedThrowingContinuation { continuation in
            save(games: games) { result in
                switch result {
                case .failure(let error):
                    continuation.resume(throwing: error)
                case .success(let gamesSaved):
                    continuation.resume(returning: gamesSaved)
                }
            }
        }
    }
    
    static func save(games: [Game], completion: @escaping @Sendable (Result<Int, Error>) -> Void) {
        DispatchQueue.global(qos: .background).async {
            do {
                let data = try JSONEncoder().encode(games)
                let outfile = try fileURL()
                try data.write(to: outfile)
                DispatchQueue.main.async {
                    completion(.success(games.count))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
}

