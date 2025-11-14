import SwiftUI
import CoreData

struct MedicationListView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Medication.name, ascending: true)],
        animation: .default)
    private var medications: FetchedResults<Medication>

    @State private var showAddMedication: Bool = false

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Dashboard (placeholder)")
                    .font(.headline)
                    .padding(.horizontal)

                List {
                    ForEach(medications, id: \.objectID) { med in
                        NavigationLink(destination: MedicationDetailView(medication: med)) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(med.name ?? "Untitled Medication")
                                    .font(.body)
                                if let dosage = med.dosage, !dosage.isEmpty {
                                    Text(dosage)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationBarTitle("Medali", displayMode: .inline)
            .navigationBarItems(trailing: Button(action: {
                showAddMedication = true
            }, label: {
                Image(systemName: "plus")
            }))
        }
        .sheet(isPresented: $showAddMedication) {
            AddMedicationView()
                .environment(\.managedObjectContext, viewContext)
        }
    }
}

struct MedicationListView_Previews: PreviewProvider {
    static var previews: some View {
        MedicationListView()
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
    }
}
