import XCTest
import SwiftUI
@testable import Vwa

// Unit tests for Design Token Extensions
// Verifies that all design system tokens from Phase 1 are correctly implemented

class DesignTokensTests: XCTestCase {

    // MARK: - Spacing Token Tests

    func testSpacingTokens() {
        // Base spacing scale (Section 5.1)
        XCTAssertEqual(CGFloat.space0, 0, "space0 should be 0")
        XCTAssertEqual(CGFloat.space1, 4, "space1 should be 4")
        XCTAssertEqual(CGFloat.space2, 8, "space2 should be 8")
        XCTAssertEqual(CGFloat.space3, 12, "space3 should be 12")
        XCTAssertEqual(CGFloat.space4, 16, "space4 should be 16")
        XCTAssertEqual(CGFloat.space5, 20, "space5 should be 20")
        XCTAssertEqual(CGFloat.space6, 24, "space6 should be 24")
        XCTAssertEqual(CGFloat.space8, 32, "space8 should be 32")
        XCTAssertEqual(CGFloat.space10, 40, "space10 should be 40")
    }

    func testShadowOffsets() {
        // Shadow offset tokens (Section 5.4)
        XCTAssertEqual(CGFloat.shadowSmOffset, 2, "shadowSmOffset should be 2")
        XCTAssertEqual(CGFloat.shadowMdOffset, 4, "shadowMdOffset should be 4")
        XCTAssertEqual(CGFloat.shadowLgOffset, 8, "shadowLgOffset should be 8")
        XCTAssertEqual(CGFloat.shadowPressedOffset, 1, "shadowPressedOffset should be 1")
    }

    func testBorderWidths() {
        // Border width tokens (Section 5.3)
        XCTAssertEqual(CGFloat.borderSubtle, 1, "borderSubtle should be 1")
        XCTAssertEqual(CGFloat.borderStandard, 2, "borderStandard should be 2")
        XCTAssertEqual(CGFloat.borderHeavy, 3, "borderHeavy should be 3")
    }

    func testTouchTargets() {
        // iOS HIG minimum touch target (Section 9.2)
        XCTAssertEqual(CGFloat.touchTargetMin, 44, "touchTargetMin should be 44")
    }

    // MARK: - Typography Token Tests

    func testDisplayFonts() {
        // Display fonts (Section 4)
        let displayLg = Font.typeDisplayLg
        let displayMd = Font.typeDisplayMd
        let displaySm = Font.typeDisplaySm

        // Verify fonts exist (no direct size comparison in SwiftUI, but we can verify they compile)
        XCTAssertNotNil(displayLg, "typeDisplayLg should exist")
        XCTAssertNotNil(displayMd, "typeDisplayMd should exist")
        XCTAssertNotNil(displaySm, "typeDisplaySm should exist")
    }

    func testBodyFonts() {
        // Body fonts (Section 4)
        let bodyLg = Font.typeBodyLg
        let body = Font.typeBody
        let bodySm = Font.typeBodySm

        XCTAssertNotNil(bodyLg, "typeBodyLg should exist")
        XCTAssertNotNil(body, "typeBody should exist")
        XCTAssertNotNil(bodySm, "typeBodySm should exist")
    }

    func testLabelAndMonoFonts() {
        // Label and monospace fonts (Section 4)
        let label = Font.typeLabel
        let mono = Font.typeMono
        let monoSm = Font.typeMonoSm

        XCTAssertNotNil(label, "typeLabel should exist")
        XCTAssertNotNil(mono, "typeMono should exist")
        XCTAssertNotNil(monoSm, "typeMonoSm should exist")
    }

    func testLetterSpacing() {
        // Letter spacing tokens (Section 4.2)
        XCTAssertEqual(CGFloat.trackingTight, -2, "trackingTight should be -2")
        XCTAssertEqual(CGFloat.trackingNormal, -1, "trackingNormal should be -1")
        XCTAssertEqual(CGFloat.trackingLoose, 1, "trackingLoose should be 1")
    }

    // MARK: - Token Consistency Tests

    func testSpacingProgression() {
        // Verify 4px base unit progression
        XCTAssertEqual(CGFloat.space2, CGFloat.space1 * 2, "space2 should be 2x space1")
        XCTAssertEqual(CGFloat.space3, CGFloat.space1 * 3, "space3 should be 3x space1")
        XCTAssertEqual(CGFloat.space4, CGFloat.space1 * 4, "space4 should be 4x space1")
        XCTAssertEqual(CGFloat.space5, CGFloat.space1 * 5, "space5 should be 5x space1")
        XCTAssertEqual(CGFloat.space6, CGFloat.space1 * 6, "space6 should be 6x space1")
        XCTAssertEqual(CGFloat.space8, CGFloat.space1 * 8, "space8 should be 8x space1")
        XCTAssertEqual(CGFloat.space10, CGFloat.space1 * 10, "space10 should be 10x space1")
    }

    func testShadowProgression() {
        // Verify shadow sizes progress correctly
        XCTAssert(CGFloat.shadowSmOffset < CGFloat.shadowMdOffset, "Small shadow should be smaller than medium")
        XCTAssert(CGFloat.shadowMdOffset < CGFloat.shadowLgOffset, "Medium shadow should be smaller than large")
        XCTAssert(CGFloat.shadowPressedOffset < CGFloat.shadowSmOffset, "Pressed shadow should be smallest")
    }

    func testBorderProgression() {
        // Verify border widths progress correctly
        XCTAssert(CGFloat.borderSubtle < CGFloat.borderStandard, "Subtle border should be thinner than standard")
        XCTAssert(CGFloat.borderStandard < CGFloat.borderHeavy, "Standard border should be thinner than heavy")
    }
}
