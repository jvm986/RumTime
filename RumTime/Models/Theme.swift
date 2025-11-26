//
//  Theme.swift
//  RumTime
//
//  Created by James Maguire on 14/10/2022.
//

import SwiftUI

enum Theme: String, CaseIterable, Identifiable, Codable {
    case ash
    case biscaygreen
    case chive
    case classicblue
    case coralpink
    case grapecompote
    case lark
    case navyblazer
    case orangepeel
    case saffron

    var accentColor: Color {
        switch self {
        case .ash, .biscaygreen, .coralpink, .lark, .orangepeel, .saffron: return .black
        case .chive, .classicblue, .navyblazer, .grapecompote: return .white
        }
    }
    var mainColor: Color {
        Color(rawValue)
    }
    var name: String {
        rawValue.capitalized
    }
    var id: String {
        name
    }
}
