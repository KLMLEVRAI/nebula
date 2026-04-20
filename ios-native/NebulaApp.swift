import SwiftUI

struct ContentView: View {
    @StateObject var groq = GroqService()
    @State private var showHistory = false
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack {
            NebulaBackground()
                .ignoresSafeArea()
            
            NavigationStack {
                ChatView(groq: groq)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button(action: { showHistory.toggle() }) {
                                Image(systemName: "line.3.horizontal")
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .sheet(isPresented: $showHistory) {
                        HistoryView(groq: groq)
                            .presentationDetents([.medium, .large])
                            .presentationBackground(.ultraThinMaterial)
                    }
            }
            .accentColor(.white)
        }
    }
}

struct HistoryView: View {
    @ObservedObject var groq: GroqService
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(groq.history) { entry in
                    Button(action: {
                        groq.messages = entry.messages
                        dismiss()
                    }) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(entry.title)
                                .font(.headline)
                            Text(entry.date, style: .date)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .listRowBackground(Color.white.opacity(0.05))
                }
                .onDelete { indices in
                    groq.history.remove(atOffsets: indices)
                }
            }
            .navigationTitle("Historique")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fermer") { dismiss() }
                }
            }
            .scrollContentBackground(.hidden)
        }
    }
}

struct SettingsView: View {
    @AppStorage("selectedModel") private var selectedModel = "llama-3.1-8b-instant"
    @AppStorage("temperature") private var temperature = 0.7
    @AppStorage("apiKey") private var apiKey = ""
    
    var body: some View {
        Form {
            Section(header: Text("AI Config").foregroundColor(.gray)) {
                Picker("Model", selection: $selectedModel) {
                    Text("Llama 3.1 8B").tag("llama-3.1-8b-instant")
                    Text("Llama 3.1 70B").tag("llama-3.1-70b-versatile")
                    Text("Mixtral 8x7B").tag("mixtral-8x7b-32768")
                }
                
                HStack {
                    Text("Temperature")
                    Slider(value: $temperature, in: 0...1)
                    Text(String(format: "%.1f", temperature))
                }
                
                SecureField("Groq API Key", text: $apiKey)
            }
            .listRowBackground(Color.white.opacity(0.05))
            
            Section(header: Text("About").foregroundColor(.gray)) {
                Text("Nebula Pro v1.1 - iPhone 12 Optimized")
            }
            .listRowBackground(Color.white.opacity(0.05))
        }
        .scrollContentBackground(.hidden)
        .navigationTitle("Settings")
    }
}

@main
struct NebulaApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
        }
    }
}
