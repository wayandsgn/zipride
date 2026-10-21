import SwiftUI

/// Payment method picker: Pix (default), card and cash.
struct PaymentPickerSheet: View {
    @Environment(RideStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Forma de pagamento")
                .font(.system(size: 20, weight: .bold))
                .padding(.top, 22)

            VStack(spacing: 8) {
                ForEach(PaymentMethod.allCases) { method in
                    row(method)
                }
            }

            Button("Pronto") { dismiss() }
                .buttonStyle(PrimaryButtonStyle())
                .accessibilityIdentifier("paymentDone")
        }
        .padding(.horizontal, 18)
        .sensoryFeedback(.selection, trigger: store.payment)
    }

    private func row(_ method: PaymentMethod) -> some View {
        let selected = store.payment == method
        return Button {
            withAnimation(.snappy(duration: 0.25)) { store.payment = method }
        } label: {
            HStack(spacing: 14) {
                Image(systemName: method.symbol)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(selected ? .white : Theme.accent)
                    .frame(width: 40, height: 40)
                    .background(selected ? Theme.accent : Theme.accentSoft, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                VStack(alignment: .leading, spacing: 2) {
                    Text(method.title).font(.system(size: 16, weight: .semibold))
                    Text(method.subtitle).font(.footnote).foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundStyle(selected ? Theme.accent : Color(.tertiaryLabel))
            }
            .foregroundStyle(.primary)
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(selected ? Color.black : Theme.hairline, lineWidth: selected ? 1.5 : 1)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(PressableStyle())
        .accessibilityIdentifier("payment_\(method.id)")
    }
}
