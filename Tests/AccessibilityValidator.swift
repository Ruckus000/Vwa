#!/usr/bin/env swift
import Foundation

// Accessibility Validation Script
// Verifies that accessibility features from Phase 2 are implemented correctly

struct ValidationResult {
    let component: String
    let feature: String
    let passed: Bool
    let details: String
}

class AccessibilityValidator {
    var results: [ValidationResult] = []

    func validateFile(_ path: String, component: String, checks: [String: String]) {
        guard let content = try? String(contentsOfFile: path, encoding: .utf8) else {
            results.append(ValidationResult(
                component: component,
                feature: "File Read",
                passed: false,
                details: "Failed to read file at \(path)"
            ))
            return
        }

        for (feature, pattern) in checks {
            let passed = content.contains(pattern)
            results.append(ValidationResult(
                component: component,
                feature: feature,
                passed: passed,
                details: passed ? "✓ Found: \(pattern)" : "✗ Missing: \(pattern)"
            ))
        }
    }

    func printReport() {
        print("\n" + String(repeating: "=", count: 80))
        print("ACCESSIBILITY VALIDATION REPORT")
        print(String(repeating: "=", count: 80))

        let groupedResults = Dictionary(grouping: results, by: { $0.component })

        var totalPassed = 0
        var totalFailed = 0

        for (component, componentResults) in groupedResults.sorted(by: { $0.key < $1.key }) {
            let passed = componentResults.filter { $0.passed }.count
            let failed = componentResults.filter { !$0.passed }.count

            print("\n\(component):")
            print(String(repeating: "-", count: 80))

            for result in componentResults {
                let icon = result.passed ? "✅" : "❌"
                print("  \(icon) \(result.feature): \(result.details)")
            }

            print("  Summary: \(passed) passed, \(failed) failed")

            totalPassed += passed
            totalFailed += failed
        }

        print("\n" + String(repeating: "=", count: 80))
        print("OVERALL SUMMARY")
        print(String(repeating: "=", count: 80))
        print("Total Passed: \(totalPassed)")
        print("Total Failed: \(totalFailed)")
        print("Success Rate: \(totalPassed)/\(totalPassed + totalFailed) (\(String(format: "%.1f", Double(totalPassed) / Double(totalPassed + totalFailed) * 100))%)")
        print(String(repeating: "=", count: 80) + "\n")

        if totalFailed == 0 {
            print("🎉 All accessibility checks passed!")
        } else {
            print("⚠️  Some accessibility checks failed. Review the report above.")
        }
    }
}

// Main validation
let validator = AccessibilityValidator()
let basePath = FileManager.default.currentDirectoryPath

print("Starting accessibility validation...")
print("Base path: \(basePath)")

// 1. Validate ProgressIndicator (Phase 2.1 - Reduced Motion)
validator.validateFile(
    "\(basePath)/ios/Views/Components/ProgressIndicator.swift",
    component: "ProgressIndicator",
    checks: [
        "Reduced Motion Environment": "@Environment(\\.accessibilityReduceMotion)",
        "Reduced Motion Check 1": "reduceMotion ? nil :",
        "Animation Conditional": ".animation(reduceMotion"
    ]
)

// 2. Validate ListeningIndicator (Phase 2.1 - Reduced Motion)
validator.validateFile(
    "\(basePath)/ios/Views/Components/ListeningIndicator.swift",
    component: "ListeningIndicator",
    checks: [
        "Reduced Motion Environment": "@Environment(\\.accessibilityReduceMotion)",
        "Reduced Motion Check": "if !reduceMotion {",
        "Conditional Animation": "withAnimation("
    ]
)

// 3. Validate BrutalButton (Phase 2.1 - Reduced Motion)
validator.validateFile(
    "\(basePath)/ios/Views/Components/BrutalButton.swift",
    component: "BrutalButton",
    checks: [
        "Reduced Motion Environment": "@Environment(\\.accessibilityReduceMotion)",
        "Reduced Motion Animation": ".animation(reduceMotion ? nil :"
    ]
)

// 4. Validate TermCardView (Phase 2.2 - Accessibility Labels)
validator.validateFile(
    "\(basePath)/ios/Views/Components/TermCardView.swift",
    component: "TermCardView",
    checks: [
        "Accessibility Label Property": "var termAccessibilityLabel",
        "Category Label": "Category:",
        "Term Label": "Term:",
        "Definition Label": "Definition:",
        "Translation Label": "translation:",
        "Progress Label": "Term",
        "Accessibility Element": ".accessibilityElement",
        "Accessibility Label Modifier": ".accessibilityLabel(termAccessibilityLabel)"
    ]
)

// 5. Validate Design Tokens exist
validator.validateFile(
    "\(basePath)/ios/Theme/Spacing.swift",
    component: "Spacing Tokens",
    checks: [
        "space0": "static let space0",
        "space1": "static let space1",
        "space2": "static let space2",
        "space3": "static let space3",
        "space4": "static let space4",
        "space5": "static let space5",
        "shadowSmOffset": "static let shadowSmOffset",
        "shadowMdOffset": "static let shadowMdOffset",
        "borderSubtle": "static let borderSubtle",
        "borderStandard": "static let borderStandard",
        "borderHeavy": "static let borderHeavy",
        "touchTargetMin": "static let touchTargetMin"
    ]
)

// 6. Validate Typography Tokens
validator.validateFile(
    "\(basePath)/ios/Theme/Typography.swift",
    component: "Typography Tokens",
    checks: [
        "typeDisplayLg": "static var typeDisplayLg",
        "typeDisplayMd": "static var typeDisplayMd",
        "typeDisplaySm": "static var typeDisplaySm",
        "typeBodyLg": "static var typeBodyLg",
        "typeBody": "static var typeBody",
        "typeBodySm": "static var typeBodySm",
        "typeLabel": "static var typeLabel",
        "typeMono": "static var typeMono",
        "trackingTight": "static let trackingTight",
        "trackingLoose": "static let trackingLoose"
    ]
)

// Print the report
validator.printReport()

// Exit with appropriate code
exit(validator.results.filter { !$0.passed }.isEmpty ? 0 : 1)
