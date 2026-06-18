//
//  AssetEditorRows.swift
//  Worthly
//
//  Created by Codex on 2026/06/18.
//

import SwiftUI

struct AssetEditorTextFieldRow: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let icon: String
    let title: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        HStack(spacing: WorthlySpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .regular))
                .foregroundStyle(.primary)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: WorthlySpacing.xxs) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                TextField(placeholder, text: $text)
                    .font(.body.weight(.semibold))
                    .monospacedDigit()
                    .keyboardType(keyboardType)
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled()
                    .lineLimit(dynamicTypeSize.isWorthlyAccessibilitySize ? 2 : 1)
                    .minimumScaleFactor(dynamicTypeSize.isWorthlyAccessibilitySize ? 1 : 0.78)
            }
        }
        .padding(.vertical, dynamicTypeSize.isWorthlyAccessibilitySize ? WorthlySpacing.xs : 0)
        .frame(minHeight: 58)
        .overlay(alignment: .bottom) {
            AssetEditorSeparator()
                .padding(.leading, WorthlySpacing.rowSeparatorWithIcon)
        }
    }
}

struct AssetEditorMenuRow<MenuContent: View>: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let icon: String
    let title: String
    let value: String
    let menuContent: MenuContent

    init(
        icon: String,
        title: String,
        value: String,
        @ViewBuilder menuContent: () -> MenuContent
    ) {
        self.icon = icon
        self.title = title
        self.value = value
        self.menuContent = menuContent()
    }

    var body: some View {
        Menu {
            menuContent
        } label: {
            HStack(spacing: WorthlySpacing.md) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .regular))
                    .foregroundStyle(.primary)
                    .frame(width: 30)

                if dynamicTypeSize.isWorthlyAccessibilitySize {
                    VStack(alignment: .leading, spacing: WorthlySpacing.xxs) {
                        Text(title)
                            .font(.body)
                            .foregroundStyle(.primary)

                        Text(value)
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    Text(title)
                        .font(.body)
                        .foregroundStyle(.primary)

                    Text(value)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer(minLength: WorthlySpacing.sm)

                Image(systemName: "chevron.up.chevron.down")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, dynamicTypeSize.isWorthlyAccessibilitySize ? WorthlySpacing.xs : 0)
            .frame(minHeight: 52)
            .overlay(alignment: .bottom) {
                AssetEditorSeparator()
                    .padding(.leading, WorthlySpacing.rowSeparatorWithIcon)
            }
        }
        .buttonStyle(.plain)
    }
}

struct AssetEditorDateRow: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let icon: String
    let title: String
    @Binding var date: Date

    var body: some View {
        DatePicker(
            selection: $date,
            displayedComponents: .date
        ) {
            HStack(spacing: WorthlySpacing.md) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .regular))
                    .foregroundStyle(.primary)
                    .frame(width: 30)

                Text(title)
                    .font(.body)
                    .foregroundStyle(.primary)
            }
        }
        .padding(.vertical, dynamicTypeSize.isWorthlyAccessibilitySize ? WorthlySpacing.xs : 0)
        .frame(minHeight: 52)
        .overlay(alignment: .bottom) {
            AssetEditorSeparator()
                .padding(.leading, WorthlySpacing.rowSeparatorWithIcon)
        }
    }
}

private struct AssetEditorSeparator: View {
    var body: some View {
        Rectangle()
            .fill(Color(.separator))
            .frame(height: 0.5)
    }
}
