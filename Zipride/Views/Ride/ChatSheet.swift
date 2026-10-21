import SwiftUI

/// Chat with the driver: quick replies, free text, typing indicator and canned answers.
struct ChatSheet: View {
    @Environment(RideStore.self) private var store
    @State private var draft = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                messages
                quickReplies
                composer
            }
            .navigationTitle(Fixtures.driver.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fechar") { store.showChat = false }
                        .accessibilityIdentifier("chatClose")
                }
            }
        }
        .sensoryFeedback(.increase, trigger: store.chat.count)
    }

    private var messages: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 8) {
                    Text("Mensagens ficam salvas só durante a corrida.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.vertical, 10)
                    ForEach(store.chat) { message in
                        ChatBubble(message: message)
                            .id(message.id)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                    if store.driverTyping {
                        TypingBubble().id("typing")
                    }
                }
                .padding(.horizontal, 14)
            }
            .onChange(of: store.chat.count) {
                if let last = store.chat.last?.id {
                    withAnimation(.snappy) { proxy.scrollTo(last, anchor: .bottom) }
                }
            }
        }
    }

    private var quickReplies: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Array(Fixtures.quickReplies.enumerated()), id: \.offset) { index, reply in
                    Button(reply) { store.send(reply) }
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                        .padding(.horizontal, 14)
                        .frame(height: 36)
                        .overlay(Capsule().stroke(Theme.hairline, lineWidth: 1))
                        .buttonStyle(PressableStyle(scale: 0.95))
                        .accessibilityIdentifier("quickReply_\(index)")
                }
            }
            .padding(.horizontal, 14)
        }
        .padding(.vertical, 8)
    }

    private var composer: some View {
        HStack(spacing: 10) {
            TextField("Escreva uma mensagem", text: $draft)
                .padding(.horizontal, 16)
                .frame(height: 44)
                .background(Color(.secondarySystemFill), in: Capsule())
                .submitLabel(.send)
                .onSubmit(sendDraft)
                .accessibilityIdentifier("chatField")
            Button(action: sendDraft) {
                Image(systemName: "arrow.up")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(draft.isEmpty ? Color(.tertiaryLabel) : Color.black, in: Circle())
            }
            .buttonStyle(PressableStyle(scale: 0.9))
            .disabled(draft.isEmpty)
            .accessibilityLabel("Enviar")
        }
        .padding(.horizontal, 14)
        .padding(.bottom, 10)
    }

    private func sendDraft() {
        store.send(draft)
        draft = ""
    }
}

private struct ChatBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            if !message.fromDriver { Spacer(minLength: 50) }
            VStack(alignment: message.fromDriver ? .leading : .trailing, spacing: 3) {
                Text(message.text)
                    .font(.body)
                    .foregroundStyle(message.fromDriver ? Color.primary : Color.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 9)
                    .background(
                        message.fromDriver ? Color(.secondarySystemFill) : Color.black,
                        in: RoundedRectangle(cornerRadius: 18, style: .continuous)
                    )
                Text(BR.time(message.time))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            if message.fromDriver { Spacer(minLength: 50) }
        }
    }
}

private struct TypingBubble: View {
    @State private var phase = false

    var body: some View {
        HStack {
            HStack(spacing: 5) {
                ForEach(0..<3, id: \.self) { dot in
                    Circle()
                        .fill(Color.secondary)
                        .frame(width: 7, height: 7)
                        .opacity(phase ? 1 : 0.3)
                        .animation(.easeInOut(duration: 0.5).repeatForever().delay(Double(dot) * 0.15), value: phase)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color(.secondarySystemFill), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            Spacer()
        }
        .onAppear { phase = true }
        .accessibilityLabel("\(Fixtures.driver.name) está digitando")
    }
}
