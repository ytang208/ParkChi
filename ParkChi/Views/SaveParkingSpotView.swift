import CoreLocation
import PhotosUI
import SwiftUI
import UIKit

struct SaveParkingSpotView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss
    @StateObject private var locationCapture = LocationCapture()

    @State private var note: String
    @State private var hasMoveTime: Bool
    @State private var moveBy: Date
    @State private var photoItem: PhotosPickerItem?
    @State private var photoData: Data?
    @State private var existingPhotoFilename: String?

    init(existingSpot: ParkingSpot?) {
        _note = State(initialValue: existingSpot?.note ?? "")
        _hasMoveTime = State(initialValue: existingSpot?.moveBy != nil)
        _moveBy = State(initialValue: existingSpot?.moveBy ?? Date().addingTimeInterval(3600))
        _existingPhotoFilename = State(initialValue: existingSpot?.photoFilename)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Where did you park?") {
                    TextField("Example: West side of Damen near Waveland", text: $note, axis: .vertical)
                        .lineLimit(2...4)
                    Button {
                        locationCapture.requestCurrentLocation()
                    } label: {
                        HStack {
                            Label("Use Current Location", systemImage: "location.fill")
                            Spacer()
                            if locationCapture.isLoading { ProgressView() }
                            if locationCapture.coordinate != nil {
                                Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                            }
                        }
                    }
                    Text(locationCapture.statusMessage)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Section("Parking sign") {
                    PhotosPicker(selection: $photoItem, matching: .images) {
                        Label(photoData == nil && existingPhotoFilename == nil ? "Add Sign Photo" : "Replace Sign Photo", systemImage: "camera.fill")
                    }
                    .onChange(of: photoItem) { _, newItem in
                        Task { photoData = try? await newItem?.loadTransferable(type: Data.self) }
                    }

                    if let image = previewImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 240)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }

                Section {
                    Toggle("Remind me to move", isOn: $hasMoveTime)
                    if hasMoveTime {
                        DatePicker("Move by", selection: $moveBy, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                    }
                } header: {
                    Text("Move reminder")
                } footer: {
                    Text("The reminder is stored on this iPhone. Delivery depends on notification settings.")
                }

                Section {
                    Button("Save Parking Spot") { save() }
                        .frame(maxWidth: .infinity)
                        .fontWeight(.semibold)
                }
            }
            .navigationTitle("Save Parking Spot")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private var previewImage: UIImage? {
        if let photoData { return UIImage(data: photoData) }
        guard let existingPhotoFilename,
              let data = ImageStore.shared.load(filename: existingPhotoFilename)
        else { return nil }
        return UIImage(data: data)
    }

    private func save() {
        var filename = existingPhotoFilename
        if let photoData, let savedFilename = ImageStore.shared.save(photoData) {
            filename = savedFilename
        }
        let coordinate = locationCapture.coordinate
        let spot = ParkingSpot(
            note: note.trimmingCharacters(in: .whitespacesAndNewlines),
            moveBy: hasMoveTime ? moveBy : nil,
            latitude: coordinate?.latitude ?? store.parkingSpot?.latitude,
            longitude: coordinate?.longitude ?? store.parkingSpot?.longitude,
            photoFilename: filename
        )
        store.saveParkingSpot(spot)
        dismiss()
    }
}
