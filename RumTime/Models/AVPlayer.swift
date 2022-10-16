//
//  AVPlayer.swift
//  RumTime
//
//  Created by James Maguire on 16/10/2022.
//

import Foundation
import AVFoundation

extension AVPlayer {
    static let sharedAlarmPlayer: AVPlayer = {
        guard let url = Bundle.main.url(forResource: "alarm", withExtension: "wav") else { fatalError("Failed to find sound file.") }
        return AVPlayer(url: url)
    }()
}
