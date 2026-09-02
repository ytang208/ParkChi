import Foundation

struct ParkingSpot: Identifiable, Codable, Equatable {
    let id: UUID
    var savedAt: Date
    var note: String
    var moveBy: Date?
    var latitude: Double?
    var longitude: Double?
    var photoFilename: String?

    init(
        id: UUID = UUID(),
        savedAt: Date = Date(),
        note: String,
        moveBy: Date?,
        latitude: Double?,
        longitude: Double?,
        photoFilename: String?
    ) {
        self.id = id
        self.savedAt = savedAt
        self.note = note
        self.moveBy = moveBy
        self.latitude = latitude
        self.longitude = longitude
        self.photoFilename = photoFilename
    }
}

enum ReminderRepeat: String, Codable, CaseIterable, Identifiable {
    case never
    case weekly

    var id: String { rawValue }
    var label: String { self == .weekly ? "Every week" : "One time" }
}

struct StreetReminder: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var details: String
    var date: Date
    var repeatRule: ReminderRepeat

    init(
        id: UUID = UUID(),
        title: String,
        details: String,
        date: Date,
        repeatRule: ReminderRepeat
    ) {
        self.id = id
        self.title = title
        self.details = details
        self.date = date
        self.repeatRule = repeatRule
    }
}

enum RenewalKind: String, Codable, CaseIterable, Identifiable {
    case citySticker
    case licensePlate
    case residentialPermit
    case emissionsTest
    case other

    var id: String { rawValue }

    var label: String {
        switch self {
        case .citySticker: "City sticker"
        case .licensePlate: "License plate"
        case .residentialPermit: "Residential permit"
        case .emissionsTest: "Emissions test"
        case .other: "Other"
        }
    }

    var symbol: String {
        switch self {
        case .citySticker: "car.side"
        case .licensePlate: "rectangle.and.text.magnifyingglass"
        case .residentialPermit: "parkingsign.circle"
        case .emissionsTest: "wind"
        case .other: "calendar.badge.clock"
        }
    }
}

struct RenewalReminder: Identifiable, Codable, Equatable {
    let id: UUID
    var kind: RenewalKind
    var customName: String
    var dueDate: Date
    var note: String

    init(
        id: UUID = UUID(),
        kind: RenewalKind,
        customName: String,
        dueDate: Date,
        note: String
    ) {
        self.id = id
        self.kind = kind
        self.customName = customName
        self.dueDate = dueDate
        self.note = note
    }

    var displayName: String {
        kind == .other && !customName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? customName
            : kind.label
    }
}

struct AppSnapshot: Codable, Equatable {
    var parkingSpot: ParkingSpot?
    var streetReminders: [StreetReminder]
    var renewals: [RenewalReminder]

    static let empty = AppSnapshot(parkingSpot: nil, streetReminders: [], renewals: [])
}
