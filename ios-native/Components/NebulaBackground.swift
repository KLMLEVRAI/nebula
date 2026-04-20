import SwiftUI

struct NebulaBackground: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            Color(red: 0.01, green: 0.01, blue: 0.06)
                .ignoresSafeArea()
            
            // Animated blobs
            ZStack {
                Circle()
                    .fill(Color.purple)
                    .frame(width: 400, height: 400)
                    .blur(radius: 80)
                    .opacity(0.4)
                    .offset(x: animate ? 100 : -100, y: animate ? -100 : 100)
                
                Circle()
                    .fill(Color.blue)
                    .frame(width: 500, height: 500)
                    .blur(radius: 100)
                    .opacity(0.3)
                    .offset(x: animate ? -150 : 150, y: animate ? 150 : -150)
                
                Circle()
                    .fill(Color.indigo)
                    .frame(width: 300, height: 300)
                    .blur(radius: 70)
                    .opacity(0.2)
                    .offset(x: animate ? 50 : -50, y: animate ? 50 : -50)
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 20).repeatForever(autoreverses: true)) {
                    animate.toggle()
                }
            }
        }
    }
}

struct GlassView: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(.white.opacity(0.1), lineWidth: 1)
            )
    }
}

extension View {
    func glassmorphism() -> some View {
        self.modifier(GlassView())
    }
}
