//
//  Helpers.swift
//  RumTime
//
//  Created by James Maguire on 17/10/2022.
//

import SwiftUI

extension Binding where Value == Bool {
    var not: Binding<Value> {
        Binding<Value>(
            get: { !self.wrappedValue },
            set: { self.wrappedValue = !$0 }
        )
    }
}
