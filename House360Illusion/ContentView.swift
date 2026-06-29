//
//  ContentView.swift
//  House360Illusion
//
//  Created by Dawit Chernet on 2026-06-29.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var viewModel: IllusionViewModel
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace

    @State private var isImmersiveSpaceOpen = false
    @State private var animateEffects = false

    var body: some View {
        HStack(spacing: 0) {
            selectorPanel
            Divider()
            stagePanel
        }
        .frame(minWidth: 980, minHeight: 650)
        .background(.black.opacity(0.08))
        .onAppear {
            animateEffects = true
        }
    }

    private var selectorPanel: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Choose Illusion")
                .font(.title.bold())

            VStack(spacing: 10) {
                ForEach(IllusionTheme.allCases) { theme in
                    Button {
                        viewModel.select(theme)
                    } label: {
                        illusionSelectorRow(for: theme)
                    }
                    .buttonStyle(.plain)
                }
            }

            Spacer(minLength: 12)

            openButton
        }
        .padding(24)
        .frame(width: 320)
        .glassBackgroundEffect()
    }

    private func illusionSelectorRow(for theme: IllusionTheme) -> some View {
        HStack(spacing: 12) {
            Image(theme.assetName)
                .resizable()
                .scaledToFill()
                .frame(width: 92, height: 62)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 4) {
                Label(theme.rawValue, systemImage: theme.symbol)
                    .font(.headline)
                    .lineLimit(1)

                Text(theme.assetName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 4)

            if viewModel.selectedTheme == theme {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title3)
                    .foregroundStyle(.green)
            }
        }
        .padding(10)
        .frame(height: 82)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(viewModel.selectedTheme == theme ? theme.swiftUIColor.opacity(0.18) : .white.opacity(0.05))
        )
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(viewModel.selectedTheme == theme ? theme.swiftUIColor : .white.opacity(0.16), lineWidth: viewModel.selectedTheme == theme ? 2 : 1)
        }
    }

    private var stagePanel: some View {
        VStack(spacing: 18) {
            selectedImageStage
            controls
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var selectedImageStage: some View {
        ZStack {
            Image(viewModel.selectedTheme.assetName)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()

            if viewModel.showPortalRing {
                portalEffect
            }

            if viewModel.showParticles {
                particleEffect
            }

            if viewModel.showFloatingFurniture {
                furnitureEffect
            }

            LinearGradient(
                colors: [.black.opacity(0.18), .clear, .black.opacity(0.64)],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 6) {
                Label(viewModel.selectedTheme.rawValue, systemImage: viewModel.selectedTheme.symbol)
                    .font(.largeTitle.bold())
                    .foregroundStyle(.white)

                Text("Asset: \(viewModel.selectedTheme.assetName)")
                    .font(.headline)
                    .foregroundStyle(.white.opacity(0.78))
            }
            .padding(22)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
        }
        .frame(height: 450)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(viewModel.selectedTheme.swiftUIColor.opacity(0.85), lineWidth: 2)
        }
        .shadow(color: viewModel.selectedTheme.swiftUIColor.opacity(0.28), radius: 24)
    }

    private var portalEffect: some View {
        ZStack {
            Circle()
                .stroke(viewModel.selectedTheme.swiftUIColor.opacity(0.95), lineWidth: 6)
                .frame(width: 220, height: 220)
                .scaleEffect(animateEffects ? 1.08 : 0.92)

            Circle()
                .stroke(.white.opacity(0.72), style: StrokeStyle(lineWidth: 2, dash: [9, 12]))
                .frame(width: 270, height: 270)
                .rotationEffect(.degrees(animateEffects ? 360 : 0))
        }
        .shadow(color: viewModel.selectedTheme.swiftUIColor.opacity(0.9), radius: 22)
        .animation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true), value: animateEffects)
        .animation(.linear(duration: 7).repeatForever(autoreverses: false), value: animateEffects)
    }

    private var particleEffect: some View {
        GeometryReader { proxy in
            ForEach(0..<min(viewModel.particleCount, 48), id: \.self) { index in
                Circle()
                    .fill(index.isMultiple(of: 3) ? viewModel.selectedTheme.swiftUIColor.opacity(0.8) : .white.opacity(0.68))
                    .frame(width: particleSize(for: index), height: particleSize(for: index))
                    .position(
                        x: particleX(for: index, width: proxy.size.width),
                        y: particleY(for: index, height: proxy.size.height)
                    )
                    .offset(y: animateEffects ? -14 : 14)
                    .shadow(color: .white.opacity(0.8), radius: 8)
                    .animation(.easeInOut(duration: Double(2 + (index % 5))).repeatForever(autoreverses: true), value: animateEffects)
            }
        }
        .allowsHitTesting(false)
    }

    private var furnitureEffect: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(.brown.opacity(0.76))
                .frame(width: 170, height: 52)
                .overlay(alignment: .top) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.brown.opacity(0.66))
                        .frame(width: 170, height: 64)
                        .offset(y: -42)
                }
                .overlay(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(.brown.opacity(0.9))
                        .frame(width: 22, height: 62)
                        .offset(x: -10, y: -6)
                }
                .overlay(alignment: .trailing) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(.brown.opacity(0.9))
                        .frame(width: 22, height: 62)
                        .offset(x: 10, y: -6)
                }
                .offset(x: -155, y: 112)

            VStack(spacing: 0) {
                Circle()
                    .fill(.yellow.opacity(0.86))
                    .frame(width: 62, height: 42)
                Rectangle()
                    .fill(.white.opacity(0.72))
                    .frame(width: 7, height: 86)
            }
            .shadow(color: .yellow.opacity(0.9), radius: 18)
            .offset(x: 165, y: 62)
        }
        .offset(y: animateEffects ? -9 : 9)
        .animation(.easeInOut(duration: 2.1).repeatForever(autoreverses: true), value: animateEffects)
    }

    private var controls: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 18) {
                Toggle("Portal", isOn: $viewModel.showPortalRing)
                Toggle("Furniture", isOn: $viewModel.showFloatingFurniture)
                Toggle("Particles", isOn: $viewModel.showParticles)
            }
            .toggleStyle(.switch)

            HStack(spacing: 14) {
                Text("Particle Count")
                    .font(.headline)

                Slider(value: particleCountBinding, in: 10...120, step: 1)

                Text("\(viewModel.particleCount)")
                    .font(.headline.monospacedDigit())
                    .frame(width: 44, alignment: .trailing)
            }
        }
        .padding(18)
        .glassBackgroundEffect()
    }

    private var openButton: some View {
        Button {
            Task {
                if isImmersiveSpaceOpen {
                    await dismissImmersiveSpace()
                    isImmersiveSpaceOpen = false
                } else {
                    let result = await openImmersiveSpace(id: "House360Space")
                    isImmersiveSpaceOpen = result == .opened
                }
            }
        } label: {
            Label(
                isImmersiveSpaceOpen ? "Close Immersive" : "Open Immersive",
                systemImage: isImmersiveSpaceOpen ? "xmark.circle.fill" : "visionpro"
            )
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
    }

    private var particleCountBinding: Binding<Double> {
        Binding(
            get: { Double(viewModel.particleCount) },
            set: { viewModel.particleCount = Int($0) }
        )
    }

    private func particleSize(for index: Int) -> CGFloat {
        CGFloat(5 + (index % 5) * 2)
    }

    private func particleX(for index: Int, width: CGFloat) -> CGFloat {
        let unit = CGFloat((index * 37) % 100) / 100
        return max(18, min(width - 18, width * unit))
    }

    private func particleY(for index: Int, height: CGFloat) -> CGFloat {
        let unit = CGFloat((index * 61) % 100) / 100
        return max(18, min(height - 18, height * unit))
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
        .environmentObject(IllusionViewModel())
}
