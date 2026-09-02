import SwiftUI

@main
struct ParkChiApp: App {
    @StateObject private var store = AppStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
                .tint(.parkChiBlue)
        }
    }
}

extension Color {
    static let parkChiBlue = Color(red: 0.02, green: 0.29, blue: 0.55)
    static let parkChiRed = Color(red: 0.94, green: 0.20, blue: 0.22)
    static let parkChiSky = Color(red: 0.90, green: 0.96, blue: 1.00)
}
