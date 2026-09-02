import MapKit
import SwiftUI

struct ParkingHomeView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.openURL) private var openURL
    @State private var isShowingSaveSheet = false
    @State private var isConfirmingClear = false
    @State private var cameraPosition: MapCameraPosition = .region(Self.chicagoRegion)

    var body: some View {
        Map(position: $cameraPosition) {
            if let coordinate = savedCoordinate {
                Marker("Parked Car", systemImage: "car.fill", coordinate: coordinate)
                    .tint(Color.parkChiBlue)
            }
        }
        .mapStyle(.standard)
        .mapControls {
            MapCompass()
            MapScaleView()
        }
        .overlay(alignment: .topLeading) {
            Label(
                store.parkingSpot == nil ? "Chicago" : "Your parked car",
                systemImage: store.parkingSpot == nil ? "building.2.fill" : "mappin.and.ellipse"
            )
            .font(.subheadline.weight(.semibold))
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(.regularMaterial, in: Capsule())
            .shadow(color: .black.opacity(0.12), radius: 8, y: 3)
            .padding()
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            parkingPanel
                .padding(.horizontal)
                .padding(.bottom, 8)
        }
        .navigationTitle("ParkChi")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(store.parkingSpot == nil ? "Save Spot" : "Update") {
                    isShowingSaveSheet = true
                }
                .fontWeight(.semibold)
            }
        }
        .sheet(isPresented: $isShowingSaveSheet) {
            SaveParkingSpotView(existingSpot: store.parkingSpot)
        }
        .confirmationDialog("Clear this parking spot?", isPresented: $isConfirmingClear) {
            Button("Clear Spot", role: .destructive) { store.clearParkingSpot() }
        }
        .onAppear { focusMap(on: store.parkingSpot) }
        .onChange(of: store.parkingSpot) { _, spot in focusMap(on: spot) }
    }

    @ViewBuilder
    private var parkingPanel: some View {
        if let spot = store.parkingSpot {
            savedSpotPanel(spot)
        } else {
            ParkChiCard {
                VStack(alignment: .leading, spacing: 14) {
                    Label("Where did you park?", systemImage: "car.fill")
                        .font(.title3.bold())

                    Text("Save your car's location and it will appear as a pin on this map.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Button {
                        isShowingSaveSheet = true
                    } label: {
                        Label("Save My Parking Spot", systemImage: "mappin.circle.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }
            }
        }
    }

    private func savedSpotPanel(_ spot: ParkingSpot) -> some View {
        ParkChiCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .firstTextBaseline) {
                    Label("Car saved", systemImage: "checkmark.circle.fill")
                        .font(.headline)
                        .foregroundStyle(.green)
                    Spacer()
                    Text(spot.savedAt, style: .relative)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if !spot.note.isEmpty {
                    Text(spot.note)
                        .font(.title3.weight(.semibold))
                        .lineLimit(2)
                }

                if let moveBy = spot.moveBy {
                    Label {
                        Text("Move by \(moveBy.formatted(date: .abbreviated, time: .shortened))")
                            .fontWeight(.semibold)
                    } icon: {
                        Image(systemName: "timer")
                            .foregroundStyle(Color.parkChiRed)
                    }
                    .font(.subheadline)
                }

                HStack {
                    if let latitude = spot.latitude, let longitude = spot.longitude {
                        Button {
                            guard let url = URL(string: "http://maps.apple.com/?ll=\(latitude),\(longitude)&q=Parked%20Car") else { return }
                            openURL(url)
                        } label: {
                            Label("Directions", systemImage: "arrow.triangle.turn.up.right.diamond.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                    }

                    Button(role: .destructive) {
                        isConfirmingClear = true
                    } label: {
                        Label("Clear", systemImage: "trash")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }

                Text("Always check posted parking signs.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var savedCoordinate: CLLocationCoordinate2D? {
        guard let latitude = store.parkingSpot?.latitude,
              let longitude = store.parkingSpot?.longitude
        else { return nil }
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    private func focusMap(on spot: ParkingSpot?) {
        guard let latitude = spot?.latitude, let longitude = spot?.longitude else {
            cameraPosition = .region(Self.chicagoRegion)
            return
        }

        cameraPosition = .region(
            MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                span: MKCoordinateSpan(latitudeDelta: 0.008, longitudeDelta: 0.008)
            )
        )
    }

    private static let chicagoRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 41.8781, longitude: -87.6298),
        span: MKCoordinateSpan(latitudeDelta: 0.16, longitudeDelta: 0.16)
    )
}
