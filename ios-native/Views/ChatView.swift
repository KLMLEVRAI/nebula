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
    @StateObject var groq = GroqService()
    @State private var inputText = ""
    @AppStorage("selectedModel") private var selectedModel = "llama-3.1-8b-instant"
    @AppStorage("apiKey") private var apiKey = ""
    
    @ScaledMetric var bubblePadding: CGFloat = 12
    
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
                    LazyVStack(spacing: 20) {
                        if groq.messages.isEmpty {
                            welcomeView
                        }
                        
                        ForEach(0..<groq.messages.count, id: \.self) { index in
                            let msg = groq.messages[index]
                            MessageBubble(role: msg["role"] ?? "", content: msg["content"] ?? "")
                                .id(index)
                                .transition(.asymmetric(
                                    insertion: .move(edge: .bottom).combined(with: .opacity),
                                    removal: .opacity
                                ))
                        }
                    }
                    .padding(.vertical, 20)
                }
                .onChange(of: groq.messages.count) { _ in
                    withAnimation(.spring()) {
                        proxy.scrollTo(groq.messages.count - 1, anchor: .bottom)
                    }
                }
            }
            
            // Bottom Area
            VStack(spacing: 12) {
                // Quick Prompts
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
                
                // Input Bar
                HStack(spacing: 12) {
                    TextField("Messagerie Nebula...", text: $inputText)
                        .padding(14)
                        .background(.white.opacity(0.1))
                        .cornerRadius(24)
                        .onSubmit { sendMessage() }
                    
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
                .padding(.bottom, 12)
            }
            .background(.ultraThinMaterial)
        }
    }
    
    var welcomeView: some View {
        VStack(spacing: 20) {
            Spacer(minLength: 150)
            Image(systemName: "sparkles")
                .font(.system(size: 60))
                .foregroundStyle(.linearGradient(colors: [.purple, .blue], startPoint: .top, endPoint: .bottom))
            
            Text("Nebula")
                .font(.title.bold())
            
            Text("L'intelligence augmentée, nativement sur votre iPhone.")
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
        HStack {
            if role == "user" { Spacer(minLength: 60) }
            
            // Using Markdown support in iOS 15+ via LocalizedStringKey
            Text(.init(content))
                .font(.body)
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
        .padding(.horizontal, 12)
    }
}
