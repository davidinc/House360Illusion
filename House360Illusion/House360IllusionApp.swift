//
//  House360IllusionApp.swift
//  House360Illusion
//
//  Created by Dawit Chernet on 2026-06-29.
//

import SwiftUI

@main
struct House360IllusionApp: App {
    @StateObject private var viewModel = IllusionViewModel()
    @State private var immersionStyle: ImmersionStyle = .progressive

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
        .defaultSize(width: 1080, height: 720)

        ImmersiveSpace(id: "House360Space") {
            House360ImmersiveView()
                .environmentObject(viewModel)
        }
        .immersionStyle(selection: $immersionStyle, in: .mixed, .progressive, .full)
    }
}
