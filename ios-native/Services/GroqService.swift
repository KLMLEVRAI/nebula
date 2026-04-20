import Foundation

struct ChatHistoryEntry: Codable, Identifiable {
    let id: UUID
    let date: Date
    let title: String
    let messages: [[String: String]]
}

class GroqService: ObservableObject {
    @Published var messages: [[String: String]] = []
    @Published var history: [ChatHistoryEntry] = []
    
    var apiKey: String = ""
    private let url = URL(string: "https://api.groq.com/openai/v1/chat/completions")!
    
    private let historyKey = "nebula_chat_history"
    
    init() {
        loadHistory()
    }
    
    func streamChat(input: String, model: String, temperature: Double) async {
        let userMessage = ["role": "user", "content": input]
        await MainActor.run {
            if messages.isEmpty {
                // New session, update history later
            }
            messages.append(userMessage)
            messages.append(["role": "assistant", "content": ""])
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "model": model,
            "messages": messages.dropLast(),
            "temperature": temperature,
            "stream": true
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        do {
            let (result, response) = try await URLSession.shared.bytes(for: request)
            
            guard (response as? HTTPURLResponse)?.statusCode == 200 else { return }
            
            for try await line in result.lines {
                if line.hasPrefix("data: ") {
                    let dataString = String(line.dropFirst(6))
                    if dataString.contains("[DONE]") { 
                        saveCurrentToHistory()
                        break 
                    }
                    
                    if let data = dataString.data(using: .utf8),
                       let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let choices = json["choices"] as? [[String: Any]],
                       let delta = choices.first?["delta"] as? [String: Any],
                       let content = delta["content"] as? String {
                        
                        await MainActor.run {
                            var lastMessage = messages.removeLast()
                            lastMessage["content"]? += content
                            messages.append(lastMessage)
                        }
                    }
                }
            }
        } catch {
            print("Streaming error: \(error)")
        }
    }
    
    private func saveCurrentToHistory() {
        guard !messages.isEmpty else { return }
        let title = messages.first?["content"]?.prefix(30).appending("...") ?? "New Chat"
        let entry = ChatHistoryEntry(id: UUID(), date: Date(), title: title, messages: messages)
        
        DispatchQueue.main.async {
            self.history.insert(entry, at: 0)
            self.saveHistory()
        }
    }
    
    private func saveHistory() {
        if let encoded = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(encoded, connect: historyKey)
        }
    }
    
    private func loadHistory() {
        if let data = UserDefaults.standard.data(forKey: historyKey),
           let decoded = try? JSONDecoder().decode([ChatHistoryEntry].self, from: data) {
            self.history = decoded
        }
    }
}
