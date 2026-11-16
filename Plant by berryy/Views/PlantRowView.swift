import SwiftUI

// One row in the plants list: watered check, room, name and care details
struct PlantRowView: View {
    let plant: Plant
    // Called when the user taps the check circle
    let onToggleWatered: () -> Void

    var body: some View {
        HStack(spacing: 24) {
            Button(action: onToggleWatered) {
                // Empty ring when not watered, filled green check when watered today
                if plant.isWatered {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 26))
                        .foregroundStyle(.black, PlantColors.checkedCircle)
                        .frame(width: 28, height: 28)
                } else {
                    Circle()
                        .strokeBorder(PlantColors.uncheckedCircle, lineWidth: 1.2)
                        .frame(width: 23, height: 23)
                        .frame(width: 28, height: 28)
                }
            }
            .buttonStyle(.plain)
            .accessibilityLabel(plant.isWatered ? "Watered today" : "Mark as watered")

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Image(systemName: "location")
                    Text("in \(plant.room.rawValue)")
                }
                .font(.system(size: 14))
                .foregroundStyle(PlantColors.locationText)

                Text(plant.name)
                    .font(.system(size: 24))
                    .foregroundStyle(plant.isWatered ? PlantColors.wateredName : .primary)

                HStack(spacing: 8) {
                    chip(plant.light.rawValue, systemImage: plant.light.icon, color: PlantColors.lightChipText)
                    chip(plant.waterAmount.rawValue, systemImage: "drop", color: PlantColors.waterChipText)
                }
            }
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(PlantColors.rowDivider)
                .frame(height: 1)
                .padding(.horizontal, 8)
        }
    }

    private func chip(_ text: String, systemImage: String, color: Color) -> some View {
        HStack(spacing: 5) {
            Image(systemName: systemImage)
            Text(text)
        }
        .font(.system(size: 13, weight: .medium))
        .foregroundStyle(color)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(PlantColors.chipBackground, in: RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    List {
        PlantRowView(plant: Plant(name: "Orchid", room: .livingRoom), onToggleWatered: {})
        PlantRowView(
            plant: Plant(name: "Spider", room: .kitchen, lastWateredDate: .now),
            onToggleWatered: {}
        )
    }
    .listStyle(.plain)
    .preferredColorScheme(.dark)
}
