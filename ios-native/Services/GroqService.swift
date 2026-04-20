import Foundation

class GroqService: ObservableObject {
    @Published var messages: [[String: String]] = []
    
    @Published var apiKey: String = "" // Injected from Settings/Storage
    private let url = URL(string: "https://api.groq.com/openai/v1/chat/completions")!
    
    func streamChat(input: String, model: String, temperature: Double) async {
        let userMessage = ["role": "user", "content": input]
        await MainActor.run {
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
            
            guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                print("Error: Invalid response")
                return
            }
            
            for try await line in result.lines {
                if line.hasPrefix("data: ") {
                    let dataString = String(line.dropFirst(6))
                    if dataString.contains("[DONE]") { break }
                    
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
}
