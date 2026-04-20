import SwiftUI
import UIKit

// Haptics Helper
class Haptics {
    static let shared = Haptics()
    func play(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
}

struct ChatView: View {
    @StateObject var groq: GroqService
    @State private var inputText = ""
    @AppStorage("selectedModel") private var selectedModel = "llama-3.1-8b-instant"
    @AppStorage("apiKey") private var apiKey = ""
    
    let quickPrompts = [
        "Plan a 3-day trip to Paris 🇫🇷",
        "Explain Quantum Physics like I'm 5 ⚛️",
        "Write a Python script for a calculator 🐍",
        "Summarize the news of the day 📰"
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Nebula")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                    Text(selectedModel)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                Spacer()
                Button(action: { 
                    Haptics.shared.play(.medium)
                    groq.messages.removeAll() 
                }) {
                    Image(systemName: "square.and.pencil")
                        .font(.title2)
                        .padding(12)
                        .background(.white.opacity(0.1))
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal)
            .padding(.top, 10)
            
            // Messages Area
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 24) {
                        if groq.messages.isEmpty {
                            welcomeView
                        }
                        
                        ForEach(0..<groq.messages.count, id: \.self) { index in
                            let msg = groq.messages[index]
                            MessageBubble(role: msg["role"] ?? "", content: msg["content"] ?? "")
                                .id(index)
                        }
                        
                        // Bottom spacer for input bar
                        Color.clear.frame(height: 120).id("bottom")
                    }
                    .padding(.top, 20)
                }
                .onChange(of: groq.messages.count) { _ in
                    withAnimation(.spring()) {
                        proxy.scrollTo(groq.messages.count - 1, anchor: .bottom)
                    }
                }
            }
            .background(Color.clear)
            
            // Bottom Area (Floating Input)
            VStack(spacing: 12) {
                if groq.messages.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(quickPrompts, id: \.self) { prompt in
                                Button(action: { 
                                    inputText = prompt
                                    sendMessage()
                                }) {
                                    Text(prompt)
                                        .font(.subheadline)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .glassmorphism()
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                HStack(spacing: 12) {
                    TextField("Messagerie Nebula...", text: $inputText, axis: .vertical)
                        .lineLimit(1...5)
                        .padding(14)
                        .background(.white.opacity(0.1))
                        .cornerRadius(24)
                    
                    if !inputText.isEmpty {
                        Button(action: sendMessage) {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 36))
                                .symbolRenderingMode(.palette)
                                .foregroundStyle(.black, .white)
                        }
                        .transition(.scale.combined(with: .opacity))
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 30) // Safe area adjustment
            }
            .background(.ultraThinMaterial)
            .cornerRadius(30) // Rounded top for the input panel
        }
        .ignoresSafeArea(.keyboard)
    }
    
    var welcomeView: some View {
        VStack(spacing: 20) {
            Spacer(minLength: 150)
            Image(systemName: "sparkles")
                .font(.system(size: 64))
                .foregroundStyle(.linearGradient(colors: [.purple, .blue], startPoint: .top, endPoint: .bottom))
            
            Text("Nebula")
                .font(.system(size: 40, weight: .black, design: .rounded))
            
            Text("L'intelligence augmentée,\nnativement sur votre iPhone.")
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
                .padding(.horizontal, 40)
            
            Spacer()
        }
    }
    
    func sendMessage() {
        guard !inputText.isEmpty else { return }
        Haptics.shared.play(.light)
        let text = inputText
        inputText = ""
        Task {
            groq.apiKey = apiKey
            await groq.streamChat(input: text, model: selectedModel, temperature: 0.7)
            Haptics.shared.play(.medium)
        }
    }
}

struct MessageBubble: View {
    let role: String
    let content: String
    
    var body: some View {
        HStack(alignment: .bottom) {
            if role == "user" { Spacer(minLength: 60) }
            
            VStack(alignment: role == "user" ? .trailing : .leading, spacing: 10) {
                MarkdownContentView(content: content, role: role)
            }
            .padding(14)
            .background(role == "user" ? Color.white : Color.white.opacity(0.1))
            .foregroundColor(role == "user" ? .black : .white)
            .cornerRadius(20)
            .glassmorphism()
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(.white.opacity(0.15), lineWidth: 1)
                    .opacity(role == "user" ? 0 : 1)
            )
            
            if role == "assistant" { Spacer(minLength: 60) }
        }
        .padding(.horizontal, 16)
    }
}

struct MarkdownContentView: View {
    let content: String
    let role: String
    
    var body: some View {
        let segments = parseMarkdown(content)
        VStack(alignment: .leading, spacing: 12) {
            ForEach(segments.indices, id: \.self) { i in
                if segments[i].isCode {
                    CodeBlock(code: segments[i].text)
                } else {
                    Text(.init(segments[i].text)) // SwiftUI Markdown for text
                        .font(.body)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
    
    struct Segment {
        let text: String
        let isCode: Bool
    }
    
    private func parseMarkdown(_ input: String) -> [Segment] {
        var segments: [Segment] = []
        let parts = input.components(separatedBy: "```")
        for (index, part) in parts.enumerated() {
            let isCode = index % 2 != 0
            if !part.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                segments.append(Segment(text: part, isCode: isCode))
            }
        }
        return segments
    }
}

struct CodeBlock: View {
    let code: String
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Code")
                    .font(.caption.bold())
                    .foregroundColor(.gray)
                Spacer()
                Image(systemName: "doc.on.doc")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(8)
            .background(.white.opacity(0.1))
            
            ScrollView(.horizontal) {
                Text(code)
                    .font(.system(.subheadline, design: .monospaced))
                    .padding(12)
            }
        }
        .background(Color.black.opacity(0.2))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.white.opacity(0.1), lineWidth: 1)
        )
    }
}
