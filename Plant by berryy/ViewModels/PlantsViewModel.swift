import Foundation
import Observation
import OSLog

@Observable
final class PlantsViewModel {
    private(set) var plants: [Plant]

    private let store: PlantStore
    private let logger = Logger(subsystem: "Plant by berryy", category: "PlantsViewModel")

    init(store: PlantStore = PlantStore()) {
        self.store = store

        do {
            plants = try store.load()
        } catch {
            logger.error("Could not load plants: \(error.localizedDescription)")
            plants = []
        }
    }

    var isEmpty: Bool {
        plants.isEmpty
    }

    var wateredTodayCount: Int {
        plants.filter(\.isWatered).count
    }

    // 0...1 for the progress bar; 0 when there are no plants so we never divide by zero
    var wateredTodayProgress: Double {
        guard !plants.isEmpty else { return 0 }
        return Double(wateredTodayCount) / Double(plants.count)
    }

    func add(_ plant: Plant) {
        plants.append(plant)
        persist()
    }

    // Tapping the check marks the plant watered now; tapping again undoes it
    func toggleWatered(_ plant: Plant) {
        guard let index = plants.firstIndex(where: { $0.id == plant.id }) else { return }
        plants[index].lastWateredDate = plant.isWatered ? nil : Date()
        persist()
    }

    func delete(_ plant: Plant) {
        plants.removeAll { $0.id == plant.id }
        persist()
    }

    // Every change saves immediately, so nothing is lost if the app is killed
    private func persist() {
        do {
            try store.save(plants)
        } catch {
            logger.error("Could not save plants: \(error.localizedDescription)")
        }
    }
}
