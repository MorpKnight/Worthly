//
//  WorthlyAccessibility.swift
//  Worthly
//
//  Created by Codex on 2026/06/17.
//

import SwiftUI

extension DynamicTypeSize {
    var isWorthlyAccessibilitySize: Bool {
        self >= .accessibility1
    }
}

enum WorthlyAccessibleColor {
    static let positive = Color(uiColor: .systemGreen)
    static let negative = Color(uiColor: .systemRed)
    static let accent = Color(uiColor: .systemBlue)
    static let transfer = Color(uiColor: .systemPurple)
    static let food = Color(uiColor: .systemTeal)

    static let liquidAsset = adaptiveColor(
        light: ChartRGB(red: 0, green: 80, blue: 190),
        dark: ChartRGB(red: 126, green: 171, blue: 255),
        highContrastLight: ChartRGB(red: 0, green: 54, blue: 150),
        highContrastDark: ChartRGB(red: 158, green: 194, blue: 255)
    )

    static let investment = adaptiveColor(
        light: ChartRGB(red: 0, green: 106, blue: 100),
        dark: ChartRGB(red: 86, green: 222, blue: 216),
        highContrastLight: ChartRGB(red: 0, green: 78, blue: 74),
        highContrastDark: ChartRGB(red: 128, green: 242, blue: 237)
    )

    private static func adaptiveColor(
        light: ChartRGB,
        dark: ChartRGB,
        highContrastLight: ChartRGB,
        highContrastDark: ChartRGB
    ) -> Color {
        Color(
            uiColor: UIColor { traitCollection in
                let isDark = traitCollection.userInterfaceStyle == .dark
                let isHighContrast = traitCollection.accessibilityContrast == .high
                let rgb: ChartRGB

                switch (isDark, isHighContrast) {
                case (true, true):
                    rgb = highContrastDark
                case (true, false):
                    rgb = dark
                case (false, true):
                    rgb = highContrastLight
                case (false, false):
                    rgb = light
                }

                return UIColor(
                    red: rgb.red,
                    green: rgb.green,
                    blue: rgb.blue,
                    alpha: 1
                )
            }
        )
    }
}

struct ChartRGB {
    let red: CGFloat
    let green: CGFloat
    let blue: CGFloat

    init(red: CGFloat, green: CGFloat, blue: CGFloat) {
        self.red = red / 255
        self.green = green / 255
        self.blue = blue / 255
    }
}
