//
//  ContentView.swift
//  Worthly
//
//  Created by Giovan Christoffel Sihombing on 2026/06/15.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase

    @State private var store = FinanceStore()
    @State private var selectedTab: AppTab = .overview

    var body: some View {
        Group {
            if store.dataRecoveryStatus == .unreadable {
                FinanceDataRecoveryView(store: store)
            } else if store.hasCompletedOnboarding {
                TabView(selection: $selectedTab) {
                    ForEach(AppTab.allCases) { tab in
                        NavigationStack {
                            content(for: tab)
                        }
                        .tabItem {
                            tab.label
                        }
                        .tag(tab)
                    }
                }
                .tabViewStyle(.sidebarAdaptable)
                .tint(WorthlyAccessibleColor.accent)
            } else {
                OnboardingView(store: store)
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            guard newPhase == .active else {
                return
            }

            store.refreshReferenceDate()
        }
        .alert(
            "Local data restored",
            isPresented: Binding(
                get: { store.dataRecoveryStatus == .recoveredFromBackup },
                set: { isPresented in
                    if !isPresented {
                        store.dismissDataRecoveryNotice()
                    }
                }
            )
        ) {
            Button("OK") {
                store.dismissDataRecoveryNotice()
            }
        } message: {
            Text("Worthly couldn’t read the latest local file, so it restored the most recent backup.")
        }
    }

    @ViewBuilder
    private func content(for tab: AppTab) -> some View {
        switch tab {
        case .overview:
            HomeView(store: store) {
                selectedTab = .planning
            }
        case .planning:
            PlanningView(store: store)
        case .assets:
            AssetView(store: store)
        case .history:
            HistoryView(store: store)
        }
    }
}

private struct FinanceDataRecoveryView: View {
    let store: FinanceStore

    @State private var showsResetConfirmation = false

    var body: some View {
        ScrollView {
            WorthlySummaryCard(padding: WorthlySpacing.md) {
                VStack(alignment: .leading, spacing: WorthlySpacing.md) {
                    Image(systemName: "externaldrive.badge.exclamationmark")
                        .font(.title.weight(.semibold))
                        .foregroundStyle(WorthlyAccessibleColor.negative)
                        .accessibilityHidden(true)

                    Text("Local data needs attention")
                        .font(.title2.weight(.bold))

                    Text("Worthly couldn’t read your saved finance data. The existing files have been left untouched so you can try again before resetting anything.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)

                    Button("Try Again", systemImage: "arrow.clockwise") {
                        store.retryLoadingData()
                    }
                    .buttonStyle(.borderedProminent)
                    .frame(minHeight: 44)

                    Button("Reset Local Data", systemImage: "trash", role: .destructive) {
                        showsResetConfirmation = true
                    }
                    .buttonStyle(.bordered)
                    .frame(minHeight: 44)
                }
            }
            .padding(.horizontal, WorthlySpacing.screenHorizontal)
            .padding(.top, WorthlySpacing.xxxl)
            .padding(.bottom, WorthlySpacing.pageBottom)
            .worthlyReadableContent()
        }
        .background(Color(.systemBackground))
        .confirmationDialog(
            "Reset unreadable local data?",
            isPresented: $showsResetConfirmation,
            titleVisibility: .visible
        ) {
            Button("Reset Local Data", role: .destructive) {
                store.resetUnreadableData()
            }

            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This permanently replaces the unreadable files with a new empty money map.")
        }
    }
}

private enum AppTab: String, CaseIterable, Identifiable {
    case overview
    case planning
    case assets
    case history

    var id: Self { self }

    @ViewBuilder
    var label: some View {
        switch self {
        case .overview:
            Label("Overview", systemImage: "house.fill")
        case .planning:
            Label("Planning", systemImage: "calendar.badge.clock")
        case .assets:
            Label("Assets", systemImage: "wallet.pass")
        case .history:
            Label("History", systemImage: "list.bullet.rectangle")
        }
    }
}

#Preview {
    ContentView()
}
