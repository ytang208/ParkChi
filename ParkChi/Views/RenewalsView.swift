import SwiftUI

struct RenewalsView: View {
    @EnvironmentObject private var store: AppStore
    @State private var isAdding = false

    var body: some View {
        List {
            Section {
                if store.renewals.isEmpty {
                    EmptyFeatureView(
                        symbol: "calendar.badge.clock",
                        title: "No renewals saved",
                        message: "Keep vehicle deadlines together and get reminders before they arrive."
                    )
                    .listRowBackground(Color.clear)
                } else {
                    ForEach(store.renewals) { renewal in
                        RenewalRow(renewal: renewal)
                    }
                    .onDelete(perform: store.deleteRenewals)
                }
            } footer: {
                Text("ParkChi sends reminders 30, 7, and 1 day before each future deadline. Verify dates with the issuing agency.")
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Vehicle Renewals")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { isAdding = true } label: { Image(systemName: "plus") }
                    .accessibilityLabel("Add renewal")
            }
        }
        .sheet(isPresented: $isAdding) { AddRenewalView() }
    }
}

private struct RenewalRow: View {
    let renewal: RenewalReminder

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: renewal.kind.symbol)
                .font(.title2)
                .foregroundStyle(Color.parkChiBlue)
                .frame(width: 38, height: 38)
                .background(Color.parkChiSky)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(renewal.displayName).font(.headline)
                Text("Due \(renewal.dueDate.formatted(date: .abbreviated, time: .omitted))")
                    .font(.subheadline)
                    .foregroundStyle(isUrgent ? Color.parkChiRed : Color.secondary)
                if !renewal.note.isEmpty {
                    Text(renewal.note).font(.caption).foregroundStyle(.secondary)
                }
            }
            Spacer()
        }
        .padding(.vertical, 4)
    }

    private var isUrgent: Bool {
        renewal.dueDate.timeIntervalSinceNow < 2_592_000
    }
}

private struct AddRenewalView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss
    @State private var kind: RenewalKind = .citySticker
    @State private var customName = ""
    @State private var dueDate = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
    @State private var note = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Vehicle deadline") {
                    Picker("Type", selection: $kind) {
                        ForEach(RenewalKind.allCases) { kind in
                            Label(kind.label, systemImage: kind.symbol).tag(kind)
                        }
                    }
                    if kind == .other {
                        TextField("Reminder name", text: $customName)
                    }
                    DatePicker("Due date", selection: $dueDate, in: Date()..., displayedComponents: .date)
                    TextField("Optional note", text: $note, axis: .vertical)
                }

                Section {
                    Button("Save Renewal") {
                        store.addRenewal(
                            RenewalReminder(
                                kind: kind,
                                customName: customName.trimmingCharacters(in: .whitespacesAndNewlines),
                                dueDate: dueDate,
                                note: note.trimmingCharacters(in: .whitespacesAndNewlines)
                            )
                        )
                        dismiss()
                    }
                    .disabled(kind == .other && customName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .frame(maxWidth: .infinity)
                    .fontWeight(.semibold)
                }
            }
            .navigationTitle("New Renewal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
