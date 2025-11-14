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

    func adherence(for medication: Medication) -> Double {
        guard let context = medication.managedObjectContext else { return 0 }
        let request: NSFetchRequest<DoseLog> = DoseLog.fetchRequest()
        request.predicate = NSPredicate(format: "medication == %@", medication)
        do {
            let logs = try context.fetch(request)
            guard !logs.isEmpty else { return 0 }
            let takenCount = logs.reduce(0) { $0 + ($1.taken ? 1 : 0) }
            return Double(takenCount) / Double(logs.count)
        } catch {
            print("Failed to fetch logs for adherence: \(error)")
            return 0
        }
    }
}
