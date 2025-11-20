//
//  ErrorWrapper.swift
//  RumTime
//
//  Created by James Maguire on 14/10/2022.
//

import Foundation

struct ErrorWrapper: Identifiable {
    let id: UUID
    let error: Error
    let guidance: String
    let retryAction: (() -> Void)?

    init(id: UUID = UUID(), error: Error, guidance: String, retryAction: (() -> Void)? = nil) {
        self.id = id
        self.error = error
        self.guidance = guidance
        self.retryAction = retryAction
    }
}
