import SwiftUI

// MARK: - Wheel of Career (Radar Chart Visualization)
// Shows student's holistic status across 6 dimensions
// The "4W + H" principle: What, How, When, Where + financial readiness

struct WheelOfCareerView: View {
    @Environment(\.dismiss) private var dismiss

    // In production these would come from StudentProfileModel
    let dimensions: [CareerDimension] = [
        CareerDimension(name: "Academics", score: 0.72, icon: "graduationcap", color: Color(red: 0.26, green: 0.38, blue: 0.25)),
        CareerDimension(name: "Activities", score: 0.45, icon: "figure.run", color: Color(red: 0.15, green: 0.50, blue: 0.35)),
        CareerDimension(name: "Test Prep", score: 0.30, icon: "pencil.and.list.clipboard", color: Color(red: 0.15, green: 0.35, blue: 0.55)),
        CareerDimension(name: "Career Clarity", score: 0.60, icon: "sparkles", color: Color(red: 0.55, green: 0.30, blue: 0.10)),
        CareerDimension(name: "Financial Aid", score: 0.25, icon: "dollarsign.circle", color: Color(red: 0.50, green: 0.20, blue: 0.45)),
        CareerDimension(name: "Applications", score: 0.10, icon: "envelope.open", color: Color(red: 0.55, green: 0.15, blue: 0.15)),
    ]

    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(spacing: LadderSpacing.xl) {
                    headerCard
                    radarChart
                    dimensionList
                    adviceSection
                }
                .padding(.horizontal, LadderSpacing.md)
                .padding(.top, LadderSpacing.md)
                .padding(.bottom, 120)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left").font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(LadderColors.onSurface)
                }
            }
            ToolbarItem(placement: .principal) {
                Text("Wheel of Career").font(LadderTypography.titleMedium).foregroundStyle(LadderColors.onSurface)
            }
        }
    }

    // MARK: - Header

    private var headerCard: some View {
        LadderCard {
            VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("YOUR CAREER READINESS").font(LadderTypography.labelSmall)
                            .foregroundStyle(LadderColors.accentLime).labelTracking()
                        Text("Overall: \(Int(overallScore * 100))%").font(LadderTypography.headlineSmall)
                            .foregroundStyle(LadderColors.onSurface)
                        Text(overallInsight).font(LadderTypography.bodySmall).foregroundStyle(LadderColors.onSurfaceVariant)
                    }
                    Spacer()
                    CircularProgressView(progress: overallScore, label: "\(Int(overallScore * 100))%", size: 64)
                }
            }
        }
    }

    // MARK: - Radar Chart

    private var radarChart: some View {
        LadderCard {
            VStack(spacing: LadderSpacing.md) {
                Text("Career Readiness Radar").font(LadderTypography.titleMedium).foregroundStyle(LadderColors.onSurface)

                ZStack {
                    // Background grid rings
                    ForEach([0.2, 0.4, 0.6, 0.8, 1.0], id: \.self) { ring in
                        RadarPolygon(sides: dimensions.count, scale: ring)
                            .stroke(LadderColors.outlineVariant.opacity(0.4), lineWidth: 1)
                            .frame(width: 240, height: 240)
                    }

                    // Spoke lines
                    RadarSpokes(sides: dimensions.count)
                        .stroke(LadderColors.outlineVariant.opacity(0.4), lineWidth: 1)
                        .frame(width: 240, height: 240)

                    // Filled score polygon
                    RadarScorePolygon(sides: dimensions.count, scores: dimensions.map(\.score))
                        .fill(LadderColors.accentLime.opacity(0.25))
                        .frame(width: 240, height: 240)

                    RadarScorePolygon(sides: dimensions.count, scores: dimensions.map(\.score))
                        .stroke(LadderColors.accentLime, lineWidth: 2)
                        .frame(width: 240, height: 240)

                    // Score dots
                    RadarDots(sides: dimensions.count, scores: dimensions.map(\.score))
                        .frame(width: 240, height: 240)

                    // Labels
                    RadarLabels(dimensions: dimensions)
                        .frame(width: 300, height: 300)
                }
                .frame(width: 300, height: 300)
            }
        }
    }

    // MARK: - Dimension List

    private var dimensionList: some View {
        VStack(spacing: LadderSpacing.sm) {
            ForEach(dimensions) { dim in
                dimensionRow(dim)
            }
        }
    }

    private func dimensionRow(_ dim: CareerDimension) -> some View {
        LadderCard {
            HStack(spacing: LadderSpacing.md) {
                ZStack {
                    Circle().fill(dim.color.opacity(0.15)).frame(width: 40, height: 40)
                    Image(systemName: dim.icon).font(.system(size: 18)).foregroundStyle(dim.color)
                }
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(dim.name).font(LadderTypography.titleSmall).foregroundStyle(LadderColors.onSurface)
                        Spacer()
                        Text("\(Int(dim.score * 100))%").font(LadderTypography.labelMedium)
                            .foregroundStyle(dim.score >= 0.6 ? LadderColors.accentLime : dim.score >= 0.35 ? LadderColors.primary : Color.orange)
                    }
                    LinearProgressBar(progress: dim.score)
                    Text(dim.advice).font(LadderTypography.bodySmall).foregroundStyle(LadderColors.onSurfaceVariant)
                }
            }
        }
    }

    // MARK: - Advice

    private var adviceSection: some View {
        LadderCard {
            VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                HStack(spacing: LadderSpacing.sm) {
                    Image(systemName: "lightbulb.fill").foregroundStyle(LadderColors.accentLime)
                    Text("Focus Areas This Month").font(LadderTypography.titleMedium).foregroundStyle(LadderColors.onSurface)
                }
                let weakest = dimensions.sorted { $0.score < $1.score }.prefix(3)
                ForEach(Array(weakest.enumerated()), id: \.offset) { i, dim in
                    HStack(alignment: .top, spacing: LadderSpacing.sm) {
                        Text("\(i + 1).").font(LadderTypography.labelMedium).foregroundStyle(LadderColors.accentLime).frame(width: 16)
                        Text(dim.focusTip).font(LadderTypography.bodySmall).foregroundStyle(LadderColors.onSurface)
                    }
                }
            }
        }
    }

    private var overallScore: Double { dimensions.map(\.score).reduce(0, +) / Double(dimensions.count) }
    private var overallInsight: String {
        let s = overallScore
        if s < 0.3 { return "Just getting started — that's perfectly fine!" }
        if s < 0.5 { return "Good progress — focus on your weakest areas" }
        if s < 0.7 { return "Strong foundation — keep pushing" }
        return "Excellent trajectory — stay consistent"
    }
}

