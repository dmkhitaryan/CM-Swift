//
//  ContentView.swift
//  CM-Swift
//
//  Created by David Mkhitaryan on 01/03/2023.
//

import SwiftUI

struct CardView: View {
    var body: some View {
        // your card view code here
        Rectangle()
            .frame(width:80, height:85)
            .background(.white)
            .cornerRadius(10)
            .border(.red, width: 4)
    }
}

struct LifeView: View {
    var body: some View {
        Text("❤️")
    }
}
struct Player {
    let name: String
    let cards: [CardView]
}

struct PileView: View {
    var body: some View {
        Rectangle()
            .frame(width: 100, height: 90)
            .foregroundColor(.blue)
    }
}

struct PlayerHandView: View {
    var body: some View {
        Text("hello!")
            .font(.largeTitle)
            .padding()
            .background(.white)
            .cornerRadius(20)
            .border(.red, width: 4)
    }
}
struct ContentView: View {
    var viewModel: MindViewModel
    let players = [
                           Player(name: "Player 2", cards: [CardView(), CardView()]),
                           Player(name: "Player 3", cards: [CardView(), CardView(), CardView(), CardView(),CardView(), CardView(), CardView(), CardView()]),
                           Player(name: "Player 4", cards: [CardView(), CardView()])
    ]
    let lives = [LifeView(), LifeView(), LifeView()]
    
    var body: some View {
        VStack {
            HStack{
                ForEach(players.indices, id: \.self) { index in
                    let player = players[index]
                    VStack{
                        Text(player.name)
                        ZStack {
                            ForEach(player.cards.indices, id: \.self) { idx in
                                let card = player.cards[idx]
                                card.offset(y: CGFloat(7*idx))
                            }
                            
                        }
                    }
                }
            }
            Spacer()
            PileView()
            Spacer()
            HStack{
                PlayerHandView()
                    .padding(.leading, 55)
                    .onTapGesture {
                        print("Hello!")
                    }
                LifeView()
                    .padding()
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let mind_game = MindViewModel()
        ContentView(viewModel: mind_game)
    }
}


