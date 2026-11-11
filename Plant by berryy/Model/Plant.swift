import Foundation

enum Room: String, CaseIterable, Identifiable {
    case bedroom = "Bedroom"
    case livingRoom = "Living Room"
    case kitchen = "Kitchen"
    case balcony = "Balcony"
    case bathroom = "Bathroom"

    var id: String { rawValue }
}

enum Light: String, CaseIterable, Identifiable {
    case fullSun = "Full Sun"
    case partialSun = "Partial Sun"
    case lowLight = "Low Light"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .fullSun: "sun.max"
        case .partialSun: "sun.horizon"
        case .lowLight: "moon"
        }
    }
}

enum WaterAmount: String, CaseIterable, Identifiable {
    case small = "20-50 ml"
    case medium = "50-100 ml"
    case large = "100-200 ml"
    case extraLarge = "200-300 ml"

    var id: String { rawValue }
}

// Raw value = number of days between waterings
enum WateringFrequency: Int, CaseIterable, Identifiable {
    case everyDay = 1
    case every2Days = 2
    case every3Days = 3
    case onceAWeek = 7
    case every10Days = 10
    case every2Weeks = 14

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .everyDay: "Every day"
        case .every2Days: "Every 2 days"
        case .every3Days: "Every 3 days"
        case .onceAWeek: "Once a week"
        case .every10Days: "Every 10 days"
        case .every2Weeks: "Every 2 weeks"
        }
    }
}

struct Plant: Identifiable {
    let id: UUID
    var name: String
    var room: Room
    var light: Light
    var waterAmount: WaterAmount
    var wateringFrequency: WateringFrequency
    var lastWateredDate: Date?

    init(
        id: UUID = UUID(),
        name: String,
        room: Room = .bedroom,
        light: Light = .fullSun,
        waterAmount: WaterAmount = .small,
        wateringFrequency: WateringFrequency = .everyDay,
        lastWateredDate: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.room = room
        self.light = light
        self.waterAmount = waterAmount
        self.wateringFrequency = wateringFrequency
        self.lastWateredDate = lastWateredDate
    }

    var isWatered: Bool {
        guard let lastWateredDate else { return false }
        return Calendar.current.isDateInToday(lastWateredDate)
    }
}
