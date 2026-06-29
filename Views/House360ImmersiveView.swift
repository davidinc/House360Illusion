//
//  House360ImmersiveView.swift
//  House360Illusion
//
//  Created by Dawit Chernet on 2026-06-29.
//

import SwiftUI
import RealityKit
import UIKit

private struct IllusionSceneConfiguration: Equatable {
    let theme: IllusionTheme
    let particleCount: Int
    let showFloatingFurniture: Bool
    let showPortalRing: Bool
    let showParticles: Bool
}

struct House360ImmersiveView: View {
    @EnvironmentObject private var viewModel: IllusionViewModel
    @State private var root = Entity()
    @State private var activeConfiguration: IllusionSceneConfiguration?

    var body: some View {
        RealityView { content in
            content.add(root)

            let configuration = sceneConfiguration
            activeConfiguration = configuration
            await rebuildScene(using: configuration)
        } update: { _ in
            let configuration = sceneConfiguration

            guard activeConfiguration != configuration else {
                return
            }

            activeConfiguration = configuration
            Task {
                await rebuildScene(using: configuration)
            }
        }
    }

    private var sceneConfiguration: IllusionSceneConfiguration {
        IllusionSceneConfiguration(
            theme: viewModel.selectedTheme,
            particleCount: viewModel.particleCount,
            showFloatingFurniture: viewModel.showFloatingFurniture,
            showPortalRing: viewModel.showPortalRing,
            showParticles: viewModel.showParticles
        )
    }

    private func rebuildScene(using configuration: IllusionSceneConfiguration) async {
        let sphere = await make360InteriorSphere(for: configuration.theme)

        for child in root.children {
            child.removeFromParent()
        }

        root.addChild(sphere)
        addLighting(for: configuration.theme)
        addGroundGlow(for: configuration.theme)

        if configuration.showPortalRing {
            addPortalRing(for: configuration.theme)
        }

        if configuration.showFloatingFurniture {
            addFloatingSofa()
            addFloatingLamp()
            addGlassTable()
            addWindowFrame()
        }

        if configuration.showParticles {
            addParticles(count: configuration.particleCount, theme: configuration.theme)
        }

        addTitleText(for: configuration.theme)
    }

    // MARK: - 360 World

    private func make360InteriorSphere(for theme: IllusionTheme) async -> ModelEntity {
        let mesh = MeshResource.generateSphere(radius: 8)
        var material = UnlitMaterial()

        if let image = UIImage(named: theme.assetName),
           let cgImage = image.cgImage,
           let texture = try? await TextureResource(
                image: cgImage,
                withName: theme.assetName,
                options: .init(semantic: .color)
           ) {
            material.color = .init(texture: .init(texture))
        } else {
            material.color = .init(tint: theme.color.withAlphaComponent(0.85))
        }

        let sphere = ModelEntity(mesh: mesh, materials: [material])
        sphere.scale = [-1, 1, 1]
        sphere.position = [0, 1.2, 0]

        return sphere
    }

    // MARK: - Lighting

    private func addLighting(for theme: IllusionTheme) {
        let mainLight = PointLight()
        mainLight.light.intensity = 1200
        mainLight.light.color = .white
        mainLight.position = [0, 2.3, -1.2]
        root.addChild(mainLight)

        let themeLight = PointLight()
        themeLight.light.intensity = 900
        themeLight.light.color = theme.color
        themeLight.position = [0, 1.5, -1.4]
        root.addChild(themeLight)
    }

    private func addGroundGlow(for theme: IllusionTheme) {
        let ringRoot = Entity()
        let dotCount = 64
        let radius: Float = 1.25

        for index in 0..<dotCount {
            let angle = Float(index) / Float(dotCount) * Float.pi * 2
            let x = cos(angle) * radius
            let z = sin(angle) * radius

            let dot = ModelEntity(
                mesh: .generateSphere(radius: 0.01),
                materials: [SimpleMaterial(color: theme.color.withAlphaComponent(0.45), isMetallic: false)]
            )

            dot.position = [x, 0, z]
            ringRoot.addChild(dot)
        }

        ringRoot.position = [0, 0.72, -1.35]
        root.addChild(ringRoot)
    }

    // MARK: - Portal

    private func addPortalRing(for theme: IllusionTheme) {
        let ringRoot = Entity()
        let dotCount = 72
        let radius: Float = 0.95

        for index in 0..<dotCount {
            let angle = Float(index) / Float(dotCount) * Float.pi * 2
            let x = cos(angle) * radius
            let y = sin(angle) * radius

            let dot = ModelEntity(
                mesh: .generateSphere(radius: 0.015),
                materials: [SimpleMaterial(color: theme.color.withAlphaComponent(0.75), isMetallic: false)]
            )

            dot.position = [x, y, 0]
            ringRoot.addChild(dot)
        }

        ringRoot.position = [0, 1.45, -1.45]
        root.addChild(ringRoot)
        addPortalSparkles(around: [0, 1.45, -1.45], theme: theme)
    }

    private func addPortalSparkles(around center: SIMD3<Float>, theme: IllusionTheme) {
        for _ in 0..<24 {
            let particle = ModelEntity(
                mesh: .generateSphere(radius: Float.random(in: 0.005...0.011)),
                materials: [SimpleMaterial(color: theme.color.withAlphaComponent(0.65), isMetallic: false)]
            )

            let angle = Float.random(in: 0...(Float.pi * 2))
            let radius = Float.random(in: 0.75...1.15)

            particle.position = [
                center.x + cos(angle) * radius,
                center.y + sin(angle) * radius,
                center.z + Float.random(in: -0.08...0.08)
            ]

            root.addChild(particle)
        }
    }

