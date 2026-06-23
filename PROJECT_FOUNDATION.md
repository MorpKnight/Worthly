# Worthly Project Foundation

This document keeps the shared reasoning behind Worthly visible in public-friendly language: why the project exists, what problem it responds to, what I wanted to learn, and how the current prototype should be evaluated.

## Project Focus

Worthly is a working iOS prototype. The current focus is to explain the product direction clearly, test it with people, and use feedback to guide the next iteration.

## Personal Problem

I often feel unsure where my money actually is.

My money can be spread across bank accounts, e-wallets, cash, investments, and liabilities. Even when the total amount exists somewhere, it can feel mentally scattered. This makes it harder to answer simple questions:

- How much money do I really have right now?
- Which account holds most of it?
- What liabilities reduce my real net worth?
- Am I moving closer to a target or just recording numbers?

The starting problem is not only calculation. It is clarity.

## Wider Problem

Many people do not struggle because they have no financial data. They struggle because the data is fragmented across different places and mental notes.

Worthly responds to the problem of scattered personal money visibility. It is for people who want a simple local-first map of where their money lives before they need a full budgeting, accounting, or bank-connected finance system.

## Product Question

How might an iOS app help people understand where their money is and whether their current financial position is moving toward a goal?

## Product Response

Worthly is a local-first iOS prototype that helps users build a first money map:

1. Add the first account.
2. Add a liability or confirm no liabilities.
3. Optionally add an investment.
4. Optionally add a first transaction.
5. See a meaningful Overview.

The app then provides four main areas:

- Overview: current net worth, cashflow, setup prompts, recent activity, and quick add actions.
- Planning: target-readiness projection using salary, recurring expenses, fixed investment returns, and liabilities.
- Assets: accounts, investments, liabilities, and allocation summary.
- History: transaction records with income, expense, and transfer filtering.

## Learning Objective

My learning objective is to connect design thinking and SwiftUI implementation into one coherent product prototype.

More specifically, I want to learn:

- How to turn a personal pain point into a broader user problem.
- How to make a product concept clearer through user flow and information architecture.
- How to apply Apple-platform design patterns instead of copying static screens blindly.
- How to build reusable SwiftUI components and organize a growing project.
- How to model finance data carefully enough that the UI feels trustworthy.
- How to use validation, feedback, and iteration to improve both design and code.

## Product Principles

- Asset-map first, not expense-tracker first.
- Local-first and private by default.
- Start empty, then guide the user.
- Keep liabilities visually and conceptually separate from assets.
- Make actions contextual so users know what they are adding.
- Use native iOS patterns where possible.
- Preserve readability over decorative effects.
- Treat planning as educational projection, not financial advice.

## Current Strengths

- The concept is clearer than the first static UI pass.
- The app now has an onboarding path instead of assuming users know what to do.
- Settings no longer competes with core workflow as a main tab.
- Components and folders are organized well enough to continue iterating.
- Planning has a real projection engine and tests.
- Dummy data can be enabled safely without destroying user data.

## Current Risks

- The user problem still needs stronger external evidence.
- Users may not understand the difference between account balances, transactions, and planning assumptions.
- There are no delete flows yet.
- Transaction balance behavior can become confusing without an opening-balance model.
- Investment and liability models are simplified.
- Accessibility has improved, but VoiceOver and real-device validation are not complete.
- The app is educational and local-first; it is not production financial advice software.

## Validation Plan

Test with 3-5 people who manage money across more than one account or wallet.

Suggested tasks:

1. Add your first bank or e-wallet account.
2. Tell the app whether you have liabilities.
3. Add one investment or skip it.
4. Add a transaction or choose to add it later.
5. Explain what the Overview tells you.
6. Find where most of your money is stored.
7. Set a target and explain whether Planning says you are on track.

Observe:

- Where users hesitate.
- Whether labels make sense.
- Whether the tab structure feels natural.
- Whether the numbers feel trustworthy.
- Whether users understand what Worthly is for.

## Success Criteria

Worthly is successful for this prototype phase if users can:

- Understand the purpose of the app within one minute.
- Complete onboarding without explanation.
- Identify total assets, liabilities, and net worth.
- Find a specific account, investment, or liability.
- Explain the Planning result in their own words.
- Feel that the app helps them see their money more clearly.

## Documentation To Capture Next

- Screenshots of the final prototype.
- Feedback before and after design changes.
- Usability test notes.
- User quotes about confusion or clarity.
- A simple user flow diagram.
- A component inventory from code to design.
- A short demo script.
- Known limitations and next iteration plan.

## Portfolio Story Draft

Worthly began from my own confusion about scattered personal assets. I realized the problem was not only tracking transactions, but understanding where money actually lives across accounts, e-wallets, investments, and liabilities.

Through feedback and iteration, the concept shifted from a static finance dashboard into a local-first money map. I redesigned the first-run experience so users start empty and build their map step by step. I also changed ambiguous add actions into contextual actions, moved Settings out of the main tab bar, and replaced distracting partial sheets with focused full-screen editors.

On the coding side, I learned how to grow a SwiftUI prototype beyond one large screen file. I refactored the app into feature folders, extracted reusable components, added local persistence, implemented dummy data safely, improved accessibility, and built a projection engine with unit tests.

The current prototype is not a complete financial product yet. Its value is that it is now clear enough to test: can people use Worthly to understand where their money is and whether they are moving toward a target?

## Recommended Next Action

Run a small usability test before adding more features.

The next learning step should be evidence, not polish. If users understand the money map and planning result, the concept is becoming strong. If they do not, the next iteration should improve language, onboarding, and information architecture before deeper technical features.
