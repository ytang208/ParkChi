import SwiftUI

struct RootView: View {
    var body: some View {
        TabView {
            NavigationStack {
                ParkingHomeView()
            }
            .tabItem { Label("Parked Car", systemImage: "car.fill") }

            NavigationStack {
                StreetRemindersView()
            }
            .tabItem { Label("Street", systemImage: "signpost.right.and.left.fill") }

            NavigationStack {
                RenewalsView()
            }
            .tabItem { Label("Renewals", systemImage: "calendar.badge.clock") }
        }
    }
}

struct ParkChiCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.background)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: .black.opacity(0.07), radius: 12, y: 5)
    }
}

struct EmptyFeatureView: View {
    let symbol: String
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: symbol)
                .font(.system(size: 44, weight: .semibold))
                .foregroundStyle(Color.parkChiBlue)
                .accessibilityHidden(true)
            Text(title)
                .font(.title3.bold())
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(28)
        .frame(maxWidth: .infinity)
    }
}
