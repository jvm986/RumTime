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
        let calculatedAngle = timeRemaining / Double(startingTime) * 360.0
        if calculatedAngle < 2 {
            return Angle(degrees: 0)
        }
        // Cap at 358 degrees to always leave a 2-degree gap, even when at or over starting time
        return Angle(degrees: min(358.0, calculatedAngle - 2))
    }
    
    private var startAngle: Angle {
        if timeRemaining > Double(startingTime) {
            return Angle(degrees: (timeRemaining / Double(startingTime) * 360.0))
        }
        return Angle(degrees: 0)
    }

    func path(in rect: CGRect) -> Path {
        let diameter = min(rect.size.width, rect.size.height)
        let radius = diameter / 2.0
        let center = CGPoint(x: rect.midX, y: rect.midY)
        return Path { path in
            path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        }
    }
}
