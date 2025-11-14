import Foundation
import UserNotifications
import Combine

final class NotificationService: ObservableObject {
    private let center: UNUserNotificationCenter

    init(center: UNUserNotificationCenter = UNUserNotificationCenter.current()) {
        self.center = center
    }

    func requestAuthorization() {
        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            if !granted {
                // No-op for now
            }
        }
    }

    // times: array of (hour, minute), 24-hour clock
    func scheduleDailyNotifications(for medicationID: String, name: String, times: [(Int, Int)]) {
        for (hour, minute) in times {
            let identifier = Self.identifier(medicationID: medicationID, hour: hour, minute: minute)

            let content = UNMutableNotificationContent()
            content.title = name
            content.body = "It's time to take your medication."
            content.sound = .default

            var dateComponents = DateComponents()
            dateComponents.hour = hour
            dateComponents.minute = minute

            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

            center.add(request) { error in
                if let error = error {
                    print("Failed to schedule notification \(identifier): \(error)")
                }
            }
        }
    }

    func cancelNotifications(for medicationID: String, times: [(Int, Int)]) {
        let identifiers = times.map { (hour, minute) in
            Self.identifier(medicationID: medicationID, hour: hour, minute: minute)
        }
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
        center.removeDeliveredNotifications(withIdentifiers: identifiers)
    }

    private static func identifier(medicationID: String, hour: Int, minute: Int) -> String {
        return "med.\(medicationID).\(hour)-\(minute)"
    }
}