// MARK: - Dimension Model

struct CareerDimension: Identifiable {
    let id = UUID()
    let name: String
    let score: Double   // 0.0 – 1.0
    let icon: String
    let color: Color

    var advice: String {
        switch name {
        case "Academics":     return score < 0.5 ? "GPA below target. Talk to your counselor about class adjustments." : "GPA looks solid. Keep it up through senior year."
        case "Activities":    return score < 0.5 ? "Need more extracurriculars. Focus on General + Career activities." : "Good activity mix. Aim for leadership roles."
        case "Test Prep":     return score < 0.5 ? "Start SAT prep now. Khan Academy is free and effective." : "SAT/ACT scores are competitive for your target schools."
        case "Career Clarity": return score < 0.5 ? "Take the Career Quiz to find your path." : "You have a clear direction — now find schools that match."
        case "Financial Aid": return score < 0.5 ? "Fill out FAFSA and check SAT fee waivers for eligibility." : "Good financial planning. Review merit scholarship options."
        case "Applications":  return score < 0.5 ? "Build your college list: 2 reach, 2 match, 1 safety." : "Application list looks balanced."
        default:              return "Keep working on this area."
        }
    }

    var focusTip: String {
        switch name {
        case "Academics":     return "Schedule a tutoring session or form a study group this week"
        case "Activities":    return "Sign up for one new club or log your volunteer hours"
        case "Test Prep":     return "Do 30 min of Khan Academy SAT prep today"
        case "Career Clarity": return "Take the Career Quiz and explore 3 colleges in your bucket"
        case "Financial Aid": return "Spend 20 min exploring scholarship options on our Scholarships tab"
        case "Applications":  return "Add 2 more schools to your college list and check their deadlines"
        default:              return "Spend 15 minutes focusing on \(name) today"
        }
    }
}

// MARK: - Radar Chart Shapes

struct RadarPolygon: Shape {
    let sides: Int; let scale: Double
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2 * scale
        for i in 0..<sides {
            let angle = (Double(i) / Double(sides)) * 2 * .pi - .pi / 2
            let pt = CGPoint(x: center.x + radius * cos(angle), y: center.y + radius * sin(angle))
            i == 0 ? path.move(to: pt) : path.addLine(to: pt)
        }
        path.closeSubpath()
        return path
    }
}

struct RadarSpokes: Shape {
    let sides: Int
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        for i in 0..<sides {
            let angle = (Double(i) / Double(sides)) * 2 * .pi - .pi / 2
            path.move(to: center)
            path.addLine(to: CGPoint(x: center.x + radius * cos(angle), y: center.y + radius * sin(angle)))
        }
        return path
    }
}

struct RadarScorePolygon: Shape {
    let sides: Int; let scores: [Double]
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        for i in 0..<sides {
            let angle = (Double(i) / Double(sides)) * 2 * .pi - .pi / 2
            let r = radius * scores[i]
            let pt = CGPoint(x: center.x + r * cos(angle), y: center.y + r * sin(angle))
            i == 0 ? path.move(to: pt) : path.addLine(to: pt)
        }
        path.closeSubpath()
        return path
    }
}

struct RadarDots: View {
    let sides: Int; let scores: [Double]
    var body: some View {
        GeometryReader { geo in
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
            let radius = min(geo.size.width, geo.size.height) / 2
            ForEach(0..<sides, id: \.self) { i in
                let angle = (Double(i) / Double(sides)) * 2 * .pi - .pi / 2
                let r = radius * scores[i]
                Circle().fill(LadderColors.accentLime).frame(width: 8, height: 8)
                    .position(x: center.x + r * cos(angle), y: center.y + r * sin(angle))
            }
        }
    }
}

struct RadarLabels: View {
    let dimensions: [CareerDimension]
    var body: some View {
        GeometryReader { geo in
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
            let radius = min(geo.size.width, geo.size.height) / 2 * 0.85
            ForEach(Array(dimensions.enumerated()), id: \.offset) { i, dim in
                let angle = (Double(i) / Double(dimensions.count)) * 2 * .pi - .pi / 2
                let x = center.x + radius * cos(angle)
                let y = center.y + radius * sin(angle)
                VStack(spacing: 2) {
                    Image(systemName: dim.icon).font(.system(size: 11)).foregroundStyle(LadderColors.accentLime)
                    Text(dim.name).font(.system(size: 9, weight: .medium)).foregroundStyle(LadderColors.onSurface)
                        .multilineTextAlignment(.center).lineLimit(2)
                }
                .frame(width: 56)
                .position(x: x, y: y)
            }
        }
    }
}

#Preview {
    NavigationStack { WheelOfCareerView() }
}
