//
//  HistoryEditorRows.swift
//  Worthly
//
//  Created by Codex on 2026/06/18.
//

import SwiftUI

struct HistoryEditorMenuRow<MenuContent: View>: View {
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
                HistoryEditorSeparator()
                    .padding(.leading, WorthlySpacing.rowSeparatorWithIcon)
            }
        }
        .buttonStyle(.plain)
    }
}

struct HistoryEditorDateRow: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @Binding var date: Date

    var body: some View {
        DatePicker(
            selection: $date,
            displayedComponents: .date
        ) {
            HStack(spacing: WorthlySpacing.md) {
                Image(systemName: "calendar")
                    .font(.system(size: 20, weight: .regular))
                    .foregroundStyle(.primary)
                    .frame(width: 30)

                Text("Date")
                    .font(.body)
                    .foregroundStyle(.primary)
            }
        }
        .padding(.vertical, dynamicTypeSize.isWorthlyAccessibilitySize ? WorthlySpacing.xs : 0)
        .frame(minHeight: 52)
        .overlay(alignment: .bottom) {
            HistoryEditorSeparator()
                .padding(.leading, WorthlySpacing.rowSeparatorWithIcon)
        }
    }
}

struct HistoryEditorNotesRow: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @Binding var note: String

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: WorthlySpacing.md) {
                Image(systemName: "list.clipboard")
                    .font(.system(size: 20, weight: .regular))
                    .foregroundStyle(.primary)
                    .frame(width: 30)

                Text("Notes")
                    .font(.body)

                Spacer()
            }
            .padding(.vertical, dynamicTypeSize.isWorthlyAccessibilitySize ? WorthlySpacing.xs : 0)
            .frame(minHeight: 52)

            TextField("Optional", text: $note, axis: .vertical)
                .font(.body)
                .lineLimit(1...3)
                .textInputAutocapitalization(.sentences)
                .frame(minHeight: 42, alignment: .topLeading)
        }
    }
}

private struct HistoryEditorSeparator: View {
    var body: some View {
        Rectangle()
            .fill(Color(.separator))
            .frame(height: 0.5)
    }
}
