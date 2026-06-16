//
//  ContentView.swift
//  Worthly
//
//  Created by Giovan Christoffel Sihombing on 2026/06/15.
//

import SwiftUI

struct ContentView: View {
    private let sampleData = SampleFinanceData.current

    @State private var selectedTab: AppTab = .overview

    var body: some View {
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
        .tint(.blue)
    }

    @ViewBuilder
    private func content(for tab: AppTab) -> some View {
        switch tab {
        case .overview:
            HomeView(data: sampleData)
        case .planning:
            PlanningView(data: sampleData)
        case .assets:
            AssetView(data: sampleData)
        case .history:
            HistoryView(data: sampleData)
        case .settings:
            SettingView()
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
