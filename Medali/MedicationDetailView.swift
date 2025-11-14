import SwiftUI
import CoreData

struct MedicationDetailView: View {
    @ObservedObject var medication: Medication

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(medication.name ?? "Untitled Medication")
                .font(.title2)
            if let dosage = medication.dosage, !dosage.isEmpty {
                Text(dosage)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding()
        .navigationBarTitle("Details", displayMode: .inline)
    }
}

struct MedicationDetailView_Previews: PreviewProvider {
    static var previews: some View {
        // Build a preview with an in-memory context and a sample Medication
        let context = PersistenceController.shared.container.viewContext
        let med = Medication(context: context)
        med.name = "Sample Med"
        med.dosage = "10 mg"
        return NavigationView { MedicationDetailView(medication: med) }
    }
}
