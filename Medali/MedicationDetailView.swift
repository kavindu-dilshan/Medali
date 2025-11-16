import SwiftUI
import CoreData

struct PressScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

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
        ZStack {
            // Same background as main Medali screen
            Color(red: 240/255, green: 244/255, blue: 255/255)
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 20) {

                // Top card: title + dosage + adherence ring
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(medication.name ?? "Untitled Medication")
                            .font(.system(size: 24, weight: .bold))
                        if let dosage = medication.dosage, !dosage.isEmpty {
                            Text(dosage)
                                .font(.system(size: 15))
                                .foregroundColor(.secondary)
                        }
                    }

                    HStack {
                        Spacer()
                        AdherenceRingView(progress: vm.adherence(for: medication))
                            .frame(width: 120, height: 120)
                        Spacer()
                    }
                }
                .padding(20)
                .background(Color.white)
                .cornerRadius(24)

                // Card: note + buttons
                VStack(alignment: .leading, spacing: 12) {
                    TextField("Optional note (e.g., 'Felt dizzy')", text: $noteText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    HStack(spacing: 12) {
                        Button(action: {
                            vm.logDose(
                                context: viewContext,
                                medication: medication,
                                taken: true,
                                note: noteText.isEmpty ? nil : noteText
                            )
                            noteText = ""
                        }) {
                            Label("Taken", systemImage: "checkmark.circle.fill")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(Color.green)
                                .cornerRadius(12)
                        }
                        .buttonStyle(PressScaleButtonStyle())
                        .accessibilityLabel("Mark dose as taken")
                        .accessibilityHint("Logs a taken dose with optional note")

                        Button(action: {
                            vm.logDose(
                                context: viewContext,
                                medication: medication,
                                taken: false,
                                note: noteText.isEmpty ? nil : noteText
                            )
                            noteText = ""
                        }) {
                            Label("Skip", systemImage: "xmark.circle.fill")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(Color.red)
                                .cornerRadius(12)
                        }
                        .buttonStyle(PressScaleButtonStyle())
                        .accessibilityLabel("Skip dose")
                        .accessibilityHint("Logs a skipped dose with optional note")
                    }
                }
                .padding(20)
                .background(Color.white)
                .cornerRadius(24)

                Divider().opacity(0)   // keep the element, but visually soft

                Text("History")
                    .font(.system(size: 20, weight: .bold))
                    .padding(.top, 4)

                // History list, themed
                List {
                    ForEach(logs, id: \.objectID) { log in
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: log.taken ? "checkmark.circle.fill" : "xmark.circle.fill")
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
                        .padding(.vertical, 8)
                        .padding(.horizontal, 4)
                        .background(Color.white)
                        .cornerRadius(16)
                        .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
                        .listRowBackground(Color.clear)
                    }
                }
                .listStyle(PlainListStyle())
                .background(Color.clear)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 8)
        }
        .navigationBarTitle("Details", displayMode: .inline)
    }
}

struct MedicationDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.shared.container.viewContext
        let med = Medication(context: context)
        med.name = "Sample Med"
        med.dosage = "10 mg"
        return NavigationView {
            MedicationDetailView(medication: med)
        }
    }
}
