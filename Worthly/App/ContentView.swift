//
//  ContentView.swift
//  Worthly
//
//  Created by Giovan Christoffel Sihombing on 2026/06/15.
//

import SwiftUI

struct ContentView: View {
    @State private var store = FinanceStore()
    @State private var selectedTab: AppTab = .overview

    var body: some View {
        Group {
            if store.hasCompletedOnboarding {
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
                .tint(WorthlyAccessibleColor.accent)
            } else {
                OnboardingView(store: store)
            }
        }
    }

    @ViewBuilder
    private func content(for tab: AppTab) -> some View {
        switch tab {
        case .overview:
            HomeView(store: store)
        case .planning:
            PlanningView(store: store)
        case .assets:
            AssetView(store: store)
        case .history:
            HistoryView(store: store)
        case .settings:
            SettingView(store: store)
        }
    }
}

private enum AppTab: String, CaseIterable, Identifiable {
    case overview
    case planning
    case assets
    case history
    case settings

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
        case .settings:
            Label("Settings", systemImage: "gearshape")
        }
    }
}

#Preview {
    ContentView()
}
