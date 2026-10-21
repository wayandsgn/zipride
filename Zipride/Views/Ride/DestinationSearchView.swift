import SwiftUI

/// Full-screen destination search with accent-insensitive filtering over the fixture places.
struct DestinationSearchView: View {
    @Environment(RideStore.self) private var store
    @State private var query = ""
    @FocusState private var focused: Bool

    private var results: [Place] {
        let key = BR.searchKey(query)
        guard !key.isEmpty else { return Fixtures.suggestions }
        return Fixtures.places.filter { place in
            BR.searchKey(place.name).contains(key) || BR.searchKey(place.address).contains(key)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    if query.isEmpty { savedSection }
                    Text(query.isEmpty ? "Sugestões em Itapipoca" : "Resultados")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)
                        .padding(.top, 18)
                        .padding(.bottom, 4)
                    if results.isEmpty {
                        emptyState
                    } else {
                        ForEach(results) { place in
                            row(for: place)
                        }
                    }
                }
                .padding(.horizontal, 18)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .background(Theme.surface)
        .onAppear { focused = true }
        .sensoryFeedback(.selection, trigger: store.destination?.id)
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 12) {
            Button {
                store.showSearch = false
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.primary)
                    .frame(width: 40, height: 40)
            }
            .buttonStyle(PressableStyle(scale: 0.9))
            .accessibilityLabel("Fechar busca")
            .accessibilityIdentifier("closeSearch")

            HStack(spacing: 12) {
                VStack(spacing: 4) {
                    Circle().fill(.black).frame(width: 8, height: 8)
                    Rectangle().fill(Color(.tertiaryLabel)).frame(width: 2, height: 26)
                    Rectangle().fill(.black).frame(width: 8, height: 8)
                }
                VStack(spacing: 8) {
                    fieldBackground {
                        Text(Fixtures.pickupName)
                            .foregroundStyle(Theme.accent)
                            .font(.system(size: 16, weight: .semibold))
                    }
                    fieldBackground {
                        TextField("Para onde?", text: $query)
                            .font(.system(size: 16, weight: .medium))
                            .focused($focused)
                            .submitLabel(.search)
                            .autocorrectionDisabled()
                            .accessibilityIdentifier("searchField")
                        if !query.isEmpty {
                            Button { query = "" } label: {
                                Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                            }
                            .accessibilityLabel("Limpar")
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.top, 8)
        .padding(.bottom, 14)
    }

    private func fieldBackground<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        HStack { content() }
            .padding(.horizontal, 14)
            .frame(height: 44)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemFill), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    private var savedSection: some View {
        VStack(spacing: 0) {
            row(for: Fixtures.home, symbol: "house.fill")
            Divider().padding(.leading, 52)
            row(for: Fixtures.work, symbol: "briefcase.fill")
            Divider().padding(.leading, 52)
            ForEach(Fixtures.recents) { place in
                row(for: place, symbol: "clock.arrow.circlepath")
            }
        }
        .padding(.top, 6)
    }

    private func row(for place: Place, symbol: String? = nil) -> some View {
        Button {
            store.choose(place)
        } label: {
            PlaceRow(place: place, symbol: symbol)
        }
        .buttonStyle(PressableStyle())
        .accessibilityIdentifier("place_\(place.id)")
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "mappin.slash")
                .font(.system(size: 34, weight: .semibold))
                .foregroundStyle(.secondary)
            Text("Nada encontrado para “\(query)”")
                .font(.headline)
            Text("Tente “Mercado”, “Baleia” ou “Rodoviária”.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Button("Limpar busca") { query = "" }
                .buttonStyle(SecondaryButtonStyle())
                .frame(width: 180)
                .padding(.top, 6)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}
