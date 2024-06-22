import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxBuilder
import SwiftCompilerPlugin
import Foundation

/// Implementation of the `CustomType` macro, which creates a type with a rawValue and static values for preset that can be iterated over from a simple enum declaration.
public struct CreateCustomTypeMacro: PeerMacro, FreestandingMacro {
    
    enum CTMError: Error, CustomStringConvertible {
        case applyToEnum
        case enumShouldBePrivate
        case nameShouldEndWithEnum
        case shouldInheritFromBaseType
        case casesShouldHaveAssociatedValues
        var description: String {
            switch self {
            case .applyToEnum:
                "@CustomType can only be applied to an enum"
            case .enumShouldBePrivate:
                "Enum should be marked private so it's not accidentally used."
            case .nameShouldEndWithEnum:
                "The enum name should be your custom type name + the string \"Enum\" so that your custom type name will be created and available or you can specify a custom type name as a macro parameter."
            case .shouldInheritFromBaseType:
                "The enum should inherit from a base type like Double or Int that the type can inherit from."
            case .casesShouldHaveAssociatedValues:
                "Each case should have an associated value so that it can be used using the dot notation."
            }
        }
    }

    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext // for communicating with compiler
    ) throws -> [DeclSyntax] {
        guard let enumDecl = declaration.as(EnumDeclSyntax.self) else {
            // TODO: create more advanced diagnostic?
            throw CTMError.applyToEnum
//            let structError = Diagnostic(
//                node: node,
//                message: CustomTypeMacroError.applyToEnum.description
//                )
//            context.diagnose(structError)
        }

// Find a way to deprecate original enum
        /*
         @available(swift, obsoleted: 1.0, message: "This enum should never actually be used as this is only used to easily generate the code above.")
         */
        guard enumDecl.modifiers.first?.name.text == "private" else {
            throw CTMError.enumShouldBePrivate
        }
        // TODO: Find a way to capture the parameter
//        let typeName: String? = nil //node.arguments?.firstToken(viewMode: .sourceAccurate)
//        guard let argument = node.argumentList.first?.expression,
//              let segments = argument.as(StringLiteralExprSyntax.self)?.segments,
//              segments.count == 1,
//              case .stringSegment(let literalSegment)? = segments.first
//        else {
//            throw CustomError.message("Need a static string")
//        }

        let customType = try {
            let name = enumDecl.name.text
            guard name.hasSuffix("Enum") else {
                throw CTMError.nameShouldEndWithEnum
            }
            return String(name.dropLast(4))
        }()
        
        guard let rawType = enumDecl.inheritanceClause?.inheritedTypes.first?.type.trimmed else {
            throw CTMError.shouldInheritFromBaseType
        }
        
        var members = [(trivia: Trivia, name: TokenSyntax, value: ExprSyntax)]()
        for member in enumDecl.memberBlock.members {
            guard let decl = member.decl.as(EnumCaseDeclSyntax.self) else {
                continue
            }
            let trivia = decl.leadingTrivia
            // determine if this is a single case or multiple
            // since can declare case a,b,c on one line, get all the cases whether they are separate cases or grouped on one line.
            for element in decl.elements {
                guard let value = element.rawValue?.value else {
                    throw CTMError.casesShouldHaveAssociatedValues // TODO: Include information about which case was missing value.
                }
                members.append((trivia: trivia, name: element.name.trimmed, value: value))
            }
        }
        
        let structMembers = MemberBlockItemListSyntax {
            for element in members {
                MemberBlockItemListSyntax(
"""
\(element.trivia)public static let \(element.name): Self = \(element.value)
""")
            }
        }

        let namedMap = members.map { element in
            """
        .\(element.name): "\(element.name)",
"""
        }.joined(separator: "\n")
        
        return [
"""
\(enumDecl.leadingTrivia)public struct \(raw: customType): ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral, Hashable, CaseIterable, Sendable, CustomStringConvertible {
    public var rawValue: \(rawType)
\(structMembers)

    public static let named: [Self : String] = [
\(raw: namedMap)
    ]
    public init(integerLiteral value: Int64) {
        self.rawValue = \(rawType)(value)
    }
    public init(floatLiteral value: \(rawType)) {
        self.rawValue = \(rawType)(value)
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
        ]
    }
}

@main
struct CustomTypePlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        CreateCustomTypeMacro.self
    ]
}
