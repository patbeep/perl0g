import SwiftUI

/// A frosted rounded-rectangle background used for rows, sheets, and
/// panels throughout the app, matching the glass look in the reference
/// designs.
struct GlassCard<Content: View>: View {
    @EnvironmentObject private var theme: ThemeStore
    var padding: CGFloat
    var cornerRadius: CGFloat
    let content: Content

    init(padding: CGFloat = 14, cornerRadius: CGFloat = 18, @ViewBuilder content: () -> Content) {
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
            .background(theme.glassMaterial, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(theme.cardStroke, lineWidth: 1)
            )
    }
}

/// The small rounded-square icon badge shown at the leading edge of a
/// timeline row (camera, fork & knife, plane, music note, etc).
struct TypeBadge: View {
    @EnvironmentObject private var theme: ThemeStore
    let type: EntryType
    var size: CGFloat = 34

    var body: some View {
        RoundedRectangle(cornerRadius: size * 0.32, style: .continuous)
            .fill(theme.tint(for: type).opacity(0.22))
            .frame(width: size, height: size)
            .overlay(
                Image(systemName: type.systemImage)
                    .font(.system(size: size * 0.46, weight: .semibold))
                    .foregroundStyle(theme.tint(for: type))
            )
    }
}

/// A small pill used for tags, mood labels, and quick metadata.
struct TagChip: View {
    @EnvironmentObject private var theme: ThemeStore
    let label: String
    var systemImage: String?
    var tint: Color?
    var onRemove: (() -> Void)?

    var body: some View {
        HStack(spacing: 4) {
            if let systemImage {
                Image(systemName: systemImage)
                    .font(.caption2.weight(.semibold))
            }
            Text(label)
                .font(.caption.weight(.medium))
                .lineLimit(1)
            if let onRemove {
                Button(action: onRemove) {
                    Image(systemName: "xmark")
                        .font(.system(size: 9, weight: .bold))
                }
                .buttonStyle(.plain)
            }
        }
        .foregroundStyle(tint ?? theme.primaryText.opacity(0.85))
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background((tint ?? theme.accent).opacity(0.16), in: Capsule())
    }
}

/// The pill-shaped primary action button ("Save record").
struct GlassPrimaryButton: View {
    @EnvironmentObject private var theme: ThemeStore
    let title: String
    var isEnabled: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
        }
        .buttonStyle(.plain)
        .foregroundStyle(.white)
        .background(
            (isEnabled ? theme.accent : theme.accent.opacity(0.35)),
            in: RoundedRectangle(cornerRadius: 16, style: .continuous)
        )
        .disabled(!isEnabled)
    }
}
