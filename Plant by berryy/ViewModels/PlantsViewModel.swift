import Foundation
import Observation
import OSLog

@Observable
final class PlantsViewModel {
    private(set) var plants: [Plant]

    private let store: PlantStore
    private let reminders: NotificationService
    private let logger = Logger(subsystem: "Plant by berryy", category: "PlantsViewModel")

    init(store: PlantStore = PlantStore(), reminders: NotificationService = .shared) {
        self.store = store
        self.reminders = reminders

        do {
            plants = try store.load()
        } catch {
            logger.error("Could not load plants: \(error.localizedDescription)")
            plants = []
        }

        // Plants saved before reminders existed (or whose reminder was lost) get one now
        let savedPlants = plants
        Task { await reminders.scheduleMissingReminders(for: savedPlants) }
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
        scheduleReminder(for: plant)
    }

    // Replaces the saved plant that has the same id
    func update(_ plant: Plant) {
        guard let index = plants.firstIndex(where: { $0.id == plant.id }) else { return }
        plants[index] = plant
        persist()
        // The watering frequency may have changed, so the reminder is rescheduled
        scheduleReminder(for: plant)
    }

    // Tapping the check marks the plant watered now; tapping again undoes it
    func toggleWatered(_ plant: Plant) {
        guard let index = plants.firstIndex(where: { $0.id == plant.id }) else { return }
        plants[index].lastWateredDate = plant.isWatered ? nil : Date()
        persist()
        // Watering restarts the countdown to the next reminder
        scheduleReminder(for: plants[index])
    }

    func delete(_ plant: Plant) {
        plants.removeAll { $0.id == plant.id }
        persist()
        reminders.cancelReminder(for: plant)
    }

    // The service call is async (it may show the permission prompt), so it runs in a Task
    private func scheduleReminder(for plant: Plant) {
        Task { await reminders.scheduleReminder(for: plant) }
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
