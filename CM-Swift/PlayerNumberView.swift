//
//  PlayerNumberView.swift
//  CM-Swift
//
//  Created by David Mkhitaryan on 11/04/2023.
//

import SwiftUI

struct PlayerNumberView: View {
    var body: some View {
        ZStack {
            Background()
            VStack {
                Image("choose_no")
                    .resizable()
                    .padding()
                    .frame(width: 450, height: 100)
                NavigationLink(destination: LazyView(ContentView(nPlayers: 2))) {
                    Image("2players")
                        .resizable()
                        .frame(width: 160, height: 100)
                }
                NavigationLink(destination: LazyView(ContentView(nPlayers: 3))) {
                    Image("3players")
                        .resizable()
                        .frame(width: 160, height: 100)
                }
                NavigationLink(destination: LazyView(ContentView(nPlayers: 4))) {
                    Image("4players")
                        .resizable()
                        .frame(width: 160, height: 100)
                }
            }
        }
    }
}


struct LazyView<Content: View>: View {
    var content: () -> Content
    
    init(_ content: @autoclosure @escaping () -> Content) {
        self.content = content
    }
    
    var body: Content {
        content()
    }
}

struct PlayerNumberView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerNumberView()
    }
}
