import SwiftUI

// MARK: - College Logo View
// Reusable component: shows a college logo from Clearbit with a deterministic gradient+initials fallback.

struct CollegeLogoView: View {
    let collegeName: String
    let websiteURL: String?
    let size: CGFloat
    let cornerRadius: CGFloat

    init(_ collegeName: String, websiteURL: String? = nil, size: CGFloat = 48, cornerRadius: CGFloat = 12) {
        self.collegeName = collegeName
        self.websiteURL = websiteURL
        self.size = size
        self.cornerRadius = cornerRadius
    }

    var body: some View {
        if let url = CollegeLogoService.logoURL(for: websiteURL, size: Int(size * 2)) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: size, height: size)
                        .background(
                            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                                .fill(.white)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                case .failure:
                    fallbackView
                case .empty:
                    ProgressView()
                        .frame(width: size, height: size)
                @unknown default:
                    fallbackView
                }
            }
        } else {
            fallbackView
        }
    }

    // MARK: - Deterministic gradient + initials (existing behavior)

    private var fallbackView: some View {
        let colors = deterministicGradient(for: collegeName)
        return RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing))
            .frame(width: size, height: size)
            .overlay(
                Text(initialsFor(collegeName))
                    .font(.system(size: size * 0.35, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            )
    }

    private func initialsFor(_ name: String) -> String {
        let skip: Set<String> = ["of", "the", "and", "at", "in", "for"]
        let words = name.split(separator: " ").filter { !skip.contains($0.lowercased()) }
        if words.count >= 2 {
            return "\(words[0].prefix(1))\(words[1].prefix(1))".uppercased()
        }
        return String(name.prefix(2)).uppercased()
    }

    private func deterministicGradient(for name: String) -> [Color] {
        let gradients: [[Color]] = [
            [Color(red: 0.29, green: 0.49, blue: 0.35), Color(red: 0.45, green: 0.65, blue: 0.45)],
            [Color(red: 0.20, green: 0.35, blue: 0.55), Color(red: 0.35, green: 0.55, blue: 0.75)],
            [Color(red: 0.55, green: 0.25, blue: 0.30), Color(red: 0.75, green: 0.40, blue: 0.40)],
            [Color(red: 0.45, green: 0.30, blue: 0.55), Color(red: 0.65, green: 0.45, blue: 0.70)],
            [Color(red: 0.50, green: 0.40, blue: 0.20), Color(red: 0.70, green: 0.60, blue: 0.35)],
            [Color(red: 0.20, green: 0.45, blue: 0.50), Color(red: 0.35, green: 0.60, blue: 0.65)],
            [Color(red: 0.55, green: 0.35, blue: 0.20), Color(red: 0.75, green: 0.50, blue: 0.30)],
            [Color(red: 0.30, green: 0.30, blue: 0.50), Color(red: 0.50, green: 0.50, blue: 0.70)],
        ]
        let hash = name.unicodeScalars.reduce(0) { acc, scalar in
            (acc &* 31 &+ Int(scalar.value)) & 0x7FFFFFFF
        }
        return gradients[hash % gradients.count]
    }
}

#Preview {
    HStack(spacing: 16) {
        CollegeLogoView("University of Florida", websiteURL: "www.ufl.edu", size: 48)
        CollegeLogoView("Massachusetts Institute of Technology", websiteURL: "https://www.mit.edu", size: 48)
        CollegeLogoView("Unknown College", size: 48)
    }
    .padding()
    .background(LadderColors.surface)
}
