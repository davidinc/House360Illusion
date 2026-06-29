//
//  IllusionTheme.swift
//  House360Illusion
//
//  Created by Dawit Chernet on 2026-06-29.
//

import SwiftUI
import UIKit

enum IllusionTheme: String, CaseIterable, Identifiable {
    case luxury = "Luxury"
    case blueWater = "Blue Water"
    case spaceApartment = "Space Apartment"
    case forestCabin = "Forest Cabin"
    case timeTravelRoom = "Time Travel Room"
    case skyPalace = "Sky Palace"

    var id: String { rawValue }

    var assetName: String {
        switch self {
        case .luxury:
            return "Luxury"
        case .blueWater:
            return "BlueWater"
        case .spaceApartment:
            return "SpaceApartment"
        case .forestCabin:
            return "ForestCabin"
        case .timeTravelRoom:
            return "TimeTravelRoom"
        case .skyPalace:
            return "SkyPalace"
        }
    }

    var color: UIColor {
        switch self {
        case .luxury:
            return .systemOrange
        case .blueWater:
            return .systemCyan
        case .spaceApartment:
            return .systemPurple
        case .forestCabin:
            return .systemGreen
        case .timeTravelRoom:
            return .systemIndigo
        case .skyPalace:
            return .systemBlue
        }
    }

    var swiftUIColor: Color {
        switch self {
        case .luxury:
            return .orange
        case .blueWater:
            return .cyan
        case .spaceApartment:
            return .purple
        case .forestCabin:
            return .green
        case .timeTravelRoom:
            return .indigo
        case .skyPalace:
            return .blue
        }
    }

    var symbol: String {
        switch self {
        case .luxury:
            return "house.fill"
        case .blueWater:
            return "water.waves"
        case .spaceApartment:
            return "sparkles"
        case .forestCabin:
            return "tree.fill"
        case .timeTravelRoom:
            return "clock.arrow.circlepath"
        case .skyPalace:
            return "cloud.sun.fill"
        }
    }
}