import Foundation
import CoreData

final class MedicationDetailVM: ObservableObject {
    func logDose(context: NSManagedObjectContext, medication: Medication, taken: Bool, note: String?) {
        let log = DoseLog(context: context)
        log.timestamp = Date()
        log.taken = taken
        log.note = (note?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == true) ? nil : note
        log.medication = medication
        do {
            try context.save()
        } catch {
            print("Failed to save dose log: \(error)")
        }
    }
}
