import SwiftUI

struct Message: Identifiable {
    let id = UUID()
    let role: String
    let content: String
}

struct ChatView: View {
    @StateObject var groq = GroqService()
    @State private var inputText = ""
    @State private var selectedModel = "llama-3.1-8b-instant"
    @AppStorage("apiKey") private var apiKey = ""
    
    var body: some View {
        VStack {
            HStack {
                Text("Nebula")
                    .font(.largeTitle.bold())
                Spacer()
                Button(action: { groq.messages.removeAll() }) {
                    Image(systemName: "trash")
                        .foregroundColor(.gray)
                }
            }
            .padding()
            
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        if groq.messages.isEmpty {
                            VStack {
                                Spacer(minLength: 200)
                                Text("Comment puis-je t'aider ?")
                                    .font(.title2)
                                    .opacity(0.5)
                            }
                        }
                        
                        ForEach(0..<groq.messages.count, id: \.self) { index in
                            let msg = groq.messages[index]
                            ChatBubble(role: msg["role"] ?? "", content: msg["content"] ?? "")
                                .id(index)
                        }
                    }
                    .padding(.horizontal)
                }
                .onChange(of: groq.messages.count) { _ in
                    withAnimation {
                        proxy.scrollTo(groq.messages.count - 1, anchor: .bottom)
                    }
                }
            }
            
            // Input Area
            HStack(spacing: 12) {
                TextField("Talk to Nebula...", text: $inputText)
                    .padding(12)
                    .background(.white.opacity(0.05))
                    .cornerRadius(25)
                    .onSubmit { sendMessage() }
                
                Button(action: sendMessage) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.white)
                }
            }
            .padding()
            .background(.ultraThinMaterial)
        }
    }
    
    func sendMessage() {
        guard !inputText.isEmpty else { return }
        let text = inputText
        inputText = ""
        Task {
            groq.apiKey = apiKey
            await groq.streamChat(input: text, model: selectedModel, temperature: 0.7)
        }
    }
}

struct ChatBubble: View {
    let role: String
    let content: String
    
    var body: some View {
        HStack {
            if role == "user" { Spacer() }
            
            Text(content)
                .padding(12)
                .background(role == "user" ? Color.white : Color.white.opacity(0.1))
                .foregroundColor(role == "user" ? .black : .white)
                .cornerRadius(18)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(.white.opacity(0.1), lineWidth: 1)
                        .opacity(role == "user" ? 0 : 1)
                )
            
            if role == "assistant" { Spacer() }
        }
    }
}
