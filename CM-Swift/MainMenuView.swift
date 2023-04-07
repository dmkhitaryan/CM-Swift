//
//  SplashView.swift
//  CM-Swift
//
//  Created by David Mkhitaryan on 07/04/2023.
//

import SwiftUI

struct MainMenuView: View {
    @State var startGame: Bool = false

    var body: some View {
        NavigationView {
            ZStack {
                Background()
                VStack {
                    if !startGame {
                        Button("Start the Game!") {
                            startGame.toggle()
                        }
                    } else {
                        let mind_game = MindViewModel()
                        NavigationLink(destination: ContentView(viewModel: mind_game)) {
                            Text("Start the game")
                        }
                        .isDetailLink(false)
                        .navigationBarBackButtonHidden(true)
                    }
                }
                .navigationBarTitle(Text("Main Menu"))
            }
        }
    }
}

struct MainMenuView_Previews: PreviewProvider {
    static var previews: some View {
        MainMenuView()
    }
}
