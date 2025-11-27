//
//  TimeView.swift
//  RumTime
//
//  Created by James Maguire on 15/10/2022.
//

import SwiftUI

struct TimeView: View {
    let totalSeconds: Double
    
    var minutes: Int {
        Int(totalSeconds) / 60 % 60
    }
    var seconds: Int {
        Int(totalSeconds) % 60
    }
    var milliseconds: Int {
        let m = Int((totalSeconds.truncatingRemainder(dividingBy: 1) * 100).rounded())
        if m == 100 || m < 0 {
            return 0
        }
        return m
    }
    
    var numWidth: Double = 0.23
    var numSpacing: Double = 0.05
    var puncSpacing: Double = 0.25

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                HStack(spacing: geometry.size.width * numSpacing) {
                    Text(String(format: "%02i", minutes))
                        .font(.system(size: geometry.size.width * numWidth, design: .rounded))
                        .minimumScaleFactor(0.5)
                        .frame(width: geometry.size.width * 0.3)
                    Text(String(format: "%02i", seconds))
                        .font(.system(size: geometry.size.width * numWidth, design: .rounded))
                        .minimumScaleFactor(0.5)
                        .frame(width: geometry.size.width * 0.3)
                    Text(String(format: "%02i", milliseconds))
                        .font(.system(size: geometry.size.width * numWidth, design: .rounded))
                        .minimumScaleFactor(0.5)
                        .frame(width: geometry.size.width * 0.3)
                }
                HStack(spacing: geometry.size.width * puncSpacing) {
                    Text(":")
                        .font(.system(size: geometry.size.width * numWidth, design: .rounded))
                        .minimumScaleFactor(0.5)
                        .frame(width: geometry.size.width * 0.1)
                    Text(".")
                        .font(.system(size: geometry.size.width * numWidth, design: .rounded))
                        .minimumScaleFactor(0.5)
                        .frame(width: geometry.size.width * 0.1)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(timeDescription)
        }
    }

    private var timeDescription: String {
        if minutes > 0 {
            return "\(minutes) minute\(minutes == 1 ? "" : "s"), \(seconds) second\(seconds == 1 ? "" : "s")"
        } else {
            return "\(seconds) second\(seconds == 1 ? "" : "s")"
        }
    }
}

struct TimeView_Previews: PreviewProvider {
    static var previews: some View {
        TimeView(totalSeconds: 0)
            .frame(width:400, height: 300)
    }
}
