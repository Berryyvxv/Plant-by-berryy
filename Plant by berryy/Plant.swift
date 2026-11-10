import Foundation

enum Room: String, CaseIterable, Identifiable {
    case bedroom = "Bedroom"
    case kitchen = "Kitchen"
    case livingRoom = "Living Room"

    var id: String { rawValue }
}

enum Light: String, CaseIterable, Identifiable {
    case fullSun = "Full sun"
    case partialSun = "Partial sun"
    case shade = "Shade"

    var id: String { rawValue }
}

enum WaterAmount: String, CaseIterable, Identifiable {
    case small = "20-50 ml"
    case medium = "50-100 ml"
    case large = "100-200 ml"

    var id: String { rawValue }
}

enum Weekday: Int, CaseIterable, Identifiable {
    case sunday = 1, monday, tuesday, wednesday, thursday, friday, saturday

    var id: Int { rawValue }
}

struct Plant: Identifiable {
    let id: UUID
    var name: String
    var room: Room
    var light: Light
    var waterAmount: WaterAmount
    var wateringDays: Set<Weekday>
    var lastWateredDate: Date?

    init(
        id: UUID = UUID(),
        name: String,
        room: Room = .bedroom,
        light: Light = .fullSun,
        waterAmount: WaterAmount = .small,
        wateringDays: Set<Weekday> = Set(Weekday.allCases),
        lastWateredDate: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.room = room
        self.light = light
        self.waterAmount = waterAmount
        self.wateringDays = wateringDays
        self.lastWateredDate = lastWateredDate
    }

    var isWatered: Bool {
        guard let lastWateredDate else { return false }
        return Calendar.current.isDateInToday(lastWateredDate)
    }
}
