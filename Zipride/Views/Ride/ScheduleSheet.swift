import SwiftUI

/// Pick "Agora" or a later pickup time; the label shows on the "Para onde?" chip.
struct ScheduleSheet: View {
    @Environment(RideStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var date = Date().addingTimeInterval(45 * 60)
    @State private var later = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quando você quer ir?")
                .font(.system(size: 20, weight: .bold))
                .padding(.top, 22)

            Picker("Quando", selection: $later.animation(.snappy)) {
                Text("Agora").tag(false)
                Text("Agendar").tag(true)
            }
            .pickerStyle(.segmented)
            .accessibilityIdentifier("schedulePicker")

            if later {
                DatePicker(
                    "Horário de embarque",
                    selection: $date,
                    in: Date()...Date().addingTimeInterval(30 * 24 * 3600),
                    displayedComponents: [.date, .hourAndMinute]
                )
                .environment(\.timeZone, BR.timeZone)
                .transition(.opacity)
                Label("O motorista espera até 5 min sem custo.", systemImage: "info.circle")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            } else {
                Label("Um motorista é chamado assim que você confirmar.", systemImage: "bolt.fill")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)

            Button(later ? "Agendar para \(BR.time(date))" : "Ir agora") {
                store.scheduleLabel = later ? BR.time(date) : "Agora"
                dismiss()
            }
            .buttonStyle(PrimaryButtonStyle())
            .accessibilityIdentifier("scheduleDone")
        }
        .padding(.horizontal, 18)
        .padding(.bottom, 12)
        .onAppear { later = store.scheduleLabel != "Agora" }
    }
}
