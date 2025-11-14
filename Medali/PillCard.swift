import SwiftUI

struct PillCard: View {
    let name: String
    let dosage: String?
    let timesText: String
    let tint: Color

    init(medication: Medication, color: Color, timesText: String) {
        self.name = medication.name ?? "Untitled Medication"
        self.dosage = medication.dosage
        self.timesText = timesText
        self.tint = color
    }

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(tint.opacity(0.15))
                Image(systemName: "pills.fill")
                    .foregroundColor(tint)
            }
            .frame(width: 44, height: 44)

            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.headline)
                if let dosage = dosage, !dosage.isEmpty {
                    Text(dosage)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                if !timesText.isEmpty {
                    Text(timesText)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint("Opens medication details")
    }

    private var accessibilityLabel: String {
        var parts: [String] = [name]
        if let dosage = dosage, !dosage.isEmpty { parts.append(dosage) }
        if !timesText.isEmpty { parts.append("Times: \(timesText)") }
        return parts.joined(separator: ", ")
    }
}

struct PillCard_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.shared.container.viewContext
        let med = Medication(context: context)
        med.name = "Amoxicillin"
        med.dosage = "500 mg"
        return Group {
            PillCard(medication: med, color: .blue, timesText: "08:00 • 12:30 • 20:00")
                .previewLayout(.sizeThatFits)
                .padding()
                .preferredColorScheme(.light)
            PillCard(medication: med, color: .blue, timesText: "08:00 • 12:30 • 20:00")
                .previewLayout(.sizeThatFits)
                .padding()
                .preferredColorScheme(.dark)
        }
    }
}
