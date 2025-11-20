//
//  AVPlayer.swift
//  RumTime
//
//  Created by James Maguire on 16/10/2022.
//

import Foundation
import AVFoundation
import os

extension AVPlayer {
    static let sharedAlarmPlayer: AVPlayer = {
        guard let url = Bundle.main.url(forResource: "alarm", withExtension: "wav") else {
            AppLogger.audio.error("Failed to find alarm.wav in bundle. Timer will be silent.")
            return AVPlayer()
        }
        return AVPlayer(url: url)
    }()
}
