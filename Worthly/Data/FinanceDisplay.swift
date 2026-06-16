//
//  FinanceDisplay.swift
//  Worthly
//
//  Created by Giovan Christoffel Sihombing on 2026/06/15.
//

import SwiftUI

extension AccountType {
    var systemImage: String {
        switch self {
        case .bank:
            "building.columns"
        case .eWallet:
            "wallet.pass"
        case .cash:
            "banknote"
        }
    }
}

extension FinanceTransaction {
    var displayIcon: String {
        switch category.lowercased() {
        case let category where category.contains("salary"):
            "square.and.arrow.down"
        case let category where category.contains("coupon"):
            "percent"
        case let category where category.contains("debt") || category.contains("installment"):
            "square.and.arrow.up"
        case let category where category.contains("restaurant") || category.contains("coffee"):
            "fork.knife"
        case let category where category.contains("travel") || category.contains("transport"):
            "airplane"
        case let category where category.contains("phone") || category.contains("internet"):
            "phone"
        case let category where category.contains("groceries"):
            "cart"
        case let category where category.contains("rent") || category.contains("home"):
            "house"
        case let category where category.contains("health"):
            "cross.case"
        case let category where category.contains("transfer") || category.contains("top up"):
            "arrow.left.arrow.right"
        case let category where category.contains("shopping"):
            "bag"
        case let category where category.contains("education"):
            "book"
        default:
            type == .income ? "square.and.arrow.down" : "creditcard"
        }
    }

    var displayTint: Color {
        switch type {
        case .income:
            .green
        case .outcome:
            category.lowercased().contains("restaurant") ? .teal : .red
        case .account:
            .purple
        }
    }

    var displayAmount: String {
        IDRFormatting.signedCompact(displaySignedAmount)
    }

    func subtitle(accountName: String) -> String {
        "\(type.title) - \(accountName)"
    }
}
