import XCTest
@testable import ParkChi

final class ParkChiCoreTests: XCTestCase {
    func testSnapshotRoundTripPreservesUserData() throws {
        let spot = ParkingSpot(
            note: "North side of Addison",
            moveBy: Date(timeIntervalSince1970: 2_000_000_000),
            latitude: 41.947,
            longitude: -87.657,
            photoFilename: "sign.jpg"
        )
        let reminder = StreetReminder(
            title: "Street cleaning",
            details: "Zone 123",
            date: Date(timeIntervalSince1970: 2_000_000_100),
            repeatRule: .never
        )
        let renewal = RenewalReminder(
            kind: .citySticker,
            customName: "",
            dueDate: Date(timeIntervalSince1970: 2_000_000_200),
            note: ""
        )
        let original = AppSnapshot(parkingSpot: spot, streetReminders: [reminder], renewals: [renewal])

        let encoded = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(AppSnapshot.self, from: encoded)

        XCTAssertEqual(decoded, original)
    }

    func testCustomRenewalUsesCustomName() {
        let renewal = RenewalReminder(
            kind: .other,
            customName: "Garage permit",
            dueDate: Date(),
            note: ""
        )

        XCTAssertEqual(renewal.displayName, "Garage permit")
    }

    func testKnownRenewalIgnoresCustomName() {
        let renewal = RenewalReminder(
            kind: .licensePlate,
            customName: "Unused",
            dueDate: Date(),
            note: ""
        )

        XCTAssertEqual(renewal.displayName, "License plate")
    }
}
