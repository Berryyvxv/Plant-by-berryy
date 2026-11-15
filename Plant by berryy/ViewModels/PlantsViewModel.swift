import Foundation
import Observation


@Observable
final class PlantsViewModel {
    private(set) var plants: [Plant] = []

    var isEmpty: Bool {
        plants.isEmpty
    }

    func add(_ plant: Plant) {
        plants.append(plant)
    }
}
