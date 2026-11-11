import Foundation
import Observation

// Holds the list of plants and the actions the screens can perform on it.
// It doesn't import SwiftUI, so it knows nothing about how things look.
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
