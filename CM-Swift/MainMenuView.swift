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
                    Image("SplashImage")
                        .resizable()
                    NavigationLink(destination: PlayerNumberView()) {
                        Image("start_game")
                            .resizable()
                            .frame(width: 160, height: 100)
                    }
                    NavigationLink(destination: HowToPlayView()) {
                        Image("how_to_play")
                            .resizable()
                            .frame(width: 160, height: 100)
                    }
                }
            }
        }
    }
}

struct MainMenuView_Previews: PreviewProvider {
    static var previews: some View {
        MainMenuView()
    }
}
