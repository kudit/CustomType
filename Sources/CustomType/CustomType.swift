// The Swift Programming Language
// https://docs.swift.org/swift-book

@attached(peer) // TODO: (typeName: String? = nil) x
public macro CreateCustomType() = #externalMacro(module: "CustomTypeMacros", type: "CreateCustomTypeMacro")
