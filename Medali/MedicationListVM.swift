import SwiftUI
import CoreData

final class MedicationListVM: ObservableObject {
    func color(from hex: String) -> Color {
        let cleaned = hex.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "#", with: "")
        guard cleaned.count == 6, let intVal = Int(cleaned, radix: 16) else {
            return Color.accentColor
        }
        let r = Double((intVal >> 16) & 0xFF) / 255.0
        let g = Double((intVal >> 8) & 0xFF) / 255.0
        let b = Double(intVal & 0xFF) / 255.0
        return Color(.sRGB, red: r, green: g, blue: b, opacity: 1)
    }

    func formattedTimes(for medication: Medication) -> String {
        guard let context = medication.managedObjectContext else { return "" }
        let req: NSFetchRequest<DoseTime> = DoseTime.fetchRequest()
        req.predicate = NSPredicate(format: "medication == %@", medication)
        do {
            let doseTimes = try context.fetch(req)
            let sorted = doseTimes.sorted { (a, b) in
                if a.hour == b.hour { return a.minute < b.minute }
                return a.hour < b.hour
            }
            let df = DateFormatter()
            df.locale = Locale.current
            df.dateFormat = "HH:mm"
            let parts = sorted.map { dt -> String in
                let comps = DateComponents(hour: Int(dt.hour), minute: Int(dt.minute))
                let cal = Calendar.current
                let date = cal.date(from: comps) ?? Date()
                return df.string(from: date)
            }
            return parts.joined(separator: " • ")
        } catch {
            return ""
        }
    }
}
