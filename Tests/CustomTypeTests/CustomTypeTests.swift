import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(CustomTypeMacros)
@testable import CustomTypeMacros

let testMacros: [String: Macro.Type] = [
    "CustomType": CreateCustomTypeMacro.self,
]

let idealCode = """
/// Enum documentation
@CustomType
private enum LifetimeEnum: TimeInterval {
    /// the shortest lifetime (very brief)
    case brief = 0.2
    /// Elements only stay for the screen for a short amount of time
    case short = 1
    /// Elements will stay on the screen for a longer time and will then disappear.
    case medium = 2
    /// Elements will stay on the screen for a long time and only then disappear.
    case long = 4
}
"""

let expandedCode = """
/// Enum documentation
private enum LifetimeEnum: TimeInterval {
    /// the shortest lifetime (very brief)
    case brief = 0.2
    /// Elements only stay for the screen for a short amount of time
    case short = 1
    /// Elements will stay on the screen for a longer time and will then disappear.
    case medium = 2
    /// Elements will stay on the screen for a long time and only then disappear.
    case long = 4
}

/// Enum documentation
public struct Lifetime: ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral, Hashable, CaseIterable, Sendable, CustomStringConvertible {
    public var rawValue: TimeInterval

    /// the shortest lifetime (very brief)
    public static let brief: Self = 0.2
    /// Elements only stay for the screen for a short amount of time
    public static let short: Self = 1
    /// Elements will stay on the screen for a longer time and will then disappear.
    public static let medium: Self = 2
    /// Elements will stay on the screen for a long time and only then disappear.
    public static let long: Self = 4

    public static let named: [Self : String] = [
        .brief: "brief",
        .short: "short",
        .medium: "medium",
        .long: "long",
    ]
    public init(integerLiteral value: Int64) {
        self.rawValue = TimeInterval(value)
    }
    public init(floatLiteral value: TimeInterval) {
        self.rawValue = TimeInterval(value)
    }
    public static var allCases: [Self] {
        return Array(named.keys)
    }
    public var description: String {
        if let name = Self.named[self] {
            return ".\\(name)"
        }
        return String(describing: rawValue)
    }
}
"""

final class CustomTypeTests: XCTestCase {
    func testCustomTypeMacro() {
        assertMacroExpansion(idealCode, expandedSource: expandedCode, macros: testMacros)
    }
    
    func testMacroOnStruct() throws {
        assertMacroExpansion(
"""
@CustomType
struct FooBar {
}
""", expandedSource: """

struct FooBar {
}
""", diagnostics: [
    DiagnosticSpec(message: CreateCustomTypeMacro.CTMError.applyToEnum.description, line: 1, column: 1)
], macros: testMacros)
    }
    
    func testPrivate() throws {
        assertMacroExpansion(
"""
@CustomType
enum FooBar {
}
""", expandedSource: """

enum FooBar {
}
""", diagnostics: [
    DiagnosticSpec(message: CreateCustomTypeMacro.CTMError.enumShouldBePrivate.description, line: 1, column: 1)
], macros: testMacros)
    }

    func testNonEnumNamed() throws {
        assertMacroExpansion(
"""
@CustomType
private enum FooBar {
}
""", expandedSource: """

enum FooBar {
}
""", diagnostics: [
    DiagnosticSpec(message: CreateCustomTypeMacro.CTMError.nameShouldEndWithEnum.description, line: 1, column: 1)
], macros: testMacros)
    }
    
    func testMissingRawType() throws {
        assertMacroExpansion(
"""
@CustomType
private enum FooBarEnum {
}
""", expandedSource: """

enum FooBarEnum {
}
""", diagnostics: [
    DiagnosticSpec(message: CreateCustomTypeMacro.CTMError.shouldInheritFromBaseType.description, line: 1, column: 1)
], macros: testMacros)
    }
    
    func testMissingAssociatedValues() throws {
        assertMacroExpansion(
"""
@CustomType
private enum FooBarEnum: Double {
    case a, b = 3, c
}
""", expandedSource: """

private enum FooBarEnum: Double {
    case a, b = 3, c
}
""", diagnostics: [
    DiagnosticSpec(message: CreateCustomTypeMacro.CTMError.casesShouldHaveAssociatedValues.description, line: 1, column: 1)
], macros: testMacros)
    }
    
    func testSimple() throws {
        assertMacroExpansion(
"""
/// Leading Trivia for FooBarEnum description
@CustomType
private enum FooBarEnum: Double {
    /// case a and b documentation
    case a = 2, b = 3
    /// case c documentation
    case c = 2.1
}
""", expandedSource: """
/// Leading Trivia for FooBarEnum description
private enum FooBarEnum: Double {
    /// case a and b documentation
    case a = 2, b = 3
    /// case c documentation
    case c = 2.1
}

/// Leading Trivia for FooBarEnum description
public struct FooBar: ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral, Hashable, CaseIterable, Sendable, CustomStringConvertible {
    public var rawValue: Double

    /// case a and b documentation
    public static let a: Self = 2
    /// case a and b documentation
    public static let b: Self = 3
    /// case c documentation
    public static let c: Self = 2.1

    public static let named: [Self : String] = [
        .a: "a",
        .b: "b",
        .c: "c",
    ]
    public init(integerLiteral value: Int64) {
        self.rawValue = Double(value)
    }
    public init(floatLiteral value: Double) {
        self.rawValue = Double(value)
    }
    public static var allCases: [Self] {
        return Array(named.keys)
    }
    public var description: String {
        if let name = Self.named[self] {
            return ".\\(name)"
        }
        return String(describing: rawValue)
    }
}
""", macros: testMacros)
    }

}
#endif
