import SwiftUI

struct SetReminderView: View {
    @Environment(\.dismiss) private var dismiss

    
    let onSave: (Plant) -> Void

    // Form values live only inside this sheet until the checkmark is tapped,
    // so tapping the X throws them away automatically
    @State private var name = ""
    @State private var room: Room = .bedroom
    @State private var light: Light = .fullSun
    @State private var waterAmount: WaterAmount = .small
    @State private var wateringFrequency: WateringFrequency = .everyDay
    @State private var showNameError = false

    private let accent = Color(red: 0.18, green: 0.5, blue: 0.38)

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    nameSection
                    roomAndLightSection
                    wateringSection
                }
                .padding()
            }
            .navigationTitle("Set Reminder")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
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
            HStack {
                Label("Room", systemImage: "location")
                Spacer()
                Picker("Room", selection: $room) {
                    ForEach(Room.allCases) { Text($0.rawValue).tag($0) }
                }
                .labelsHidden()
            }

            Divider()

            HStack {
                Label("Light", systemImage: "sun.max")
                Spacer()
                Picker("Light", selection: $light) {
                    ForEach(Light.allCases) { Label($0.rawValue, systemImage: $0.icon).tag($0) }
                }
                .labelsHidden()
            }
        }
        .pickerStyle(.menu)
        .tint(.secondary)
        .padding()
        .background(.primary.opacity(0.08), in: RoundedRectangle(cornerRadius: 20))
    }

    private var wateringSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Watering Days", systemImage: "drop")
                Spacer()
                Picker("Watering Days", selection: $wateringFrequency) {
                    ForEach(WateringFrequency.allCases) { Text($0.title).tag($0) }
                }
                .labelsHidden()
                .pickerStyle(.menu)
            }

            Divider()

            HStack {
                Label("Water", systemImage: "drop")
                Spacer()
                Picker("Water", selection: $waterAmount) {
                    ForEach(WaterAmount.allCases) { Text($0.rawValue).tag($0) }
                }
                .labelsHidden()
                .pickerStyle(.menu)
            }
        }
        .tint(.secondary)
        .padding()
        .background(.primary.opacity(0.08), in: RoundedRectangle(cornerRadius: 20))
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
            wateringFrequency: wateringFrequency
        ))
        dismiss()
    }
}

#Preview {
    SetReminderView { _ in }
}
