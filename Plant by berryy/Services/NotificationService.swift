import Foundation
import OSLog
import UserNotifications

// Schedules the "time to water" reminders with iOS.
// Like PlantStore, it knows nothing about SwiftUI. The view model decides WHEN to call it.
final class NotificationService: NSObject, UNUserNotificationCenterDelegate {
    // One shared instance: the center only keeps a weak reference to its delegate,
    // so this object must live for the whole app lifetime or banners stop appearing.
    static let shared = NotificationService()

    private let center = UNUserNotificationCenter.current()
    private let logger = Logger(subsystem: "Plant by berryy", category: "NotificationService")

    private override init() {
        super.init()
        center.delegate = self
    }

    // MARK: - Permission

    // Asks the user for permission the first time only; afterwards just reports the current answer
    func requestAuthorizationIfNeeded() async -> Bool {
        let settings = await center.notificationSettings()

        switch settings.authorizationStatus {
        case .notDetermined:
            do {
                return try await center.requestAuthorization(options: [.alert, .sound])
            } catch {
                logger.error("Notification permission request failed: \(error.localizedDescription)")
                return false
            }
        case .authorized, .provisional, .ephemeral:
            return true
        default:
            return false
        }
    }

    // MARK: - Scheduling

    // Replaces the plant's reminder: it will fire after one full watering interval, then repeat.
    // The plant's id is the request identifier, so scheduling again overwrites the old one.
    func scheduleReminder(for plant: Plant) async {
        guard await requestAuthorizationIfNeeded() else { return }

        // A new reminder replaces any banner still sitting in Notification Center
        center.removeDeliveredNotifications(withIdentifiers: [plant.id.uuidString])
        await add(plant)
    }

    // Used at launch: schedules reminders only for plants that don't have one yet,
    // so opening the app never pushes existing reminders further away.
    func scheduleMissingReminders(for plants: [Plant]) async {
        guard !plants.isEmpty, await requestAuthorizationIfNeeded() else { return }

        let pendingIDs = Set(await center.pendingNotificationRequests().map(\.identifier))
        for plant in plants where !pendingIDs.contains(plant.id.uuidString) {
            await add(plant)
        }
    }

    func cancelReminder(for plant: Plant) {
        let ids = [plant.id.uuidString]
        center.removePendingNotificationRequests(withIdentifiers: ids)
        center.removeDeliveredNotifications(withIdentifiers: ids)
    }

    private func add(_ plant: Plant) async {
        let content = UNMutableNotificationContent()
        content.title = "Planto"
        content.body = "Hey! let's water your plant"
        content.sound = .default

        // The raw value of WateringFrequency is the number of days between waterings
        let seconds = TimeInterval(plant.wateringFrequency.rawValue * 24 * 60 * 60)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: true)

        let request = UNNotificationRequest(
            identifier: plant.id.uuidString,
            content: content,
            trigger: trigger
        )

        do {
            try await center.add(request)
        } catch {
            logger.error("Could not schedule reminder: \(error.localizedDescription)")
        }
    }

    // MARK: - UNUserNotificationCenterDelegate

    // By default iOS hides notifications while the app is open. This shows the banner anyway.
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound]
    }
}
