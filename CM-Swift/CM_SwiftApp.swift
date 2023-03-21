//
//  CM_SwiftApp.swift
//  CM-Swift
//
//  Created by David Mkhitaryan on 04/03/2023.
//

import SwiftUI

@main
struct CM_SwiftApp: App {
    let mind_game = MindViewModel()
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: mind_game)
        }
    }
}
