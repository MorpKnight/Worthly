//
//  OnboardingView.swift
//  Worthly
//
//  Created by Codex on 2026/06/18.
//

import SwiftUI

struct OnboardingView: View {
    let store: FinanceStore

    @State private var step: OnboardingStep
    @State private var activeEditor: OnboardingEditor?
    @State private var hasSkippedInvestment = false

    init(store: FinanceStore = FinanceStore()) {
        self.store = store
        _step = State(initialValue: OnboardingStep.recommendedStep(for: store, hasSkippedInvestment: false))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: WorthlySpacing.lg) {
                header

                OnboardingProgressView(currentStep: step)

                WorthlySummaryCard(padding: WorthlySpacing.md) {
                    stepContent
                }

                Text("You can edit every account, liability, investment, and transaction later.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, WorthlySpacing.screenHorizontal)
            .padding(.top, WorthlySpacing.xxxl)
            .padding(.bottom, WorthlySpacing.pageBottom)
        }
        .background(Color(.systemBackground))
        .fullScreenCover(item: $activeEditor) { editor in
            editorView(for: editor)
        }
        .onAppear {
            step = OnboardingStep.recommendedStep(for: store, hasSkippedInvestment: hasSkippedInvestment)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: WorthlySpacing.xs) {
            Image(systemName: "map")
                .font(.title.weight(.semibold))
                .foregroundStyle(WorthlyAccessibleColor.accent)
                .accessibilityHidden(true)

            Text("Worthly")
                .font(.largeTitle.weight(.bold))

            Text("Build your first money map")
                .font(.title3.weight(.semibold))

            Text("Add the minimum information Worthly needs to make your Overview useful.")
                .font(.body)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    @ViewBuilder
    private var stepContent: some View {
        switch step {
        case .account:
            OnboardingStepContent(
                systemImage: "wallet.pass",
                eyebrow: step.progressText,
                title: "Add your first account",
                message: "Start with one place where your money lives, like a bank, e-wallet, or cash account.",
                primaryTitle: store.accounts.isEmpty ? "Add first account" : "Continue",
                primarySystemImage: store.accounts.isEmpty ? "plus" : "arrow.right",
                primaryAction: {
                    if store.accounts.isEmpty {
                        activeEditor = .account
                    } else {
                        step = .liability
                    }
                }
            )
        case .liability:
            OnboardingStepContent(
                systemImage: "creditcard",
                eyebrow: step.progressText,
                title: "Do you have liabilities?",
                message: "Liabilities are debts or installments that reduce your net worth. Add one now or mark that you have none.",
                primaryTitle: "Add liability",
                primarySystemImage: "plus",
                primaryAction: { activeEditor = .liability },
                secondaryTitle: "I have no liabilities",
                secondarySystemImage: "checkmark.circle",
                secondaryAction: {
                    store.confirmNoLiabilities()
                    step = .investment
                }
            )
        case .investment:
            OnboardingStepContent(
                systemImage: "percent",
                eyebrow: step.progressText,
                title: "Add investment?",
                message: "Investments are optional for setup. Add one if you want your asset allocation to be more complete now.",
                primaryTitle: "Add investment",
                primarySystemImage: "plus",
                primaryAction: { activeEditor = .investment },
                secondaryTitle: "Skip for now",
                secondarySystemImage: "forward",
                secondaryAction: {
                    hasSkippedInvestment = true
                    step = .transaction
                }
            )
        case .transaction:
            OnboardingStepContent(
                systemImage: "list.bullet.rectangle",
                eyebrow: step.progressText,
                title: "Add your first transaction",
                message: "A transaction gives Overview its first cashflow signal. You can also add it later and start from your asset map.",
                primaryTitle: "Add transaction",
                primarySystemImage: "plus",
                primaryAction: { activeEditor = .transaction },
                secondaryTitle: "Add later",
                secondarySystemImage: "clock",
                secondaryAction: { store.completeOnboarding() }
            )
        case .complete:
            OnboardingStepContent(
                systemImage: "checkmark.circle.fill",
                eyebrow: step.progressText,
                title: "Your overview is ready",
                message: "Worthly now has enough local data to show a meaningful first money map.",
                primaryTitle: "See Overview",
                primarySystemImage: "arrow.right",
                primaryAction: { store.completeOnboarding() }
            )
        }
    }

    @ViewBuilder
    private func editorView(for editor: OnboardingEditor) -> some View {
        switch editor {
        case .account:
            AddAssetEditorSheet(
                title: "Add First Account",
                initialKind: .liquidAccount,
                allowedKinds: [.liquidAccount],
                referenceDate: store.referenceDate,
                onSaveAccount: {
                    store.addAccount($0)
                    step = .liability
                },
                onSaveInvestment: { _ in },
                onSaveDebt: { _ in }
            )
        case .liability:
            AddAssetEditorSheet(
                title: "Add Liability",
                initialKind: .liability,
                allowedKinds: [.liability],
                referenceDate: store.referenceDate,
                onSaveAccount: { _ in },
                onSaveInvestment: { _ in },
                onSaveDebt: {
                    store.addDebt($0)
                    step = .investment
                }
            )
        case .investment:
            AddAssetEditorSheet(
                title: "Add Investment",
                initialKind: .sbnInvestment,
                allowedKinds: [.sbnInvestment],
                referenceDate: store.referenceDate,
                onSaveAccount: { _ in },
                onSaveInvestment: {
                    store.addInvestment($0)
                    step = .transaction
                },
                onSaveDebt: { _ in }
            )
        case .transaction:
            HistoryTransactionEditorSheet(
                mode: .add,
                transaction: nil,
                accounts: store.accounts,
                referenceDate: store.referenceDate,
                onSave: {
                    store.addTransaction($0)
                    step = .complete
                }
            )
        }
    }
}

private enum OnboardingStep: Int, CaseIterable, Hashable {
    case account
    case liability
    case investment
    case transaction
    case complete

    var progressText: String {
        "Step \(rawValue + 1) of \(Self.allCases.count)"
    }

    static func recommendedStep(for store: FinanceStore, hasSkippedInvestment: Bool) -> OnboardingStep {
        if store.accounts.isEmpty {
            return .account
        }

        if store.debts.isEmpty && !store.hasAnsweredLiabilitySetup {
            return .liability
        }

        if !store.transactions.isEmpty {
            return .complete
        }

        if store.sbnInvestments.isEmpty && !hasSkippedInvestment {
            return .investment
        }

        return .transaction
    }
}

private enum OnboardingEditor: String, Identifiable {
    case account
    case liability
    case investment
    case transaction

    var id: String { rawValue }
}

private struct OnboardingProgressView: View {
    let currentStep: OnboardingStep

    var body: some View {
        HStack(spacing: WorthlySpacing.xs) {
            ForEach(OnboardingStep.allCases, id: \.self) { step in
                Capsule()
                    .fill(step.rawValue <= currentStep.rawValue ? WorthlyAccessibleColor.accent : Color(.systemGray5))
                    .frame(height: 6)
                    .accessibilityHidden(true)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Onboarding progress")
        .accessibilityValue(currentStep.progressText)
    }
}

private struct OnboardingStepContent: View {
    let systemImage: String
    let eyebrow: String
    let title: String
    let message: String
    let primaryTitle: String
    let primarySystemImage: String
    let primaryAction: () -> Void
    let secondaryTitle: String?
    let secondarySystemImage: String?
    let secondaryAction: (() -> Void)?

    init(
        systemImage: String,
        eyebrow: String,
        title: String,
        message: String,
        primaryTitle: String,
        primarySystemImage: String,
        primaryAction: @escaping () -> Void,
        secondaryTitle: String? = nil,
        secondarySystemImage: String? = nil,
        secondaryAction: (() -> Void)? = nil
    ) {
        self.systemImage = systemImage
        self.eyebrow = eyebrow
        self.title = title
        self.message = message
        self.primaryTitle = primaryTitle
        self.primarySystemImage = primarySystemImage
        self.primaryAction = primaryAction
        self.secondaryTitle = secondaryTitle
        self.secondarySystemImage = secondarySystemImage
        self.secondaryAction = secondaryAction
    }

    var body: some View {
        VStack(alignment: .leading, spacing: WorthlySpacing.md) {
            VStack(alignment: .leading, spacing: WorthlySpacing.xs) {
                Image(systemName: systemImage)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(WorthlyAccessibleColor.accent)
                    .accessibilityHidden(true)

                Text(eyebrow)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                Text(title)
                    .font(.title3.weight(.bold))

                Text(message)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            VStack(spacing: WorthlySpacing.xs) {
                Button(action: primaryAction) {
                    Label(primaryTitle, systemImage: primarySystemImage)
                        .font(.body.weight(.semibold))
                        .frame(maxWidth: .infinity, minHeight: 48)
                }
                .buttonStyle(.borderedProminent)

                if let secondaryAction, let secondaryTitle {
                    Button(action: secondaryAction) {
                        Label(secondaryTitle, systemImage: secondarySystemImage ?? "arrow.right")
                            .font(.body.weight(.semibold))
                            .frame(maxWidth: .infinity, minHeight: 48)
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
        .accessibilityElement(children: .contain)
    }
}

#Preview {
    OnboardingView(store: FinanceStore())
}
