import Foundation
import UserNotifications

final class NotificationManager {
    static let shared = NotificationManager()
    private init() {}

    func scheduleMoveReminder(for spot: ParkingSpot) {
        let id = Self.moveID(for: spot.id)
        cancel(ids: [id])
        guard let moveBy = spot.moveBy, moveBy > Date() else { return }
        add(
            id: id,
            title: "Time to move your car",
            body: spot.note.isEmpty ? "Check the posted parking signs before time runs out." : spot.note,
            date: moveBy,
            repeats: false
        )
    }

    func scheduleStreetReminder(_ reminder: StreetReminder) {
        cancel(ids: [reminder.id.uuidString])
        guard reminder.repeatRule == .weekly || reminder.date > Date() else { return }
        add(
            id: reminder.id.uuidString,
            title: reminder.title,
            body: reminder.details.isEmpty ? "Check the posted signs and move your car if needed." : reminder.details,
            date: reminder.date,
            repeats: reminder.repeatRule == .weekly
        )
    }

    func scheduleRenewal(_ renewal: RenewalReminder) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: Self.renewalIDs(for: renewal.id))
        for days in [30, 7, 1] {
            guard let date = Calendar.current.date(byAdding: .day, value: -days, to: renewal.dueDate), date > Date() else {
                continue
            }
            add(
                id: "renewal-\(renewal.id.uuidString)-\(days)",
                title: "\(renewal.displayName) due soon",
                body: "Due in \(days) day\(days == 1 ? "" : "s"). Verify the deadline with the issuing agency.",
                date: date,
                repeats: false
            )
        }
    }

    func cancel(ids: [String]) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
    }

    static func moveID(for id: UUID) -> String { "move-\(id.uuidString)" }

    static func renewalIDs(for id: UUID) -> [String] {
        [30, 7, 1].map { "renewal-\(id.uuidString)-\($0)" }
    }

    private func add(id: String, title: String, body: String, date: Date, repeats: Bool) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let components: DateComponents
        if repeats {
            components = Calendar.current.dateComponents([.weekday, .hour, .minute], from: date)
        } else {
            components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        }
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: repeats)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .notDetermined:
                center.requestAuthorization(options: [.alert, .badge, .sound]) { allowed, _ in
                    if allowed { center.add(request) }
                }
            case .authorized, .provisional, .ephemeral:
                center.add(request)
            case .denied:
                break
            @unknown default:
                break
            }
        }
    }
}
