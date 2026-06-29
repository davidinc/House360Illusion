//
//  IllusionViewModel.swift
//  House360Illusion
//
//  Created by Dawit Chernet on 2026-06-29.
//


import Combine
import Foundation

@MainActor
final class IllusionViewModel: ObservableObject {
    @Published var selectedTheme: IllusionTheme = .luxury
    @Published var particleCount: Int = 24
    @Published var showFloatingFurniture: Bool = true
    @Published var showPortalRing: Bool = false
    @Published var showParticles: Bool = true

    func select(_ theme: IllusionTheme) {
        selectedTheme = theme
    }
}
