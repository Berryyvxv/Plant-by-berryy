import SwiftUI

struct SetReminderView: View {
    @Environment(\.dismiss) private var dismiss

    // Called with the new plant when the user taps the checkmark
    let onSave: (Plant) -> Void

    // Form values live only inside this sheet until the checkmark is tapped,
    // so tapping the X throws them away automatically
    @State private var name = ""
    @State private var room: Room = .bedroom
    @State private var light: Light = .fullSun
    @State private var waterAmount: WaterAmount = .small
    @State private var wateringDays = Set(Weekday.allCases)
    @State private var showNameError = false

    private let accent = Color(red: 0.18, green: 0.5, blue: 0.38)

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    nameSection
                    roomAndLightSection
                    wateringSection
                }
                .padding()
            }
            .navigationTitle("Set Reminder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", systemImage: "xmark") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", systemImage: "checkmark", action: save)
                        .tint(accent)
                }
            }
        }
    }

    // MARK: - Sections

    private var nameSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Plant Name")
                TextField("Pothos", text: $name)
            }
            .padding()
            .background(.primary.opacity(0.08), in: RoundedRectangle(cornerRadius: 20))

            if showNameError {
                Text("Please enter a plant name")
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .padding(.leading)
            }
        }
        .onChange(of: name) { showNameError = false }
    }

    private var roomAndLightSection: some View {
        VStack(spacing: 12) {
            Picker(selection: $room) {
                ForEach(Room.allCases) { Text($0.rawValue).tag($0) }
            } label: {
                Label("Room", systemImage: "location")
            }

            Divider()

            Picker(selection: $light) {
                ForEach(Light.allCases) { Text($0.rawValue).tag($0) }
            } label: {
                Label("Light", systemImage: "sun.max")
            }
        }
        .pickerStyle(.menu)
        .padding()
        .background(.primary.opacity(0.08), in: RoundedRectangle(cornerRadius: 20))
    }

    private var wateringSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Watering Days", systemImage: "drop")

            HStack(spacing: 0) {
                ForEach(Weekday.allCases) { day in
                    dayButton(day)
                }
            }

            Divider()

            Picker(selection: $waterAmount) {
                ForEach(WaterAmount.allCases) { Text($0.rawValue).tag($0) }
            } label: {
                Label("Water", systemImage: "drop")
            }
            .pickerStyle(.menu)
        }
        .padding()
        .background(.primary.opacity(0.08), in: RoundedRectangle(cornerRadius: 20))
    }

    // One round button per weekday; tapping it adds or removes the day
    private func dayButton(_ day: Weekday) -> some View {
        let isOn = wateringDays.contains(day)

        return Button {
            if isOn {
                wateringDays.remove(day)
            } else {
                wateringDays.insert(day)
            }
        } label: {
            // Weekday's raw value (Sunday = 1) lines up with Calendar's symbol lists
            Text(Calendar.current.veryShortWeekdaySymbols[day.rawValue - 1])
                .font(.subheadline.bold())
                .foregroundStyle(isOn ? .white : .primary)
                .frame(width: 36, height: 36)
                .background(isOn ? accent : .primary.opacity(0.1), in: Circle())
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Calendar.current.weekdaySymbols[day.rawValue - 1])
        .accessibilityAddTraits(isOn ? .isSelected : [])
    }

    // MARK: - Actions

    private func save() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)

        guard !trimmedName.isEmpty else {
            showNameError = true
            return
        }

        onSave(Plant(
            name: trimmedName,
            room: room,
            light: light,
            waterAmount: waterAmount,
            wateringDays: wateringDays
        ))
        dismiss()
    }
}

#Preview {
    SetReminderView { _ in }
}
