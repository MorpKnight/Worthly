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
                            title: "Reset demo data",
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
            "Reset demo data?",
            isPresented: $showsResetConfirmation,
            titleVisibility: .visible
        ) {
            Button("Reset demo data", role: .destructive) {
                store.resetToSampleData()
            }

            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This replaces your local Worthly data with the sample dataset.")
        }
    }
}

#Preview {
    NavigationStack {
        SettingView()
    }
}
