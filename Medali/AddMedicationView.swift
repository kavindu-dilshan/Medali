import SwiftUI
import CoreData

struct AddMedicationView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject private var notificationService: NotificationService

    @State private var name: String = ""
    @State private var dosage: String = ""
    @State private var notes: String = ""
    @State private var colorHex: String = "#4CAF50"
    @State private var times: [Date] = [Date()]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Details")) {
                    TextField("Name", text: $name)
                    TextField("Dosage", text: $dosage)
                    TextField("Notes (optional)", text: $notes)
                }

                Section(header: Text("Times")) {
                    ForEach(times.indices, id: \.self) { idx in
                        DatePicker("Time #\(idx + 1)", selection: $times[idx], displayedComponents: .hourAndMinute)
                    }
                    Button(action: {
                        times.append(Date())
                    }) {
                        Label("Add another time", systemImage: "plus.circle")
                    }
                }

                Section(header: Text("Appearance")) {
                    TextField("Color Hex", text: $colorHex)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
            }
            .navigationBarTitle("Add Medication", displayMode: .inline)
            .navigationBarItems(leading: Button("Cancel") { presentationMode.wrappedValue.dismiss() }, trailing: Button("Save") { save() }.disabled(name.trimmingCharacters(in: .whitespaces).isEmpty))
        }
    }

    private func save() {
        let med = Medication(context: viewContext)
        med.id = UUID()
        med.name = name.trimmingCharacters(in: .whitespaces)
        med.dosage = dosage.trimmingCharacters(in: .whitespaces)
        med.notes = notes.trimmingCharacters(in: .whitespaces)
        med.colorHex = colorHex.trimmingCharacters(in: .whitespaces)

        let calendar = Calendar.current
        var createdDoseTimes: [DoseTime] = []
        for date in times {
            let components = calendar.dateComponents([.hour, .minute], from: date)
            let doseTime = DoseTime(context: viewContext)
            doseTime.hour = Int16(components.hour ?? 0)
            doseTime.minute = Int16(components.minute ?? 0)
            doseTime.medication = med
            createdDoseTimes.append(doseTime)
        }

        do {
            try viewContext.save()
            let medicationID = med.id?.uuidString ?? UUID().uuidString
            let medName = med.name ?? name
            let timesTuples: [(Int, Int)] = createdDoseTimes.map { (Int($0.hour), Int($0.minute)) }
            notificationService.scheduleDailyNotifications(for: medicationID, name: medName, times: timesTuples)
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("Failed to save medication: \(error)")
        }
    }
}

struct AddMedicationView_Previews: PreviewProvider {
    static var previews: some View {
        AddMedicationView()
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
            .environmentObject(NotificationService())
    }
}
