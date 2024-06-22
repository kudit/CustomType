#if canImport(SwiftUI)
import SwiftUI
#if canImport(CustomType)
import CustomType
#endif

@main
struct CustomTypeTestApp: App {
    init() {
        CustomType.current.disableIdleTimerWhenPluggedIn()
    }
    var body: some Scene {
        WindowGroup {
            if #available(watchOS 8.0, tvOS 15.0, macOS 12.0, *) {
                CustomTypeTestView()
            } else {
                // Fallback on earlier versions
                Text("UI Tests not available on older platforms.  However, framework code should still work.")
            }
        }
    }
}
#endif
