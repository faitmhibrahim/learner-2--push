//
//  ConfettiView.swift
//  learner
//
//  Created by Faitmh ibrahim on 29/04/1447 AH.
//


import SwiftUI

// MARK: - Confetti View 🎉
struct ConfettiView: View {
    @State private var particles: [ConfettiParticle] = []

    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                Circle()
                    .fill(particle.color)
                    .frame(width: particle.size, height: particle.size)
                    .position(particle.position)
                    .animation(.easeInOut(duration: particle.duration), value: particles)
            }
        }
        .onAppear {
            generateConfetti()
        }
    }

    func generateConfetti() {
        let colors: [Color] = [
            .orange, .yellow, .pink, .purple, .green, .blue
        ]
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height

        for _ in 0..<40 {
            let x = CGFloat.random(in: 0...screenWidth)
            let y = CGFloat.random(in: -50...screenHeight / 2)
            let color = colors.randomElement() ?? .orange
            let size = CGFloat.random(in: 6...14)
            let duration = Double.random(in: 2.5...4.5)
            let particle = ConfettiParticle(
                position: CGPoint(x: x, y: y),
                color: color,
                size: size,
                duration: duration
            )
            particles.append(particle)

            // حذف بعد المدة
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                particles.removeAll { $0.id == particle.id }
            }
        }
    }
}

// MARK: - Particle Model
struct ConfettiParticle: Identifiable, Equatable {
    let id = UUID()
    var position: CGPoint
    var color: Color
    var size: CGFloat
    var duration: Double

    static func == (lhs: ConfettiParticle, rhs: ConfettiParticle) -> Bool {
        // Compare by stable identity
        lhs.id == rhs.id
    }
}

#Preview {
    ConfettiView()
}
