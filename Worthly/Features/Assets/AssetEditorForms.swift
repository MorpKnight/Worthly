//
//  AssetEditorForms.swift
//  Worthly
//
//  Created by Codex on 2026/06/18.
//

import SwiftUI

struct AssetAccountForm: View {
    @Binding var draft: AccountDraft

    var body: some View {
        AssetEditorTextFieldRow(
            icon: "textformat",
            title: "Name",
            placeholder: "Bank Central Asia",
            text: $draft.name
        )

        AssetEditorMenuRow(
            icon: draft.type.systemImage,
            title: "Type",
            value: draft.type.editorTitle
        ) {
            ForEach(AccountType.allCases) { type in
                Button(type.editorTitle) {
                    draft.type = type
                }
            }
        }

        AssetEditorTextFieldRow(
            icon: "creditcard",
            title: "Balance",
            placeholder: "Rp 0",
            text: $draft.balanceText,
            keyboardType: .decimalPad
        )

        AssetEditorDateRow(
            icon: "calendar",
            title: "Since",
            date: $draft.createdAt
        )
    }
}

struct AssetInvestmentForm: View {
    @Binding var draft: InvestmentDraft

    var body: some View {
        AssetEditorTextFieldRow(
            icon: "textformat",
            title: "Name",
            placeholder: "Deposit, gold, fund",
            text: $draft.name
        )

        AssetEditorTextFieldRow(
            icon: "banknote",
            title: "Investment Value",
            placeholder: "Rp 0",
            text: $draft.principalText,
            keyboardType: .decimalPad
        )

        AssetEditorTextFieldRow(
            icon: "percent",
            title: "Interest p.a. (%)",
            placeholder: "0",
            text: $draft.annualInterestRateText,
            keyboardType: .decimalPad
        )

        AssetEditorTextFieldRow(
            icon: "calendar.badge.clock",
            title: "Duration (Months)",
            placeholder: "0",
            text: $draft.durationMonthsText,
            keyboardType: .numberPad
        )

        AssetEditorDateRow(
            icon: "calendar",
            title: "Since",
            date: $draft.startDate
        )
    }
}

struct AssetDebtForm: View {
    @Binding var draft: DebtDraft

    var body: some View {
        AssetEditorTextFieldRow(
            icon: "textformat",
            title: "Name",
            placeholder: "KPR rumah",
            text: $draft.name
        )

        AssetEditorTextFieldRow(
            icon: "banknote",
            title: "Liability Value",
            placeholder: "Rp 0",
            text: $draft.remainingAmountText,
            keyboardType: .decimalPad
        )

        AssetEditorTextFieldRow(
            icon: "percent",
            title: "Interest p.a. (%)",
            placeholder: "0",
            text: $draft.annualInterestRateText,
            keyboardType: .decimalPad
        )

        AssetEditorTextFieldRow(
            icon: "calendar.badge.clock",
            title: "Duration (Months)",
            placeholder: "0",
            text: $draft.durationMonthsText,
            keyboardType: .numberPad
        )

        AssetEditorDateRow(
            icon: "calendar",
            title: "Since",
            date: $draft.startDate
        )
    }
}