    // MARK: - Furniture Illusion

    private func addFloatingSofa() {
        let sofaRoot = Entity()

        let base = ModelEntity(
            mesh: .generateBox(size: [0.9, 0.18, 0.32]),
            materials: [SimpleMaterial(color: UIColor.brown.withAlphaComponent(0.95), isMetallic: false)]
        )
        base.position = [0, 0.18, 0]

        let back = ModelEntity(
            mesh: .generateBox(size: [0.9, 0.38, 0.12]),
            materials: [SimpleMaterial(color: UIColor.systemBrown, isMetallic: false)]
        )
        back.position = [0, 0.38, -0.16]

        let leftArm = ModelEntity(
            mesh: .generateBox(size: [0.12, 0.28, 0.34]),
            materials: [SimpleMaterial(color: UIColor.systemBrown, isMetallic: false)]
        )
        leftArm.position = [-0.5, 0.27, 0]

        let rightArm = ModelEntity(
            mesh: .generateBox(size: [0.12, 0.28, 0.34]),
            materials: [SimpleMaterial(color: UIColor.systemBrown, isMetallic: false)]
        )
        rightArm.position = [0.5, 0.27, 0]

        sofaRoot.addChild(base)
        sofaRoot.addChild(back)
        sofaRoot.addChild(leftArm)
        sofaRoot.addChild(rightArm)

        sofaRoot.position = [-0.8, 0.75, -1.7]
        root.addChild(sofaRoot)
    }

    private func addFloatingLamp() {
        let lampRoot = Entity()

        let stand = ModelEntity(
            mesh: .generateCylinder(height: 0.65, radius: 0.02),
            materials: [SimpleMaterial(color: UIColor.darkGray, isMetallic: true)]
        )
        stand.position = [0, 0.35, 0]

        let shade = ModelEntity(
            mesh: .generateSphere(radius: 0.18),
            materials: [SimpleMaterial(color: UIColor.systemYellow.withAlphaComponent(0.82), isMetallic: false)]
        )
        shade.scale = [1.25, 0.65, 1.25]
        shade.position = [0, 0.72, 0]

        let glow = PointLight()
        glow.light.color = .systemYellow
        glow.light.intensity = 650
        glow.position = [0, 0.72, 0]

        lampRoot.addChild(stand)
        lampRoot.addChild(shade)
        lampRoot.addChild(glow)

        lampRoot.position = [0.85, 0.72, -1.55]
        root.addChild(lampRoot)
    }

    private func addGlassTable() {
        let tableTop = ModelEntity(
            mesh: .generateBox(size: [0.75, 0.05, 0.45]),
            materials: [SimpleMaterial(color: UIColor.white.withAlphaComponent(0.32), isMetallic: false)]
        )

        tableTop.position = [0, 0.78, -1.25]
        root.addChild(tableTop)

        for x in [-0.3, 0.3] as [Float] {
            for z in [-0.15, 0.15] as [Float] {
                let leg = ModelEntity(
                    mesh: .generateCylinder(height: 0.45, radius: 0.015),
                    materials: [SimpleMaterial(color: UIColor.lightGray, isMetallic: true)]
                )

                leg.position = [x, 0.52, -1.25 + z]
                root.addChild(leg)
            }
        }
    }

    private func addWindowFrame() {
        let frameColor = UIColor.white.withAlphaComponent(0.65)

        let top = ModelEntity(mesh: .generateBox(size: [0.9, 0.035, 0.035]), materials: [SimpleMaterial(color: frameColor, isMetallic: false)])
        top.position = [0, 1.9, -1.9]

        let bottom = ModelEntity(mesh: .generateBox(size: [0.9, 0.035, 0.035]), materials: [SimpleMaterial(color: frameColor, isMetallic: false)])
        bottom.position = [0, 1.25, -1.9]

        let left = ModelEntity(mesh: .generateBox(size: [0.035, 0.65, 0.035]), materials: [SimpleMaterial(color: frameColor, isMetallic: false)])
        left.position = [-0.45, 1.58, -1.9]

        let right = ModelEntity(mesh: .generateBox(size: [0.035, 0.65, 0.035]), materials: [SimpleMaterial(color: frameColor, isMetallic: false)])
        right.position = [0.45, 1.58, -1.9]

        root.addChild(top)
        root.addChild(bottom)
        root.addChild(left)
        root.addChild(right)
    }

    // MARK: - Particles

    private func addParticles(count: Int, theme: IllusionTheme) {
        for _ in 0..<count {
            let particle = ModelEntity(
                mesh: .generateSphere(radius: Float.random(in: 0.005...0.012)),
                materials: [SimpleMaterial(color: theme.color.withAlphaComponent(0.45), isMetallic: false)]
            )

            particle.position = [
                Float.random(in: -2.3...2.3),
                Float.random(in: 0.55...2.6),
                Float.random(in: -2.6 ... -0.55)
            ]

            root.addChild(particle)
        }
    }

    // MARK: - Text

    private func addTitleText(for theme: IllusionTheme) {
        let mesh = MeshResource.generateText(
            theme.rawValue,
            extrusionDepth: 0.01,
            font: .systemFont(ofSize: 0.13, weight: .bold),
            containerFrame: .zero,
            alignment: .center,
            lineBreakMode: .byWordWrapping
        )

        let text = ModelEntity(mesh: mesh, materials: [SimpleMaterial(color: UIColor.white, isMetallic: false)])
        text.position = [-0.55, 2.25, -1.55]

        root.addChild(text)
    }
}
