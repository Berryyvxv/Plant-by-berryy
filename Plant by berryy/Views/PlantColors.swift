import SwiftUI
import UIKit

// Colors for the plants page. The dark values are sampled from the design;
// the light values are a matching light palette. The system picks one automatically.
enum PlantColors {
    static let background = Color(light: 0xFFFFFF, dark: 0x000000)
    static let headerDivider = Color(light: 0xE5E5EA, dark: 0x181819)
    static let rowDivider = Color(light: 0xE5E5EA, dark: 0x222224)

    static let progressTrack = Color(light: 0xE5E5EA, dark: 0x262626)
    static let progressFill = Color(light: 0x59A68F, dark: 0x59A68F)

    static let uncheckedCircle = Color(light: 0x979797, dark: 0x979797)
    static let checkedCircle = Color(light: 0x28E0A8, dark: 0x28E0A8)

    static let locationText = Color(light: 0x6E6E73, dark: 0x808080)
    static let wateredName = Color(light: 0x8E8E93, dark: 0x989898)

    static let chipBackground = Color(light: 0xF0F0F5, dark: 0x18181D)
    static let lightChipText = Color(light: 0x8A8420, dark: 0xCCC785)
    static let waterChipText = Color(light: 0x1A7A8C, dark: 0xCAF3FB)

    static let addButton = Color(light: 0x28745D, dark: 0x28745D)

    // The system red in each appearance; the dark value is the one sampled from the design
    static let deleteButton = Color(light: 0xFF383C, dark: 0xFF4245)
}

private extension Color {
    // 0xRRGGBB for each appearance; resolved by the system when drawing, so it follows theme changes
    init(light: UInt32, dark: UInt32) {
        self.init(uiColor: UIColor { traits in
            UIColor(hex: traits.userInterfaceStyle == .dark ? dark : light)
        })
    }
}

private extension UIColor {
    convenience init(hex: UInt32) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: 1
        )
    }
}
