import Combine
import Foundation

@MainActor
final class AppStore: ObservableObject {
    @Published private(set) var parkingSpot: ParkingSpot?
    @Published private(set) var streetReminders: [StreetReminder]
    @Published private(set) var renewals: [RenewalReminder]

    private let storageKey = "parkchi.snapshot.v1"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        let snapshot = Self.loadSnapshot(defaults: defaults, key: storageKey)
        parkingSpot = snapshot.parkingSpot
        streetReminders = snapshot.streetReminders
        renewals = snapshot.renewals
    }

    func saveParkingSpot(_ spot: ParkingSpot) {
        if let oldSpot = parkingSpot, oldSpot.id != spot.id {
            NotificationManager.shared.cancel(ids: [NotificationManager.moveID(for: oldSpot.id)])
        }
        if let oldPhoto = parkingSpot?.photoFilename, oldPhoto != spot.photoFilename {
            ImageStore.shared.delete(filename: oldPhoto)
        }
        parkingSpot = spot
        persist()
        NotificationManager.shared.scheduleMoveReminder(for: spot)
    }

    func clearParkingSpot() {
        if let spot = parkingSpot {
            NotificationManager.shared.cancel(ids: [NotificationManager.moveID(for: spot.id)])
            if let filename = spot.photoFilename {
                ImageStore.shared.delete(filename: filename)
            }
        }
        parkingSpot = nil
        persist()
    }

    func addStreetReminder(_ reminder: StreetReminder) {
        streetReminders.append(reminder)
        sortAndPersist()
        NotificationManager.shared.scheduleStreetReminder(reminder)
    }

    func deleteStreetReminders(at offsets: IndexSet) {
        let ids = offsets.map { streetReminders[$0].id.uuidString }
        for index in offsets.sorted(by: >) {
            streetReminders.remove(at: index)
        }
        persist()
        NotificationManager.shared.cancel(ids: ids)
    }

    func addRenewal(_ renewal: RenewalReminder) {
        renewals.append(renewal)
        sortAndPersist()
        NotificationManager.shared.scheduleRenewal(renewal)
    }

    func deleteRenewals(at offsets: IndexSet) {
        let ids = offsets.flatMap { NotificationManager.renewalIDs(for: renewals[$0].id) }
        for index in offsets.sorted(by: >) {
            renewals.remove(at: index)
        }
        persist()
        NotificationManager.shared.cancel(ids: ids)
    }

    private func sortAndPersist() {
        streetReminders.sort { $0.date < $1.date }
        renewals.sort { $0.dueDate < $1.dueDate }
        persist()
    }

    private func persist() {
        let snapshot = AppSnapshot(
            parkingSpot: parkingSpot,
            streetReminders: streetReminders,
            renewals: renewals
        )
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        defaults.set(data, forKey: storageKey)
    }

    private static func loadSnapshot(defaults: UserDefaults, key: String) -> AppSnapshot {
        guard
            let data = defaults.data(forKey: key),
            let snapshot = try? JSONDecoder().decode(AppSnapshot.self, from: data)
        else { return .empty }
        return snapshot
    }
}
