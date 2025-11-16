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
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(tint)
                Image(systemName: "pills.fill")
                    .foregroundColor(.white)
                    .font(.system(size: 20, weight: .medium))
            }
            .frame(width: 48, height: 48)

            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.system(size: 17, weight: .semibold))
                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                if let primaryTime = primaryTime {
                    Text(primaryTime)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.primary)
                }
            }
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
        .background(Color.white)
        .cornerRadius(24)
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

    private var subtitle: String {
        if let dosage = dosage, !dosage.isEmpty {
            return "\(dosage), Notes"
        } else {
            return "Dose, Notes"
        }
    }

    private var primaryTime: String? {
        let parts = timesText
            .split(separator: "\u{2022}")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        return parts.first
    }
}

struct PillCard_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.shared.container.viewContext
        let med = Medication(context: context)
        med.name = "Name"
        med.dosage = "Dose"

        return Group {
            PillCard(medication: med, color: .blue, timesText: "21:24 • 09:00")
                .previewLayout(.sizeThatFits)
                .padding()
        }
    }
}
