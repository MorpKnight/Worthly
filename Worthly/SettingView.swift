//
//  SettingView.swift
//  Worthly
//
//  Created by Giovan Christoffel Sihombing on 2026/06/15.
//

import SwiftUI

struct SettingView: View {
    let store: FinanceStore

    @State private var showsResetConfirmation = false

    init(store: FinanceStore = FinanceStore()) {
        self.store = store
    }

    private var dummyDataBinding: Binding<Bool> {
        Binding(
            get: { store.isDummyDataEnabled },
            set: { store.setDummyDataEnabled($0) }
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("Preferences")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 14)

                VStack(spacing: 0) {
                    WorthlyDisclosureRow(
                        title: "Currency",
                        value: "IDR",
                        rowMinHeight: 52,
                        horizontalPadding: 16,
                        separatorLeadingInset: 16,
                        valueUsesMonospacedDigits: false
                    )

                    WorthlyDisclosureRow(
                        title: "Categories",
                        value: "Default",
                        rowMinHeight: 52,
                        horizontalPadding: 16,
                        separatorLeadingInset: 16,
                        valueUsesMonospacedDigits: false
                    )
                }
                .padding(.bottom, 12)

                Text("Data and app")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 14)

                VStack(spacing: 0) {
                    SettingToggleRow(
                        title: "Use dummy data",
                        isOn: dummyDataBinding
                    )

                    WorthlyDisclosureRow(
                        title: "Local data only",
                        rowMinHeight: 52,
                        horizontalPadding: 16,
                        separatorLeadingInset: 16,
                        valueUsesMonospacedDigits: false,
                        showsChevron: false
                    )

                    Button {
                        showsResetConfirmation = true
                    } label: {
                        WorthlyDisclosureRow(
                            title: "Reset local data",
                            titleColor: .red,
                            rowMinHeight: 52,
                            horizontalPadding: 16,
                            separatorLeadingInset: 16,
                            valueUsesMonospacedDigits: false
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.top, 8)
            .padding(.bottom, 40)
        }
        .background(Color(.systemBackground))
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
        .confirmationDialog(
            "Reset local data?",
            isPresented: $showsResetConfirmation,
            titleVisibility: .visible
        ) {
            Button("Reset local data", role: .destructive) {
                store.resetToEmptyData()
            }

            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This removes your local Worthly data and starts setup again.")
        }
    }
}

private struct SettingToggleRow: View {
    let title: String
    @Binding var isOn: Bool

    var body: some View {
        Toggle(isOn: $isOn) {
            Text(title)
                .font(.body)
                .foregroundStyle(.primary)
        }
        .padding(.horizontal, 16)
        .frame(minHeight: 52)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color(.separator))
                .frame(height: 0.5)
                .padding(.leading, 16)
        }
    }
}

#Preview {
    NavigationStack {
        SettingView()
    }
}
