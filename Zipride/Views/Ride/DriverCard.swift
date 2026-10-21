import SwiftUI

/// Matched driver: countdown header, driver and car, chat, call, start and cancel.
struct DriverCard: View {
    @Environment(RideStore.self) private var store
    @State private var showCall = false
    @State private var confirmCancel = false

    private var arrived: Bool { store.phase == .driverArrived }

    var body: some View {
        @Bindable var store = store
        VStack(spacing: 14) {
            header
            Divider()
            DriverSummary()
            actions
            Button(arrived ? "Iniciar viagem" : "Já estou no carro") {
                store.startTrip()
            }
            .buttonStyle(PrimaryButtonStyle(tint: arrived ? .black : Color(white: 0.25)))
            .accessibilityIdentifier("startTrip")
        }
        .padding(18)
        .mapPanel()
        .sensoryFeedback(.success, trigger: arrived)
        .sheet(isPresented: $store.showChat) {
            ChatSheet()
                .environment(store)
                .presentationDetents([.large])
                .presentationCornerRadius(Theme.sheetRadius)
        }
        .alert("Ligação protegida", isPresented: $showCall) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Seu número fica oculto. Na versão de demonstração a ligação não é feita.")
        }
        .confirmationDialog("Cancelar a corrida?", isPresented: $confirmCancel, titleVisibility: .visible) {
            Button("Cancelar corrida", role: .destructive) { store.cancelRide() }
            Button("Continuar esperando", role: .cancel) {}
        } message: {
            Text("O \(Fixtures.driver.name) já está a caminho.")
        }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(arrived ? "Seu motorista chegou" : "Chegando em \(store.arrivalMinutes) min")
                    .font(.system(size: 20, weight: .bold))
                    .contentTransition(.numericText(countsDown: true))
                    .accessibilityIdentifier("driverStatus")
                Text(arrived ? "Encontre o \(Fixtures.driver.name) no ponto de embarque" : "Embarque na \(Fixtures.pickupAddress)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Spacer()
            if !arrived {
                ProgressView(value: store.driverProgress)
                    .progressViewStyle(.circular)
                    .tint(Theme.accent)
            }
        }
        .animation(.snappy, value: store.arrivalMinutes)
    }

    private var actions: some View {
        HStack(spacing: 10) {
            Button {
                store.showChat = true
            } label: {
                HStack {
                    Image(systemName: "message.fill")
                    Text("Mensagem para \(Fixtures.driver.name)")
                    Spacer()
                }
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.primary)
                .padding(.horizontal, 14)
                .frame(height: 48)
                .background(Color(.secondarySystemFill), in: Capsule())
            }
            .buttonStyle(PressableStyle())
            .accessibilityIdentifier("messageButton")

            roundAction(symbol: "phone.fill", label: "Ligar") { showCall = true }
            roundAction(symbol: "xmark", label: "Cancelar corrida") { confirmCancel = true }
                .accessibilityIdentifier("cancelRide")
        }
    }

    private func roundAction(symbol: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.primary)
                .frame(width: 48, height: 48)
                .background(Color(.secondarySystemFill), in: Circle())
        }
        .buttonStyle(PressableStyle(scale: 0.9))
        .accessibilityLabel(label)
    }
}

/// Driver photo, rating, car and Mercosul plate.
struct DriverSummary: View {
    var body: some View {
        HStack(spacing: 14) {
            ZStack(alignment: .bottomTrailing) {
                RemoteAvatar(url: Fixtures.driver.photoURL, initials: "M", size: 60)
                HStack(spacing: 2) {
                    Image(systemName: "star.fill").font(.system(size: 9))
                    Text(BR.rating(Fixtures.driver.rating)).font(.system(size: 11, weight: .bold))
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(.white, in: Capsule())
                .shadow(color: .black.opacity(0.15), radius: 2, y: 1)
                .offset(x: 6, y: 4)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(Fixtures.driver.name)
                    .font(.system(size: 18, weight: .bold))
                Text(Fixtures.driver.car)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("\(BR.integer(Fixtures.driver.trips)) viagens")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            MercosulPlate(text: Fixtures.driver.plate)
        }
    }
}

/// Brazilian Mercosul plate: blue band with "BRASIL" above the characters.
struct MercosulPlate: View {
    let text: String

    var body: some View {
        VStack(spacing: 0) {
            Text("BRASIL")
                .font(.system(size: 7, weight: .heavy))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 11)
                .background(Color(red: 0.0, green: 0.2, blue: 0.6))
            Text(text)
                .font(.system(size: 16, weight: .heavy, design: .monospaced))
                .foregroundStyle(.black)
                .padding(.horizontal, 6)
                .frame(height: 24)
        }
        .frame(width: 92)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 4, style: .continuous).stroke(.black, lineWidth: 1.2))
        .accessibilityLabel("Placa \(text)")
    }
}
