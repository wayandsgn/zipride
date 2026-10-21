import SwiftUI

/// Conta: profile, rating, wallet and settings.
struct AccountView: View {
    @Environment(RideStore.self) private var store
    @State private var notice: AccountNotice?

    var body: some View {
        NavigationStack {
            List {
                Section { profile }
                Section { tiles }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                Section {
                    NavigationLink { WalletView() } label: {
                        row("Carteira", "Pix, cartões e saldo Zipride", "wallet.bifold.fill")
                    }
                    .accessibilityIdentifier("walletLink")
                    NavigationLink { SavedPlacesView() } label: {
                        row("Lugares salvos", "Casa e Trabalho", "mappin.and.ellipse")
                    }
                    NavigationLink { SettingsView() } label: {
                        row("Configurações", "Notificações, privacidade e conta", "gearshape.fill")
                    }
                    .accessibilityIdentifier("settingsLink")
                }
                Section {
                    Button { notice = .invite } label: {
                        row("Convide amigos", "Ganhe R$ 10 na próxima viagem", "gift.fill")
                    }
                    Button { notice = .help } label: {
                        row("Ajuda", "Fale com o suporte Zipride", "questionmark.circle.fill")
                    }
                }
                Section {
                    Button("Sair da conta", role: .destructive) { notice = .logout }
                }
            }
            .navigationTitle("Conta")
            .alert(item: $notice) { notice in
                Alert(title: Text(notice.title), message: Text(notice.message), dismissButton: .default(Text("OK")))
            }
        }
    }

    private var profile: some View {
        HStack(spacing: 14) {
            RemoteAvatar(url: Fixtures.userPhotoURL, initials: "DF", size: 68)
            VStack(alignment: .leading, spacing: 4) {
                Text(Fixtures.userName)
                    .font(.system(size: 22, weight: .bold))
                HStack(spacing: 4) {
                    Image(systemName: "star.fill").foregroundStyle(Theme.sun)
                    Text(BR.rating(Fixtures.userRating)).fontWeight(.semibold)
                    Text("· \(Fixtures.userTrips + store.trips.count - Fixtures.pastTrips.count) viagens")
                        .foregroundStyle(.secondary)
                }
                .font(.subheadline)
                Text(Fixtures.cityName)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 6)
    }

    private var tiles: some View {
        HStack(spacing: 10) {
            tile("Carteira", "wallet.bifold.fill") { store.payment = .pix; notice = .wallet }
            tile("Segurança", "shield.lefthalf.filled") { notice = .safety }
            tile("Atividade", "clock.fill") { store.tab = .activity }
        }
    }

    private func tile(_ title: String, _ symbol: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: symbol).font(.system(size: 22, weight: .semibold))
                Text(title).font(.system(size: 14, weight: .semibold))
            }
            .foregroundStyle(.primary)
            .frame(maxWidth: .infinity)
            .frame(height: 78)
            .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(PressableStyle(scale: 0.95))
    }

    private func row(_ title: String, _ subtitle: String, _ symbol: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: symbol)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Theme.accent)
                .frame(width: 34, height: 34)
                .background(Theme.accentSoft, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            VStack(alignment: .leading, spacing: 1) {
                Text(title).font(.system(size: 16, weight: .semibold)).foregroundStyle(.primary)
                Text(subtitle).font(.footnote).foregroundStyle(.secondary)
            }
        }
    }
}

enum AccountNotice: String, Identifiable {
    case invite, help, logout, wallet, safety

    var id: String { rawValue }

    var title: String {
        switch self {
        case .invite: return "Seu código: DAVI10"
        case .help: return "Ajuda Zipride"
        case .logout: return "Modo demonstração"
        case .wallet: return "Pix selecionado"
        case .safety: return "Central de segurança"
        }
    }

    var message: String {
        switch self {
        case .invite: return "Quem usar seu código ganha R$ 10 na primeira viagem, e você também."
        case .help: return "O suporte responde pelo chat em até 5 minutos, todos os dias."
        case .logout: return "Nesta versão de demonstração você continua conectado."
        case .wallet: return "Suas próximas viagens serão pagas com Pix, sem taxa."
        case .safety: return "Compartilhe a viagem, confira a placa e ligue 190 em emergências."
        }
    }
}

/// Casa and Trabalho, each one tap away from a ride.
private struct SavedPlacesView: View {
    @Environment(RideStore.self) private var store

    var body: some View {
        List {
            ForEach([Fixtures.home, Fixtures.work]) { place in
                Button {
                    store.tab = .home
                    store.choose(place)
                } label: {
                    PlaceRow(place: place)
                }
            }
        }
        .navigationTitle("Lugares salvos")
    }
}
