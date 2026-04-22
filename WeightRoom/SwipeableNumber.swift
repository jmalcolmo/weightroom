import SwiftUI

/// A number display the user can swipe up/down to change.
/// Swipe up = increase, swipe down = decrease.
/// Every 30pt of drag = one step. Not speed-based — value tracks finger position.
struct SwipeableNumber: View {
    @Binding var value: Int
    let step: Int
    let minimum: Int

    @State private var isDragging = false
    @State private var baseValue = 0

    var body: some View {
        Text("\(value)")
            .font(.title2)
            .fontWeight(.bold)
            .monospacedDigit()
            .frame(minWidth: 52)
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 5)
                .onChanged { drag in
                    if !isDragging {
                        isDragging = true
                        baseValue = value
                    }
                    let steps = Int(-drag.translation.height / 30)
                    value = max(minimum, baseValue + steps * step)
                }
                .onEnded { _ in
                    isDragging = false
                    baseValue = value
                }
        )
    }
}
