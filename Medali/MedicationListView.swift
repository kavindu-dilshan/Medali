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

    // MARK: - Init (UITableView appearance for iOS 14)

    init() {
        UITableView.appearance().backgroundColor = .clear        // list background transparent
        UITableViewCell.appearance().backgroundColor = .clear     // row background transparent
        UITableView.appearance().separatorStyle = .none           // hide default separators
    }

    // MARK: - Body

    var body: some View {
        NavigationView {
            ZStack {
                // Background colour from design
                Color(red: 240/255, green: 244/255, blue: 255/255)
                    .ignoresSafeArea()

                List {
                    // HEADER + SUMMARY
                    Section {
                        VStack(alignment: .leading, spacing: 24) {
                            header
                            summaryCards
                            Text("Your medicines")
                                .font(.system(size: 26, weight: .bold))
                                .padding(.top, 4)
                        }
                        .padding(.top, 24)
                        .padding(.bottom, 8)
                        .padding(.horizontal, 10)
                    }
                    .listRowBackground(Color.clear)

                    // MEDICINES
                    Section {
                        if medications.isEmpty {
                            Text("No medicines added yet.")
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 10)
                                .listRowBackground(Color.clear)
                        } else {
                            ForEach(medications, id: \.objectID) { med in
                                NavigationLink(destination: MedicationDetailView(medication: med)) {
                                    PillCard(
                                        medication: med,
                                        color: listVM.color(from: med.colorHex ?? ""),
                                        timesText: listVM.formattedTimes(for: med)
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                                .listRowInsets(EdgeInsets(top: 6, leading: 20, bottom: 6, trailing: 20))
                                .listRowBackground(Color.clear)
                            }
                            .onDelete(perform: deleteMedications)   // swipe to delete
                        }
                    }
                }
                .listStyle(PlainListStyle())
                .background(Color.clear)
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showAddMedication) {
            AddMedicationView()
                .environment(\.managedObjectContext, viewContext)
        }
    }

    // MARK: - Subviews

    private var header: some View {
        HStack(alignment: .center) {
            Text("Medali")
                .font(.system(size: 34, weight: .bold))

            Spacer()

            Button(action: {
                showAddMedication = true
            }) {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 56, height: 56)
                    Image(systemName: "plus")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.black)
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
    }

    private var summaryCards: some View {
        VStack(spacing: 16) {
            // Overall Progress card
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color(red: 77/255, green: 123/255, blue: 255/255))
                    Image(systemName: "pills.fill")
                        .foregroundColor(.white)
                        .font(.system(size: 24))
                }
                .frame(width: 56, height: 56)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Overall Progress")
                        .font(.system(size: 17, weight: .semibold))
                    Text("You keeps ahead!")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }

                Spacer()

                AdherenceRingView(progress: overallAdherence)
                    .frame(width: 76, height: 76)
            }
            .padding(20)
            .background(Color.white)
            .cornerRadius(24)

            // Today's Steps card
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Today’s Steps")
                        .font(.system(size: 17, weight: .semibold))
                    Text("On days you took all doses, you walked 28% more steps.")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }

                Spacer()

                Text(NumberFormatter.decimalFormatter
                        .string(from: NSNumber(value: Int(healthKitService.todayStepCount))) ?? "0")
                    .font(.system(size: 26, weight: .bold))
            }
            .padding(20)
            .background(Color.white)
            .cornerRadius(24)
        }
    }

    // MARK: - Helpers

    private var overallAdherence: Double {
        guard !allLogs.isEmpty else { return 0 }
        let taken = allLogs.reduce(0) { $0 + ($1.taken ? 1 : 0) }
        return Double(taken) / Double(allLogs.count)
    }

    private func deleteMedications(at offsets: IndexSet) {
        let medsToDelete = offsets.map { medications[$0] }
        for med in medsToDelete {
            deleteMedication(med)
        }

        do {
            try viewContext.save()
        } catch {
            print("Failed to delete medications: \(error)")
        }
    }

    private func deleteMedication(_ med: Medication) {
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
}

// MARK: - Preview

struct MedicationListView_Previews: PreviewProvider {
    static var previews: some View {
        MedicationListView()
            .environment(\.managedObjectContext,
                          PersistenceController.shared.container.viewContext)
    }
}

// MARK: - NumberFormatter helper

extension NumberFormatter {
    static let decimalFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
}
