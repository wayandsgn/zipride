import SwiftUI

/// Ride options for the chosen destination, with payment and the confirm button.
struct RideOptionsSheet: View {
    @Environment(RideStore.self) private var store
    @Namespace private var selection
    @State private var showPayment = false

    var body: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(Color(.tertiaryLabel))
                .frame(width: 36, height: 5)
                .padding(.top, 10)
            header
            ScrollView {
                VStack(spacing: 4) {
                    ForEach(Fixtures.rideTypes) { ride in
                        option(ride)
                    }
                }
                .padding(.horizontal, 10)
            }
            .frame(maxHeight: 300)
            .scrollBounceBehavior(.basedOnSize)
            Divider()
            footer
        }
        .mapPanel()
        .sensoryFeedback(.selection, trigger: store.selectedRideID)
        .sheet(isPresented: $showPayment) {
            PaymentPickerSheet()
                .environment(store)
                .presentationDetents([.height(360)])
                .presentationCornerRadius(Theme.sheetRadius)
        }
    }

    private var header: some View {
        VStack(spacing: 4) {
            Text("Escolha uma viagem")
                .font(.system(size: 19, weight: .bold))
            HStack(spacing: 6) {
                if store.isRouting {
                    ProgressView().controlSize(.mini)
                    Text("Calculando rota…")
                } else {
                    Text(store.destination?.name ?? "")
                    Text("·")
                    Text("\(BR.km(store.tripKm)) · \(store.tripMinutes) min")
                }
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .contentTransition(.opacity)
        }
        .padding(.vertical, 12)
        .animation(.snappy, value: store.isRouting)
    }

    private func option(_ ride: RideType) -> some View {
        let selected = ride.id == store.selectedRideID
        return Button {
            withAnimation(.spring(duration: 0.3, bounce: 0.2)) {
                store.selectedRideID = ride.id
            }
        } label: {
            HStack(spacing: 12) {
                RideIllustration(ride: ride)
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(ride.name).font(.system(size: 17, weight: .bold))
                        Label("\(ride.seats)", systemImage: "person.fill")
                            .font(.caption.weight(.semibold))
                            .labelStyle(.titleAndIcon)
                            .foregroundStyle(.secondary)
                    }
                    Text(arrival(for: ride))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    if selected {
                        Text(ride.tagline)
                            .font(.footnote)
                            .foregroundStyle(Theme.accent)
                            .transition(.opacity)
                    }
                }
                Spacer(minLength: 6)
                Text(BR.money(store.price(of: ride)))
                    .font(.system(size: 17, weight: .bold))
                    .contentTransition(.numericText())
            }
            .foregroundStyle(.primary)
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background {
                if selected {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(.black, lineWidth: 2)
                        .background(Theme.accentSoft, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .matchedGeometryEffect(id: "selectedRide", in: selection)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(PressableStyle(scale: 0.98))
        .accessibilityIdentifier("rideOption_\(ride.id)")
    }

    private func arrival(for ride: RideType) -> String {
        let pickup = Date().addingTimeInterval(Double(ride.etaMinutes) * 60)
        let dropoff = pickup.addingTimeInterval(Double(store.tripMinutes) * 60)
        return "\(ride.etaMinutes) min · chega às \(BR.time(dropoff))"
    }

    private var footer: some View {
        VStack(spacing: 10) {
            Button {
                showPayment = true
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: store.payment.symbol)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Theme.accent)
                        .frame(width: 28)
                    Text(store.payment.title)
                        .font(.system(size: 16, weight: .semibold))
                    if store.scheduleLabel != "Agora" {
                        Text("· \(store.scheduleLabel)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.footnote.weight(.bold))
                        .foregroundStyle(.secondary)
                }
                .foregroundStyle(.primary)
                .frame(height: 40)
                .contentShape(Rectangle())
            }
            .buttonStyle(PressableStyle())
            .accessibilityIdentifier("paymentRow")

            Button("Escolher \(store.selectedRide.name)") {
                store.confirmRide()
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(store.isRouting)
            .opacity(store.isRouting ? 0.5 : 1)
            .accessibilityIdentifier("confirmRide")
            .sensoryFeedback(.impact(weight: .medium), trigger: store.phase == .matching)
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 14)
    }
}
