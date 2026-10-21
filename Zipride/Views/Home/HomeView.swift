import SwiftUI

/// Início: the map with a bottom panel that changes with the ride phase.
struct HomeView: View {
    @Environment(RideStore.self) private var store

    var body: some View {
        @Bindable var store = store
        ZStack(alignment: .bottom) {
            HomeMap()
                .ignoresSafeArea()

            VStack {
                HomeHeader()
                Spacer()
            }

            panel
                .padding(.bottom, 6)
                .transition(.move(edge: .bottom).combined(with: .opacity))
        }
        .animation(.spring(duration: 0.32, bounce: 0.15), value: store.phase)
        .fullScreenCover(isPresented: $store.showSearch) {
            DestinationSearchView()
                .environment(store)
        }
        .sheet(isPresented: $store.showSchedule) {
            ScheduleSheet()
                .environment(store)
                .presentationDetents([.medium])
                .presentationCornerRadius(Theme.sheetRadius)
        }
        .fullScreenCover(isPresented: $store.showRating) {
            RatingView()
                .environment(store)
                .interactiveDismissDisabled()
        }
        .task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(120))
                withAnimation(.linear(duration: 0.12)) { store.tickAmbient(by: 0.12) }
            }
        }
    }

    @ViewBuilder
    private var panel: some View {
        switch store.phase {
        case .idle:
            HomeSheet()
        case .choosing:
            RideOptionsSheet()
        case .matching:
            FindingDriverCard()
        case .driverEnRoute, .driverArrived:
            DriverCard()
        case .onTrip:
            TripProgressCard()
        }
    }
}

/// Top bar over the map: logo and profile at rest, a back button while choosing a ride.
private struct HomeHeader: View {
    @Environment(RideStore.self) private var store

    var body: some View {
        HStack {
            if store.phase == .choosing {
                CircleIconButton(symbol: "arrow.left", label: "Voltar") {
                    store.backToHome()
                }
                .accessibilityIdentifier("backToHome")
            } else {
                ZiprideWordmark(size: 28)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(.white, in: Capsule())
                    .shadow(color: .black.opacity(0.12), radius: 8, y: 2)
            }
            Spacer()
            if store.phase == .idle {
                Button {
                    store.tab = .account
                } label: {
                    RemoteAvatar(url: Fixtures.userPhotoURL, initials: "DF", size: 44)
                }
                .buttonStyle(PressableStyle(scale: 0.92))
                .accessibilityLabel("Sua conta")
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 4)
    }
}

/// White round button floating on the map.
struct CircleIconButton: View {
    let symbol: String
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.black)
                .frame(width: 44, height: 44)
                .background(.white, in: Circle())
                .shadow(color: .black.opacity(0.15), radius: 8, y: 2)
        }
        .buttonStyle(PressableStyle(scale: 0.9))
        .accessibilityLabel(label)
    }
}
