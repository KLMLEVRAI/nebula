import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack {
            NebulaBackground()
                .ignoresSafeArea()
            
            TabView(selection: $selectedTab) {
                ChatView()
                    .tabItem {
                        Label("Chat", systemImage: "message.fill")
                    }
                    .tag(0)
                
                Text("Explorer coming soon...")
                    .tabItem {
                        Label("Explorer", systemImage: "compass.fill")
                    }
                    .tag(1)
                
                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gearshape.fill")
                    }
                    .tag(2)
            }
            .accentColor(.white)
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
                Text("Nebula Native v1.0")
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
