import SwiftUI

struct ExerciseRowView: View {
    let exercise: Exercise
    let isExpanded: Bool
    @Binding var weight: Int
    @Binding var reps: Int
    let onTap: () -> Void
    let onAddSet: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // ── Exercise name row ──────────────────────────────────────────
            HStack {
                Text(exercise.name)
                    .foregroundColor(.primary)
                    .font(.body)
                Spacer()
            }
            .padding(.vertical, 14)
            .contentShape(Rectangle())
            .onTapGesture(perform: onTap)

            // ── Inline input panel ─────────────────────────────────────────
            if isExpanded {
                HStack(spacing: 0) {
                    Spacer()

                    VStack(spacing: 2) {
                        Text("Weight (lbs)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        SwipeableNumber(value: $weight, step: 5, minimum: 0)
                    }

                    Spacer()

                    VStack(spacing: 2) {
                        Text("Reps")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        SwipeableNumber(value: $reps, step: 1, minimum: 1)
                    }

                    Spacer()

                    Button(action: onAddSet) {
                        Text("Add Set")
                            .fontWeight(.semibold)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .buttonStyle(.plain)

                    Spacer()
                }
                .padding(.vertical, 12)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
}
