//
//  WorthlyToolbarIconButton.swift
//  Worthly
//
//  Created by Giovan Christoffel Sihombing on 2026/06/15.
//

import SwiftUI

struct WorthlyToolbarIconButton: View {
    let systemImage: String
    let accessibilityLabel: String
    let size: CGFloat
    let showsCircleBackground: Bool
    let action: () -> Void

    init(
        systemImage: String,
        accessibilityLabel: String,
        size: CGFloat = 44,
        showsCircleBackground: Bool = true,
        action: @escaping () -> Void
    ) {
        self.systemImage = systemImage
        self.accessibilityLabel = accessibilityLabel
        self.size = size
        self.showsCircleBackground = showsCircleBackground
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.title3.weight(.medium))
                .frame(width: size, height: size)
                .background {
                    if showsCircleBackground {
                        Circle()
                            .fill(.ultraThinMaterial)
                    }
                }
        }
        .buttonStyle(.plain)
        .foregroundStyle(.primary)
        .accessibilityLabel(accessibilityLabel)
    }
}

#Preview {
    HStack {
        WorthlyToolbarIconButton(systemImage: "plus", accessibilityLabel: "Add item") {}
        WorthlyToolbarIconButton(
            systemImage: "wallet.pass",
            accessibilityLabel: "Open wallet",
            size: 32,
            showsCircleBackground: false
        ) {}
    }
    .padding()
}
