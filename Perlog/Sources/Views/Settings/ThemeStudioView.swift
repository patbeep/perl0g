import SwiftUI

struct ThemeStudioView: View {
    @EnvironmentObject private var theme: ThemeStore

    var body: some View {
        ZStack {
            theme.background.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Theme Studio")
                            .font(.title2.weight(.bold))
                            .foregroundStyle(theme.primaryText)
                        Text("Make Perlog yours")
                            .font(.subheadline)
                            .foregroundStyle(theme.secondaryText)
                    }

                    VStack(spacing: 10) {
                        ForEach(ThemePreset.allCases) { preset in
                            presetRow(preset)
                        }
                    }

                    if theme.preset == .custom || theme.preset == .iridescent {
                        GlassCard {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Text("Base hue")
                                        .font(.subheadline.weight(.medium))
                                        .foregroundStyle(theme.primaryText)
                                    Spacer()
                                    Text("\(Int(theme.customHue * 360))°")
                                        .font(.caption)
                                        .foregroundStyle(theme.secondaryText)
                                }
                                huesSlider
                                Text("Adjusts your accent color and record-type colors.")
                                    .font(.caption2)
                                    .foregroundStyle(theme.secondaryText)
                            }
                        }
                    }

                    Button("Restore default") {
                        withAnimation {
                            theme.preset = .black
                            theme.customHue = 0.62
                        }
                    }
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(theme.accent)
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding()
            }
        }
        .navigationTitle("Theme Studio")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func presetRow(_ preset: ThemePreset) -> some View {
        Button {
            withAnimation { theme.preset = preset }
        } label: {
            GlassCard {
                HStack(spacing: 12) {
                    Image(systemName: theme.preset == preset ? "largecircle.fill.circle" : "circle")
                        .foregroundStyle(theme.preset == preset ? theme.accent : theme.secondaryText)

                    swatch(for: preset)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(preset.displayName)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(theme.primaryText)
                        Text(preset.subtitle)
                            .font(.caption2)
                            .foregroundStyle(theme.secondaryText)
                    }
                    Spacer()
                }
            }
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func swatch(for preset: ThemePreset) -> some View {
        let shape = Circle()
        switch preset {
        case .black:
            shape.fill(Color.black).frame(width: 28, height: 28).overlay(shape.strokeBorder(.white.opacity(0.2)))
        case .grey:
            shape.fill(Color(white: 0.35)).frame(width: 28, height: 28)
        case .white:
            shape.fill(Color.white).frame(width: 28, height: 28).overlay(shape.strokeBorder(.black.opacity(0.15)))
        case .iridescent:
            shape.fill(
                AngularGradient(colors: [.pink, .purple, .blue, .green, .yellow, .pink], center: .center)
            )
            .frame(width: 28, height: 28)
        case .custom:
            shape.fill(Color(hue: theme.customHue, saturation: 0.75, brightness: 0.95))
                .frame(width: 28, height: 28)
        }
    }

    private var huesSlider: some View {
        ZStack(alignment: .leading) {
            LinearGradient(
                colors: stride(from: 0.0, through: 1.0, by: 0.1).map { Color(hue: $0, saturation: 0.75, brightness: 0.95) },
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(height: 8)
            .clipShape(Capsule())

            Slider(value: $theme.customHue, in: 0...1)
                .tint(.clear)
        }
    }
}

#Preview {
    NavigationStack {
        ThemeStudioView()
            .environmentObject(ThemeStore())
    }
}
