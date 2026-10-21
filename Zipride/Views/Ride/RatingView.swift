import SwiftUI

/// End of trip: stars, tip and "Concluir", which adds the trip to Atividade.
struct RatingView: View {
    @Environment(RideStore.self) private var store
    @State private var stars = 0
    @State private var tip: Double = 0
    @State private var customTip = false
    @State private var customValue = 15

    private let tips: [Double] = [2, 5, 10]

    private var fare: Double { store.price(of: store.selectedRide) }
    private var chosenTip: Double { customTip ? Double(customValue) : tip }

    var body: some View {
        ScrollView {
            VStack(spacing: 22) {
                VStack(spacing: 10) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 30))
                        .foregroundStyle(Theme.accent)
                    Text("Você chegou em \(store.destination?.name ?? "seu destino")")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                    RemoteAvatar(url: Fixtures.driver.photoURL, initials: "M", size: 84)
                        .padding(.top, 6)
                    Text("Como foi sua viagem com o \(Fixtures.driver.name)?")
                        .font(.system(size: 24, weight: .bold))
                        .multilineTextAlignment(.center)
                }
                starRow
                tipSection
                summary
            }
            .padding(.horizontal, 22)
            .padding(.top, 30)
        }
        .safeAreaInset(edge: .bottom) {
            Button(stars == 0 ? "Concluir sem avaliar" : "Concluir") {
                store.finishRating(stars: stars == 0 ? 5 : stars, tip: chosenTip)
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(.horizontal, 18)
            .padding(.bottom, 8)
            .background(.white)
            .accessibilityIdentifier("ratingDone")
        }
        .background(Theme.surface)
        .sensoryFeedback(.selection, trigger: stars)
        .sensoryFeedback(.selection, trigger: chosenTip)
    }

    private var starRow: some View {
        HStack(spacing: 10) {
            ForEach(1...5, id: \.self) { value in
                Button {
                    withAnimation(.spring(duration: 0.28, bounce: 0.45)) { stars = value }
                } label: {
                    Image(systemName: value <= stars ? "star.fill" : "star")
                        .font(.system(size: 38, weight: .semibold))
                        .foregroundStyle(value <= stars ? Theme.sun : Color(.tertiaryLabel))
                        .scaleEffect(value == stars ? 1.15 : 1)
                }
                .buttonStyle(PressableStyle(scale: 0.85))
                .accessibilityLabel("\(value) estrela\(value > 1 ? "s" : "")")
                .accessibilityIdentifier("ratingStar_\(value)")
            }
        }
    }

    private var tipSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quer deixar uma gorjeta?")
                .font(.headline)
            HStack(spacing: 8) {
                ForEach(tips, id: \.self) { value in
                    tipChip(BR.money(value), selected: !customTip && tip == value, id: "tip_\(Int(value))") {
                        customTip = false
                        tip = tip == value ? 0 : value
                    }
                }
                tipChip("Outro valor", selected: customTip, id: "tip_other") {
                    customTip.toggle()
                }
            }
            if customTip {
                Stepper(value: $customValue, in: 1...100) {
                    Text("Gorjeta: \(BR.money(Double(customValue)))")
                        .font(.system(size: 16, weight: .semibold))
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
                .accessibilityIdentifier("tipStepper")
            }
            Text("100% da gorjeta vai para o motorista.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .animation(.snappy(duration: 0.25), value: customTip)
    }

    private func tipChip(_ title: String, selected: Bool, id: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .foregroundStyle(selected ? Color.white : Color.primary)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(selected ? Color.black : Color(.secondarySystemFill), in: Capsule())
        }
        .buttonStyle(PressableStyle(scale: 0.94))
        .accessibilityIdentifier(id)
    }

    private var summary: some View {
        VStack(spacing: 10) {
            summaryLine("Viagem \(store.selectedRide.name)", BR.money(fare))
            summaryLine("Gorjeta", BR.money(chosenTip))
            Divider()
            summaryLine("Total no \(store.payment.title)", BR.money(fare + chosenTip), bold: true)
        }
        .padding(16)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: Theme.cardRadius, style: .continuous))
        .padding(.bottom, 20)
    }

    private func summaryLine(_ title: String, _ value: String, bold: Bool = false) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value).contentTransition(.numericText())
        }
        .font(.system(size: 16, weight: bold ? .bold : .regular))
    }
}
