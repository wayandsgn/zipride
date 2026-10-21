import SwiftUI

/// Carteira: Zipride balance and the payment method used by default.
struct WalletView: View {
    @Environment(RideStore.self) private var store
    @State private var showAdd = false

    var body: some View {
        @Bindable var store = store
        List {
            Section {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Saldo Zipride")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.8))
                    Text(BR.money(23.50))
                        .font(.system(size: 34, weight: .heavy))
                        .foregroundStyle(.white)
                    Text("Use em viagens e entregas em Itapipoca")
                        .font(.footnote)
                        .foregroundStyle(.white.opacity(0.8))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(18)
                .background(
                    LinearGradient(colors: [Theme.accent, .black], startPoint: .topLeading, endPoint: .bottomTrailing),
                    in: RoundedRectangle(cornerRadius: Theme.cardRadius, style: .continuous)
                )
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            }

            Section("Pagamento padrão") {
                Picker("Pagamento padrão", selection: $store.payment) {
                    ForEach(PaymentMethod.allCases) { method in
                        Label(method.title, systemImage: method.symbol).tag(method)
                    }
                }
                .pickerStyle(.inline)
                .labelsHidden()
                .accessibilityIdentifier("walletPicker")
            }

            Section {
                Button {
                    showAdd = true
                } label: {
                    Label("Adicionar forma de pagamento", systemImage: "plus.circle.fill")
                }
            }
        }
        .navigationTitle("Carteira")
        .sensoryFeedback(.selection, trigger: store.payment)
        .alert("Adicionar pagamento", isPresented: $showAdd) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Na versão de demonstração você pode usar Pix, o Visa •••• 4242 ou dinheiro.")
        }
    }
}

/// Configurações: toggles live only for this session (nothing is saved).
struct SettingsView: View {
    @State private var tripAlerts = true
    @State private var promos = false
    @State private var shareTrips = true
    @State private var pinCheck = false
    @State private var showDelete = false

    var body: some View {
        Form {
            Section("Conta") {
                LabeledContent("Nome", value: Fixtures.userName)
                LabeledContent("Telefone", value: Fixtures.userPhone)
                LabeledContent("E-mail", value: Fixtures.userEmail)
                LabeledContent("Cidade", value: Fixtures.cityName)
            }
            Section("Notificações") {
                Toggle("Avisos da viagem", isOn: $tripAlerts)
                Toggle("Promoções e cupons", isOn: $promos)
            }
            Section("Segurança") {
                Toggle("Compartilhar viagens com contatos", isOn: $shareTrips)
                Toggle("Confirmar embarque com PIN", isOn: $pinCheck)
            }
            Section {
                LabeledContent("Versão", value: "1.0 (Itapipoca)")
                Button("Excluir conta", role: .destructive) { showDelete = true }
            }
        }
        .tint(Theme.accent)
        .navigationTitle("Configurações")
        .sensoryFeedback(.selection, trigger: [tripAlerts, promos, shareTrips, pinCheck])
        .alert("Excluir conta", isPresented: $showDelete) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Na versão de demonstração nenhuma conta é excluída.")
        }
    }
}
