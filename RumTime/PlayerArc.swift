//
//  PlayerArc.swift
//  RumTime
//
//  Created by James Maguire on 09/10/2022.
//

import SwiftUI

struct PlayerArc: Shape {
    let startingTime: Int
    let timeRemaining: Double

    private var endAngle: Angle {
        if timeRemaining / Double(startingTime) * 360.0 < 2 {
            return Angle(degrees: 0)
        }
        return Angle(degrees: (timeRemaining / Double(startingTime) * 360.0) - 2)
    }
    
    private var startAngle: Angle {
        if timeRemaining > Double(startingTime) {
            return Angle(degrees: (timeRemaining / Double(startingTime) * 360.0))
        }
        return Angle(degrees: 0)
    }

    func path(in rect: CGRect) -> Path {
        let diameter = min(rect.size.width, rect.size.height) - 24.0
        let radius = diameter / 2.0
        let center = CGPoint(x: rect.midX, y: rect.midY)
        return Path { path in
            path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        }
    }
}
