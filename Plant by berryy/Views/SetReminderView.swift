import SwiftUI

struct SetReminderView: View {
    @Environment(\.dismiss) private var dismiss

    // nil = adding a new plant, otherwise editing this one
    let plant: Plant?
    let onSave: (Plant) -> Void
    // Only passed when editing; its presence shows the Delete button
    let onDelete: (() -> Void)?

    @State private var name: String
    @State private var room: Room
    @State private var light: Light
    @State private var waterAmount: WaterAmount
    @State private var wateringFrequency: WateringFrequency
    @State private var showNameError = false
    @State private var showDeleteConfirmation = false

    private let accent = Color(red: 0.18, green: 0.5, blue: 0.38)

    // The fields start from the plant's current values, so the sheet edits a copy
    init(plant: Plant? = nil, onSave: @escaping (Plant) -> Void, onDelete: (() -> Void)? = nil) {
        self.plant = plant
        self.onSave = onSave
        self.onDelete = onDelete
        _name = State(initialValue: plant?.name ?? "")
        _room = State(initialValue: plant?.room ?? .bedroom)
        _light = State(initialValue: plant?.light ?? .fullSun)
        _waterAmount = State(initialValue: plant?.waterAmount ?? .small)
        _wateringFrequency = State(initialValue: plant?.wateringFrequency ?? .everyDay)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    nameSection
                    roomAndLightSection
                    wateringSection

                    if onDelete != nil {
                        deleteButton
                    }
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

    private var deleteButton: some View {
        Button("Delete Reminder", role: .destructive) {
            showDeleteConfirmation = true
        }
        .foregroundStyle(.red)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(.primary.opacity(0.08), in: Capsule())
        .padding(.horizontal, 8)
        .padding(.top, 20)
        .confirmationDialog("Delete \(plant?.name ?? "this plant")?", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                onDelete?()
                dismiss()
            }
        } message: {
            Text("Are you certain you want to delete ?")
        }
    }

    // MARK: - Actions

    private func save() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)

        guard !trimmedName.isEmpty else {
            showNameError = true
            return
        }

        // Keep the id and watering date when editing, so the plant stays the same plant
        onSave(Plant(
            id: plant?.id ?? UUID(),
            name: trimmedName,
            room: room,
            light: light,
            waterAmount: waterAmount,
            wateringFrequency: wateringFrequency,
            lastWateredDate: plant?.lastWateredDate
        ))
        dismiss()
    }
}

#Preview {
    SetReminderView { _ in }
}
