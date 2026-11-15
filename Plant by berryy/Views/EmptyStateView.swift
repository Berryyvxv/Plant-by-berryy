import SwiftUI

// Shown on the main page when there are no plants yet
struct EmptyStateView: View {
    // Called when the user taps the button
    let onAddTapped: () -> Void

    private let accent = Color(red: 0.18, green: 0.5, blue: 0.38)

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 16) {
                Image("PlantPot")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 164, height: 200)

                Text("Start your plant journey!")
                    .font(.title2.weight(.semibold))

                Text("Now all your plants will be in one place and we will help you take care of them :)🪴")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }

            Spacer()

            Button(action: onAddTapped) {
                Text("Set Plant Reminder")
                    .font(.callout.weight(.medium))
                    .foregroundStyle(.white)
                    .frame(maxWidth: 280)
                    .padding(.vertical, 12)
                    .background(accent, in: Capsule())
                    .overlay(Capsule().strokeBorder(.white.opacity(0.25), lineWidth: 1))
            }
            .buttonStyle(.plain)

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    EmptyStateView {}
        .preferredColorScheme(.dark)
}
