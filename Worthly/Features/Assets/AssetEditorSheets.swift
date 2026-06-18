//
//  AssetEditorSheets.swift
//  Worthly
//
//  Created by Codex on 2026/06/18.
//

import SwiftUI

struct AddAssetEditorSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let onSaveAccount: (Account) -> Void
    let onSaveInvestment: (SBNInvestment) -> Void
    let onSaveDebt: (Debt) -> Void

    @State private var selectedKind: AddAssetKind
    @State private var accountDraft: AccountDraft
    @State private var investmentDraft: InvestmentDraft
    @State private var debtDraft: DebtDraft

    init(
        initialKind: AddAssetKind = .liquidAccount,
        referenceDate: Date,
        onSaveAccount: @escaping (Account) -> Void,
        onSaveInvestment: @escaping (SBNInvestment) -> Void,
        onSaveDebt: @escaping (Debt) -> Void
    ) {
        self.onSaveAccount = onSaveAccount
        self.onSaveInvestment = onSaveInvestment
        self.onSaveDebt = onSaveDebt
        _selectedKind = State(initialValue: initialKind)
        _accountDraft = State(initialValue: AccountDraft(referenceDate: referenceDate))
        _investmentDraft = State(initialValue: InvestmentDraft(referenceDate: referenceDate))
        _debtDraft = State(initialValue: DebtDraft(referenceDate: referenceDate))
    }

    private var canSave: Bool {
        switch selectedKind {
        case .liquidAccount:
            accountDraft.isValid
        case .sbnInvestment:
            investmentDraft.isValid
        case .liability:
            debtDraft.isValid
        }
    }

    private var selectedKindBinding: Binding<AddAssetKind> {
        Binding(
            get: { selectedKind },
            set: { newValue in
                guard selectedKind != newValue else {
                    return
                }

                if reduceMotion {
                    selectedKind = newValue
                } else {
                    withAnimation(.snappy(duration: 0.18)) {
                        selectedKind = newValue
                    }
                }
            }
        )
    }

    private var formTransition: AnyTransition {
        reduceMotion ? .identity : .opacity
    }

    var body: some View {
        AssetEditorSheetContainer(
            title: "Add Asset",
            saveIsEnabled: canSave,
            onCancel: { dismiss() },
            onSave: save
        ) {
            VStack(spacing: WorthlySpacing.sm) {
                Picker("Asset type", selection: selectedKindBinding) {
                    ForEach(AddAssetKind.allCases) { kind in
                        Text(kind.title)
                            .tag(kind)
                    }
                }
                .pickerStyle(.segmented)

                AssetEditorFormGroup {
                    Group {
                        switch selectedKind {
                        case .liquidAccount:
                            AssetAccountForm(draft: $accountDraft)
                        case .sbnInvestment:
                            AssetInvestmentForm(draft: $investmentDraft)
                        case .liability:
                            AssetDebtForm(draft: $debtDraft)
                        }
                    }
                    .id(selectedKind)
                    .transition(formTransition)
                }
            }
        }
    }

    private func save() {
        switch selectedKind {
        case .liquidAccount:
            guard let account = accountDraft.account else {
                return
            }

            onSaveAccount(account)
        case .sbnInvestment:
            guard let investment = investmentDraft.investment else {
                return
            }

            onSaveInvestment(investment)
        case .liability:
            guard let debt = debtDraft.debt else {
                return
            }

            onSaveDebt(debt)
        }

        dismiss()
    }
}

struct AssetAccountEditorSheet: View {
    @Environment(\.dismiss) private var dismiss

    let onSave: (Account) -> Void

    @State private var draft: AccountDraft

    init(account: Account, onSave: @escaping (Account) -> Void) {
        self.onSave = onSave
        _draft = State(initialValue: AccountDraft(account: account))
    }

    var body: some View {
        AssetEditorSheetContainer(
            title: "Edit Account",
            saveIsEnabled: draft.isValid,
            onCancel: { dismiss() },
            onSave: save
        ) {
            AssetEditorFormGroup {
                AssetAccountForm(draft: $draft)
            }
        }
    }

    private func save() {
        guard let account = draft.account else {
            return
        }

        onSave(account)
        dismiss()
    }
}

struct AssetInvestmentEditorSheet: View {
    @Environment(\.dismiss) private var dismiss

    let title: String
    let onSave: (SBNInvestment) -> Void

    @State private var draft: InvestmentDraft

    init(investment: SBNInvestment, onSave: @escaping (SBNInvestment) -> Void) {
        self.title = "Edit \(investment.name)"
        self.onSave = onSave
        _draft = State(initialValue: InvestmentDraft(investment: investment))
    }

    var body: some View {
        AssetEditorSheetContainer(
            title: title,
            saveIsEnabled: draft.isValid,
            onCancel: { dismiss() },
            onSave: save
        ) {
            AssetEditorFormGroup {
                AssetInvestmentForm(draft: $draft)
            }
        }
    }

    private func save() {
        guard let investment = draft.investment else {
            return
        }

        onSave(investment)
        dismiss()
    }
}

struct AssetDebtEditorSheet: View {
    @Environment(\.dismiss) private var dismiss

    let title: String
    let onSave: (Debt) -> Void

    @State private var draft: DebtDraft

    init(debt: Debt, onSave: @escaping (Debt) -> Void) {
        self.title = "Edit \(debt.name)"
        self.onSave = onSave
        _draft = State(initialValue: DebtDraft(debt: debt))
    }

    var body: some View {
        AssetEditorSheetContainer(
            title: title,
            saveIsEnabled: draft.isValid,
            onCancel: { dismiss() },
            onSave: save
        ) {
            AssetEditorFormGroup {
                AssetDebtForm(draft: $draft)
            }
        }
    }

    private func save() {
        guard let debt = draft.debt else {
            return
        }

        onSave(debt)
        dismiss()
    }
}

struct AssetMissingEditorSheet: View {
    @Environment(\.dismiss) private var dismiss

    let title: String

    var body: some View {
        AssetEditorSheetContainer(
            title: title,
            saveIsEnabled: false,
            onCancel: { dismiss() },
            onSave: {}
        ) {
            Text("Please choose another asset.")
                .font(.body)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

private struct AssetEditorSheetContainer<Content: View>: View {
    let title: String
    let saveIsEnabled: Bool
    let onCancel: () -> Void
    let onSave: () -> Void
    let content: Content

    init(
        title: String,
        saveIsEnabled: Bool,
        onCancel: @escaping () -> Void,
        onSave: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.saveIsEnabled = saveIsEnabled
        self.onCancel = onCancel
        self.onSave = onSave
        self.content = content()
    }

    var body: some View {
        WorthlyFullScreenEditorContainer(
            title: title,
            leadingAccessibilityLabel: "Cancel",
            saveAccessibilityLabel: "Save asset",
            saveIsEnabled: saveIsEnabled,
            onLeading: onCancel,
            onSave: onSave
        ) {
            content
        }
    }
}

private struct AssetEditorFormGroup<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 0) {
            content
        }
        .padding(.horizontal, WorthlySpacing.md)
        .padding(.vertical, WorthlySpacing.xs)
        .background(
            Color(.secondarySystemGroupedBackground),
            in: RoundedRectangle(cornerRadius: WorthlySpacing.xl, style: .continuous)
        )
    }
}
