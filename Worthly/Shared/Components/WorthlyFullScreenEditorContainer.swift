//
//  WorthlyFullScreenEditorContainer.swift
//  Worthly
//
//  Created by Codex on 2026/06/18.
//

import SwiftUI

struct WorthlyFullScreenEditorContainer<Content: View>: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let title: String
    let leadingSystemImage: String
    let leadingAccessibilityLabel: String
    let saveAccessibilityLabel: String
    let saveIsEnabled: Bool
    let onLeading: () -> Void
    let onSave: () -> Void
    let content: Content

    init(
        title: String,
        leadingSystemImage: String = "xmark",
        leadingAccessibilityLabel: String,
        saveAccessibilityLabel: String,
        saveIsEnabled: Bool,
        onLeading: @escaping () -> Void,
        onSave: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.leadingSystemImage = leadingSystemImage
        self.leadingAccessibilityLabel = leadingAccessibilityLabel
        self.saveAccessibilityLabel = saveAccessibilityLabel
        self.saveIsEnabled = saveIsEnabled
        self.onLeading = onLeading
        self.onSave = onSave
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                HStack {
                    WorthlyEditorCircleButton(
                        systemImage: leadingSystemImage,
                        accessibilityLabel: leadingAccessibilityLabel,
                        style: .secondary,
                        action: onLeading
                    )

                    Spacer()

                    WorthlyEditorCircleButton(
                        systemImage: "checkmark",
                        accessibilityLabel: saveAccessibilityLabel,
                        style: saveIsEnabled ? .primary : .disabled,
                        action: onSave
                    )
                    .disabled(!saveIsEnabled)
                }

                Text(title)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .lineLimit(dynamicTypeSize.isWorthlyAccessibilitySize ? 2 : 1)
                    .minimumScaleFactor(dynamicTypeSize.isWorthlyAccessibilitySize ? 1 : 0.82)
                    .padding(.horizontal, WorthlySpacing.sheetTitleHorizontal)
            }
            .padding(.top, WorthlySpacing.md)
            .padding(.horizontal, WorthlySpacing.xs)

            ScrollView {
                content
                    .padding(.top, WorthlySpacing.sheetContentTop)
                    .padding(.horizontal, WorthlySpacing.xs)
                    .padding(.bottom, WorthlySpacing.sheetContentBottom)
            }
            .scrollDismissesKeyboard(.interactively)
            .scrollIndicators(.hidden)
        }
        .padding(.horizontal, WorthlySpacing.sheetHorizontal)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

struct WorthlyEditorCircleButton: View {
    enum Style {
        case primary
        case secondary
        case disabled
    }

    let systemImage: String
    let accessibilityLabel: String
    let style: Style
    let action: () -> Void

    private var background: Color {
        switch style {
        case .primary:
            WorthlyAccessibleColor.accent
        case .secondary, .disabled:
            Color(.systemGray5)
        }
    }

    private var foreground: Color {
        switch style {
        case .primary:
            .white
        case .secondary:
            .primary
        case .disabled:
            .secondary
        }
    }

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(foreground)
                .frame(width: 44, height: 44)
                .background(background, in: Circle())
        }
        .opacity(style == .disabled ? 0.7 : 1)
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
    }
}

#Preview {
    WorthlyFullScreenEditorContainer(
        title: "Add Asset",
        leadingAccessibilityLabel: "Cancel",
        saveAccessibilityLabel: "Save asset",
        saveIsEnabled: true,
        onLeading: {},
        onSave: {}
    ) {
        Text("Form content")
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
