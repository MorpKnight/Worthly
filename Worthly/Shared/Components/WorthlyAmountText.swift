//
//  WorthlyAmountText.swift
//  Worthly
//
//  Created by Giovan Christoffel Sihombing on 2026/06/15.
//

import SwiftUI

struct WorthlyAmountText: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let text: String
    let font: Font
    let color: Color
    let minimumScaleFactor: CGFloat

    init(
        text: String,
        font: Font = .body,
        color: Color = .primary,
        minimumScaleFactor: CGFloat = 0.82
    ) {
        self.text = text
        self.font = font
        self.color = color
        self.minimumScaleFactor = minimumScaleFactor
    }

    var body: some View {
        Text(text)
            .font(font)
            .foregroundStyle(color)
            .monospacedDigit()
            .lineLimit(dynamicTypeSize.isWorthlyAccessibilitySize ? nil : 1)
            .minimumScaleFactor(dynamicTypeSize.isWorthlyAccessibilitySize ? 1 : minimumScaleFactor)
            .multilineTextAlignment(.leading)
    }
}

#Preview {
    WorthlyAmountText(
        text: "Rp 999.999.999,99",
        font: .title2.weight(.bold),
        minimumScaleFactor: 0.78
    )
    .padding()
}
