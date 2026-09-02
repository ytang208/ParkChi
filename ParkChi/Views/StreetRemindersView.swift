import SwiftUI

struct StreetRemindersView: View {
    @EnvironmentObject private var store: AppStore
    @State private var isAdding = false

    var body: some View {
        List {
            Section {
                if store.streetReminders.isEmpty {
                    EmptyFeatureView(
                        symbol: "signpost.right.and.left.fill",
                        title: "No street reminders",
                        message: "Add the date printed on the sign near your regular parking spot."
                    )
                    .listRowBackground(Color.clear)
                } else {
                    ForEach(store.streetReminders) { reminder in
                        StreetReminderRow(reminder: reminder)
                    }
                    .onDelete(perform: store.deleteStreetReminders)
                }
            } footer: {
                Text("Schedules can change. Verify temporary and permanent signs before parking.")
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Street Reminders")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { isAdding = true } label: { Image(systemName: "plus") }
                    .accessibilityLabel("Add street reminder")
            }
        }
        .sheet(isPresented: $isAdding) { AddStreetReminderView() }
    }
}

private struct StreetReminderRow: View {
    let reminder: StreetReminder

    var body: some View {
        HStack(spacing: 14) {
            VStack(spacing: 1) {
                Text(reminder.date.formatted(.dateTime.month(.abbreviated)))
                    .font(.caption.bold())
                    .foregroundStyle(Color.parkChiRed)
                Text(reminder.date.formatted(.dateTime.day()))
                    .font(.title2.bold())
            }
            .frame(width: 46, height: 50)
            .background(Color.parkChiSky)
            .clipShape(RoundedRectangle(cornerRadius: 11))

            VStack(alignment: .leading, spacing: 4) {
                Text(reminder.title).font(.headline)
                Text(reminder.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.subheadline).foregroundStyle(.secondary)
                if !reminder.details.isEmpty {
                    Text(reminder.details).font(.caption).foregroundStyle(.secondary)
                }
            }
            Spacer()
            if reminder.repeatRule == .weekly {
                Image(systemName: "repeat").foregroundStyle(Color.parkChiBlue)
                    .accessibilityLabel("Repeats weekly")
            }
        }
        .padding(.vertical, 4)
    }
}

private struct AddStreetReminderView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss
    @State private var title = "Street cleaning"
    @State private var details = ""
    @State private var date = Date().addingTimeInterval(86400)
    @State private var repeatRule: ReminderRepeat = .never

    var body: some View {
        NavigationStack {
            Form {
                Section("Reminder") {
                    TextField("Title", text: $title)
                    TextField("Block, zone, or sign details", text: $details, axis: .vertical)
                    DatePicker("Date and time", selection: $date, in: Date()...)
                    Picker("Repeat", selection: $repeatRule) {
                        ForEach(ReminderRepeat.allCases) { rule in
                            Text(rule.label).tag(rule)
                        }
                    }
                }

                Section {
                    Button("Add Reminder") {
                        store.addStreetReminder(
                            StreetReminder(
                                title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                                details: details.trimmingCharacters(in: .whitespacesAndNewlines),
                                date: date,
                                repeatRule: repeatRule
                            )
                        )
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .frame(maxWidth: .infinity)
                    .fontWeight(.semibold)
                }
            }
            .navigationTitle("New Street Reminder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
