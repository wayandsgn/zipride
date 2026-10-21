import SwiftUI

@main
struct ZiprideApp: App {
    @State private var store = RideStore()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environment(store)
                .tint(Theme.accent)
                .environment(\.locale, BR.locale)
        }
    }
}

struct RootTabView: View {
    @Environment(RideStore.self) private var store

    var body: some View {
        @Bindable var store = store
        TabView(selection: $store.tab) {
            Tab("Início", systemImage: "house.fill", value: AppTab.home) {
                HomeView()
            }
            Tab("Serviços", systemImage: "square.grid.2x2.fill", value: AppTab.services) {
                ServicesView()
            }
            Tab("Atividade", systemImage: "list.bullet.rectangle.portrait.fill", value: AppTab.activity) {
                ActivityView()
            }
            Tab("Conta", systemImage: "person.crop.circle.fill", value: AppTab.account) {
                AccountView()
            }
        }
        .sensoryFeedback(.selection, trigger: store.tab)
    }
}
