//
//  ThemePicker.swift
//  RumTime
//
//  Created by James Maguire on 14/10/2022.
//

import SwiftUI

struct ThemePicker: View {
    let title: String
    @Binding var selection: Theme
    
    var body: some View {
        Picker(title, selection: $selection) {
            ForEach(Theme.allCases) { theme in
                ThemeView(theme: theme)
                    .tag(theme)
            }
        }
    }
}

struct ThemePicker_Previews: PreviewProvider {
    static var previews: some View {
        ThemePicker(title: "Theme", selection: .constant(.seafoam))
    }
}
