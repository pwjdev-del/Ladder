import SwiftUI

// MARK: - Child Switcher View
// For parents with multiple linked children — switch active child or add new ones

struct ChildSwitcherView: View {
    @State private var inviteManager = InviteCodeManager()
    @State private var selectedChildId: String?
    @State private var showAddChild = false
    @State private var newChildCode = ""
    @State private var addChildError: String?
    @State private var isLinking = false

    // TODO: Replace with real linked children from backend
    @State private var linkedChildren: [LinkedChild] = [
        LinkedChild(id: "1", name: "Alex Johnson", grade: 10, schoolName: "Pine Valley High School"),
        LinkedChild(id: "2", name: "Maya Johnson", grade: 12, schoolName: "Pine Valley High School"),
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: LadderSpacing.lg) {

                // MARK: - Header
                VStack(spacing: LadderSpacing.sm) {
                    Text("Your Children")
                        .font(LadderTypography.headlineSmall)
                        .foregroundStyle(LadderColors.onSurface)

                    Text("Select a child to view their progress")
                        .font(LadderTypography.bodyMedium)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                }
                .padding(.top, LadderSpacing.md)

                // MARK: - Children List
                VStack(spacing: LadderSpacing.md) {
                    ForEach(linkedChildren) { child in
                        childCard(child: child)
                    }
                }

                // MARK: - Add Another Child
                if showAddChild {
                    addChildSection
                } else {
                    Button {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showAddChild = true
                        }
                    } label: {
                        HStack(spacing: LadderSpacing.sm) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 20))
                            Text("Add Another Child")
                                .font(LadderTypography.titleMedium)
                        }
                        .foregroundStyle(LadderColors.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, LadderSpacing.lg)
                        .background(LadderColors.surfaceContainerLow)
                        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
            }
            .padding(LadderSpacing.lg)
        }
        .background(LadderColors.surface.ignoresSafeArea())
        .navigationTitle("Switch Child")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if selectedChildId == nil {
                selectedChildId = linkedChildren.first?.id
            }
        }
    }

    // MARK: - Child Card

    private func childCard(child: LinkedChild) -> some View {
        let isSelected = child.id == selectedChildId

        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedChildId = child.id
            }
        } label: {
            HStack(spacing: LadderSpacing.md) {
                // Avatar
                ZStack {
                    Circle()
                        .fill(isSelected ? LadderColors.primary : LadderColors.surfaceContainerHighest)
                        .frame(width: 52, height: 52)

                    Text(child.initials)
                        .font(LadderTypography.titleMedium)
                        .foregroundStyle(isSelected ? .white : LadderColors.onSurfaceVariant)
                }

                // Info
                VStack(alignment: .leading, spacing: LadderSpacing.xxs) {
                    Text(child.name)
                        .font(LadderTypography.titleMedium)
                        .foregroundStyle(LadderColors.onSurface)

                    HStack(spacing: LadderSpacing.sm) {
                        Text("Grade \(child.grade)")
                            .font(LadderTypography.bodySmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)

                        if let school = child.schoolName {
                            Text(school)
                                .font(LadderTypography.bodySmall)
                                .foregroundStyle(LadderColors.onSurfaceVariant)
                                .lineLimit(1)
                        }
                    }
                }

                Spacer()

                // Selection indicator
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(LadderColors.primary)
                } else {
                    Image(systemName: "circle")
                        .font(.system(size: 24))
                        .foregroundStyle(LadderColors.outlineVariant)
                }
            }
            .padding(LadderSpacing.md)
            .background(isSelected ? LadderColors.surfaceContainerLow : LadderColors.surfaceContainerLowest)
            .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
            .overlay {
                if isSelected {
                    RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous)
                        .stroke(LadderColors.primary.opacity(0.3), lineWidth: 2)
                }
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Add Child Section

    private var addChildSection: some View {
        LadderCard {
            VStack(spacing: LadderSpacing.lg) {
                Text("Add Another Child")
                    .font(LadderTypography.titleMedium)
                    .foregroundStyle(LadderColors.onSurface)

                Text("Enter the invite code from your child's Ladder app.")
                    .font(LadderTypography.bodyMedium)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
                    .multilineTextAlignment(.center)

                LadderTextField("6-digit invite code", text: $newChildCode, icon: "key")
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                    .onChange(of: newChildCode) { _, newValue in
                        if newValue.count > 6 {
                            newChildCode = String(newValue.prefix(6))
                        }
                        newChildCode = newChildCode.uppercased()
                    }

                if let error = addChildError {
                    HStack(spacing: LadderSpacing.xs) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 14))
                        Text(error)
                            .font(LadderTypography.bodySmall)
                    }
                    .foregroundStyle(LadderColors.error)
                }

                if isLinking {
                    ProgressView()
                        .tint(LadderColors.primary)
                } else {
                    HStack(spacing: LadderSpacing.md) {
                        LadderSecondaryButton("Cancel") {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showAddChild = false
                                newChildCode = ""
                                addChildError = nil
                            }
                        }

                        LadderPrimaryButton("Link", icon: "link") {
                            Task { await linkNewChild() }
                        }
                        .opacity(newChildCode.count == 6 ? 1.0 : 0.5)
                        .allowsHitTesting(newChildCode.count == 6)
                    }
                }
            }
        }
    }

    // MARK: - Actions

    private func linkNewChild() async {
        addChildError = nil
        isLinking = true
        defer { isLinking = false }

        let isValid = await inviteManager.validateCode(newChildCode)
        guard isValid else {
            addChildError = "Invalid or expired code. Please try again."
            return
        }

        do {
            try await inviteManager.linkParentToStudent(code: newChildCode)

            // TODO: Replace with actual student data from backend
            let newChild = LinkedChild(
                id: UUID().uuidString,
                name: "New Child",
                grade: 9,
                schoolName: nil
            )

            withAnimation(.easeInOut(duration: 0.3)) {
                linkedChildren.append(newChild)
                selectedChildId = newChild.id
                showAddChild = false
                newChildCode = ""
            }
        } catch {
            addChildError = "Failed to link. Please try again."
        }
    }
}

// MARK: - Linked Child Model

struct LinkedChild: Identifiable {
    let id: String
    let name: String
    let grade: Int
    let schoolName: String?

    var initials: String {
        let parts = name.split(separator: " ").prefix(2)
        return parts.compactMap { $0.first.map { String($0) } }.joined().uppercased()
    }
}

#Preview {
    NavigationStack {
        ChildSwitcherView()
    }
}
