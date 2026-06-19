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
            WorthlyToolbarIconLabel(
                systemImage: systemImage,
                size: size,
                showsCircleBackground: showsCircleBackground
            )
        }
        .buttonStyle(.plain)
        .foregroundStyle(.primary)
        .accessibilityLabel(accessibilityLabel)
    }
}

struct WorthlyToolbarIconLabel: View {
    let systemImage: String
    let size: CGFloat
    let showsCircleBackground: Bool

    init(
        systemImage: String,
        size: CGFloat = 44,
        showsCircleBackground: Bool = true
    ) {
        self.systemImage = systemImage
        self.size = size
        self.showsCircleBackground = showsCircleBackground
    }

    var body: some View {
        Group {
            if showsCircleBackground {
                icon
                    .glassEffect(.regular.interactive(), in: Circle())
            } else {
                icon
            }
        }
        .contentShape(Circle())
    }

    private var icon: some View {
        Image(systemName: systemImage)
            .font(.title3.weight(.medium))
            .frame(width: size, height: size)
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
