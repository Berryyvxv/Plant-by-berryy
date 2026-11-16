import SwiftUI
import Playgrounds

struct ContentView: View {
    @State private var viewModel = PlantsViewModel()
    @State private var showingSetReminder = false
    // The plant being edited; setting it presents the edit sheet, nil dismisses it
    @State private var plantToEdit: Plant?
    // The plant waiting for delete confirmation; non-nil shows the dialog
    @State private var plantToDelete: Plant?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("My Plants 🌱")
                .font(.largeTitle.bold())
                .padding(.horizontal)

            Rectangle()
                .fill(PlantColors.headerDivider)
                .frame(height: 1)
                .padding(.horizontal)
                .padding(.top, 8)

            if viewModel.isEmpty {
                EmptyStateView { showingSetReminder = true }
            } else {
                progressHeader

                List(viewModel.plants) { plant in
                    // Swiping left reveals the trash pill; tapping it asks for confirmation
                    SwipeToDeleteRow(onDelete: { plantToDelete = plant }) {
                        PlantRowView(plant: plant) { viewModel.toggleWatered(plant) }
                            .contentShape(Rectangle())
                            .onTapGesture { plantToEdit = plant }
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
        .background(PlantColors.background.ignoresSafeArea())
        .overlay(alignment: .bottomTrailing) {
            if !viewModel.isEmpty {
                addButton
            }
        }
        .sheet(isPresented: $showingSetReminder) {
            SetReminderView { plant in
                viewModel.add(plant)
            }
        }
        .confirmationDialog(
            "Delete \(plantToDelete?.name ?? "plant")?",
            isPresented: Binding(
                get: { plantToDelete != nil },
                set: { if !$0 { plantToDelete = nil } }
            ),
            titleVisibility: .visible,
            presenting: plantToDelete
        ) { plant in
            Button("Delete", role: .destructive) {
                viewModel.delete(plant)
            }
        } message: { _ in
            Text("This reminder will be permanently deleted. This can't be undone.")
        }
        .sheet(item: $plantToEdit) { plant in
            SetReminderView(
                plant: plant,
                onSave: { viewModel.update($0) },
                onDelete: { viewModel.delete(plant) }
            )
        }
    }

    // MARK: - Subviews

    private var progressMessage: String {
        viewModel.wateredTodayCount == 0
            ? "Your plants are waiting for a sip 💦"
            : "\(viewModel.wateredTodayCount) of your plants feel loved today ✨"
    }

    private var progressHeader: some View {
        VStack(spacing: 12) {
            Text(progressMessage)
                .font(.system(size: 18))
                .tracking(0.23)
                .foregroundStyle(.primary)

            // Grey track with a green fill that grows as plants get watered
            RoundedRectangle(cornerRadius: 4)
                .fill(PlantColors.progressTrack)
                .frame(height: 8)
                .overlay(alignment: .leading) {
                    GeometryReader { proxy in
                        RoundedRectangle(cornerRadius: 4)
                            .fill(PlantColors.progressFill)
                            .frame(width: proxy.size.width * viewModel.wateredTodayProgress)
                    }
                }
                .animation(.easeInOut, value: viewModel.wateredTodayProgress)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 33)
        .padding(.vertical, 24)
        .accessibilityElement(children: .combine)
    }

    private var addButton: some View {
        Button("Add plant", systemImage: "plus") { showingSetReminder = true }
            .labelStyle(.iconOnly)
            .font(.title2.weight(.semibold))
            .foregroundStyle(.white)
            .frame(width: 44, height: 44)
            // Liquid Glass tinted with the design's green; interactive() 
            .glassEffect(.regular.tint(PlantColors.addButton).interactive(), in: .circle)
            .padding(.trailing, 30)
            .padding(.bottom, 40)
    }
}

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}

#Playground {
    _ = 1 + 2
}
