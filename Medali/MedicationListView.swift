import SwiftUI
import CoreData

struct MedicationListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var healthKitService: HealthKitService
    @EnvironmentObject var notificationService: NotificationService
    @StateObject private var listVM = MedicationListVM()

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Medication.name, ascending: true)],
        animation: .default)
    private var medications: FetchedResults<Medication>

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \DoseLog.timestamp, ascending: false)],
        animation: .default)
    private var allLogs: FetchedResults<DoseLog>

    @State private var showAddMedication: Bool = false

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Today’s steps")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(Int(healthKitService.todayStepCount))")
                            .font(.title2)
                            .bold()
                    }
                    Spacer()
                    VStack(spacing: 8) {
                        AdherenceRingView(progress: overallAdherence)
                            .frame(width: 100, height: 100)
                        Text("Overall adherence")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Dashboard header. Today's steps \(Int(healthKitService.todayStepCount)). Overall adherence \(Int(overallAdherence * 100)) percent.")

                List {
                    ForEach(medications, id: \.objectID) { med in
                        NavigationLink(destination: MedicationDetailView(medication: med)) {
                            PillCard(
                                medication: med,
                                color: listVM.color(from: med.colorHex ?? ""),
                                timesText: listVM.formattedTimes(for: med)
                            )
                        }
                    }
                    .onDelete(perform: deleteMedications)
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

    private var overallAdherence: Double {
        guard !allLogs.isEmpty else { return 0 }
        let taken = allLogs.reduce(0) { $0 + ($1.taken ? 1 : 0) }
        return Double(taken) / Double(allLogs.count)
    }

    private func deleteMedications(at offsets: IndexSet) {
        let medsToDelete = offsets.map { medications[$0] }
        for med in medsToDelete {
            // Build times from DoseTime children
            var times: [(Int, Int)] = []
            if let context = med.managedObjectContext {
                let req: NSFetchRequest<DoseTime> = DoseTime.fetchRequest()
                req.predicate = NSPredicate(format: "medication == %@", med)
                do {
                    let doseTimes = try context.fetch(req)
                    times = doseTimes.map { (Int($0.hour), Int($0.minute)) }
                } catch {
                    print("Failed to fetch dose times for deletion: \(error)")
                }
            }

            if let id = med.id?.uuidString {
                notificationService.cancelNotifications(for: id, times: times)
            }

            viewContext.delete(med)
        }

        do {
            try viewContext.save()
        } catch {
            print("Failed to delete medications: \(error)")
        }
    }
}

struct MedicationListView_Previews: PreviewProvider {
    static var previews: some View {
        MedicationListView()
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
    }
}
