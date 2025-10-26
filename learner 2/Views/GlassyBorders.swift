import SwiftUI

// MARK: - Glassy Borders Helpers

@ViewBuilder
public func glassyCircleBorder() -> some View {
    ZStack {
        // حد رئيسي خافت
        Circle().stroke(Color.white.opacity(0.14), lineWidth: 1)

        // لمعان علوي
        Circle()
            .stroke(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.28),
                        Color.white.opacity(0.08),
                        Color.clear
                    ],
                    startPoint: .top, endPoint: .bottom
                ),
                lineWidth: 2
            )

        // لمعان مائل بسيط
        Circle()
            .stroke(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.12),
                        Color.clear
                    ],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                ),
                lineWidth: 1
            )
            .blendMode(.overlay)

        // حد داخلي طفيف مع طمس خفيف لإحساس زجاجي
        Circle()
            .stroke(Color.white.opacity(0.10), lineWidth: 1)
            .blur(radius: 1.2)
    }
}

@ViewBuilder
public func glassyRoundedBorder(cornerRadius: CGFloat) -> some View {
    ZStack {
        RoundedRectangle(cornerRadius: cornerRadius)
            .stroke(Color.white.opacity(0.14), lineWidth: 1)

        RoundedRectangle(cornerRadius: cornerRadius)
            .stroke(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.28),
                        Color.white.opacity(0.08),
                        Color.clear
                    ],
                    startPoint: .top, endPoint: .bottom
                ),
                lineWidth: 2
            )

        RoundedRectangle(cornerRadius: cornerRadius)
            .stroke(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.12),
                        Color.clear
                    ],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                ),
                lineWidth: 1
            )
            .blendMode(.overlay)

        RoundedRectangle(cornerRadius: max(0, cornerRadius - 2))
            .stroke(Color.white.opacity(0.10), lineWidth: 1)
            .blur(radius: 1.2)
    }
}
