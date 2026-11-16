import SwiftUI

// A list row that slides left to reveal a red trash pill, matching the design.
// SwiftUI's built-in swipeActions can't change the button's size or shape (an icon-only
// action is always a circle), so the swipe is built by hand.
struct SwipeToDeleteRow<Content: View>: View {
    // Called when the trash is tapped. The caller decides what happens (we ask for confirmation).
    let onDelete: () -> Void
    @ViewBuilder let content: Content

    // How far the row is currently slid to the left (0 = closed)
    @State private var offset: CGFloat = 0
    @State private var isOpen = false

    // Design: a 62 x 45 pill, 13pt from the screen edge, 5pt away from the row
    private let pillSize = CGSize(width: 62, height: 45)
    private let pillTrailingPadding: CGFloat = 13
    private let revealWidth: CGFloat = 80

    var body: some View {
        ZStack(alignment: .trailing) {
            deleteButton

            content
                .offset(x: offset)
                // While open, taps must close the row instead of reaching the row's own buttons
                .allowsHitTesting(!isOpen)

            if isOpen {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture { setOpen(false) }
                    .padding(.trailing, revealWidth)
            }
        }
        // simultaneous, so vertical scrolling of the List keeps working
        .simultaneousGesture(drag)
        .accessibilityAction(named: "Delete", onDelete)
    }

    private var deleteButton: some View {
        Button {
            setOpen(false)
            onDelete()
        } label: {
            Image(systemName: "trash.fill")
                .font(.system(size: 20))
                .foregroundStyle(.white)
                .frame(width: pillSize.width, height: pillSize.height)
                .background(PlantColors.deleteButton, in: Capsule())
        }
        .buttonStyle(.plain)
        .padding(.trailing, pillTrailingPadding)
        // Fades in as the row slides, so it is invisible while the row is closed
        .opacity(min(1, max(0, -offset / 30)))
        .allowsHitTesting(isOpen)
        // VoiceOver uses the "Delete" action above instead
        .accessibilityHidden(true)
    }

    private var drag: some Gesture {
        DragGesture(minimumDistance: 12)
            .onChanged { value in
                // Ignore mostly vertical drags: those are the List scrolling
                guard abs(value.translation.width) > abs(value.translation.height) else { return }

                let start: CGFloat = isOpen ? -revealWidth : 0
                // Can't slide right of closed, and only a little past fully open
                offset = min(0, max(-revealWidth - 16, start + value.translation.width))
            }
            .onEnded { _ in
                // Snap open if the row was dragged past halfway, otherwise snap closed
                setOpen(offset < -revealWidth / 2)
            }
    }

    private func setOpen(_ open: Bool) {
        withAnimation(.snappy) {
            isOpen = open
            offset = open ? -revealWidth : 0
        }
    }
}
