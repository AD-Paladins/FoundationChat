//
//  Color+Extension.swift
//  FoundationChat
//
//  Created by andres paladines on 7/22/25.
//

import SwiftUI

extension Color {
    var light: Color {
        return self.opacity(0.7).blend(with: .white, fraction: 0.3)
    }
    var dark: Color {
        return self.opacity(0.7).blend(with: .black, fraction: 0.3)
    }

    // Blend helper
    func blend(with color: Color, fraction: CGFloat) -> Color {
        // Cannot directly blend in SwiftUI, so use Color interpolation via UIColor
        let uiColor1 = UIColor(self)
        let uiColor2 = UIColor(color)

        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0

        uiColor1.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        uiColor2.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)

        return Color(
            red: Double(r1 + (r2 - r1) * fraction),
            green: Double(g1 + (g2 - g1) * fraction),
            blue: Double(b1 + (b2 - b1) * fraction),
            opacity: Double(a1 + (a2 - a1) * fraction)
        )
    }
}
