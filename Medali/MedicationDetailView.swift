import SwiftUI
import CoreData

struct MedicationDetailView: View {
    @ObservedObject var medication: Medication
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var vm = MedicationDetailVM()
    @State private var noteText: String = ""

    @FetchRequest private var logs: FetchedResults<DoseLog>

    init(medication: Medication) {
        self.medication = medication
        _logs = FetchRequest<DoseLog>(
            sortDescriptors: [NSSortDescriptor(keyPath: \DoseLog.timestamp, ascending: false)],
            predicate: NSPredicate(format: "medication == %@", medication),
            animation: .default
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(medication.name ?? "Untitled Medication")
                    .font(.title2)
                if let dosage = medication.dosage, !dosage.isEmpty {
                    Text(dosage)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                TextField("Optional note (e.g., 'Felt dizzy')", text: $noteText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                HStack(spacing: 12) {
                    Button(action: {
                        vm.logDose(context: viewContext, medication: medication, taken: true, note: noteText.isEmpty ? nil : noteText)
                        noteText = ""
                    }) {
                        Label("Taken", systemImage: "checkmark.circle.fill")
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.green)
                            .cornerRadius(8)
                    }

                    Button(action: {
                        vm.logDose(context: viewContext, medication: medication, taken: false, note: noteText.isEmpty ? nil : noteText)
                        noteText = ""
                    }) {
                        Label("Skip", systemImage: "xmark.circle.fill")
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.red)
                            .cornerRadius(8)
                    }
                }
            }

            Divider()

            Text("History")
                .font(.headline)

            List {
                ForEach(logs, id: \.objectID) { log in
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: (log.taken ? "checkmark.circle.fill" : "xmark.circle.fill"))
                            .foregroundColor(log.taken ? .green : .red)
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 4) {
                                Text(log.timestamp ?? Date(), style: .date)
                                Text(log.timestamp ?? Date(), style: .time)
                                    .foregroundColor(.secondary)
                            }
                            if let note = log.note, !note.isEmpty {
                                Text(note)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .listStyle(InsetGroupedListStyle())

            Spacer(minLength: 0)
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
