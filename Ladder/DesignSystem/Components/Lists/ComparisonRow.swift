import SwiftUI

// MARK: - Comparison Row (side-by-side metric display)

struct ComparisonRow: View {
    let label: String
    let leftValue: String
    let rightValue: String
    var leftAdvantage: Bool? = nil // true = left better, false = right better, nil = equal/N/A

    var body: some View {
        HStack {
            Text(leftValue)
                .font(LadderTypography.bodyMedium)
                .foregroundStyle(leftAdvantage == true ? LadderColors.primary : LadderColors.onSurface)
                .fontWeight(leftAdvantage == true ? .bold : .regular)
                .frame(maxWidth: .infinity, alignment: .trailing)

            Text(label)
                .font(LadderTypography.labelSmall)
                .foregroundStyle(LadderColors.onSurfaceVariant)
                .frame(width: 90)
                .multilineTextAlignment(.center)

            Text(rightValue)
                .font(LadderTypography.bodyMedium)
                .foregroundStyle(leftAdvantage == false ? LadderColors.primary : LadderColors.onSurface)
                .fontWeight(leftAdvantage == false ? .bold : .regular)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, LadderSpacing.xs)
    }
}
