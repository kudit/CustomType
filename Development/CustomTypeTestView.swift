#if canImport(SwiftUI)
import SwiftUI
import CustomType

@CustomType
public enum Degrees: Double {
    case top = 270.0
    case right = 0.0
    case bottom = 90.0
    case left = 180.0
}

@available(watchOS 8.0, tvOS 15.0, macOS 12.0, *)
public struct CustomTypeTestView: View {    
    public var body: some View {
        VStack {
            let test: Degree = 24.3
            Text("\(test)")
            ForEach(Degrees.allCases) { degree in
                Text("\(degree)")
            }
        }
    }
}

@available(watchOS 8.0, tvOS 15.0, macOS 12.0, *)
#Preview {
    CustomTypeTestView()
}
#endif
