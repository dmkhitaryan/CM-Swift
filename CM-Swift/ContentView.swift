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
        Text("This is a card")
            .padding()
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


struct ContentView: View {
    let players = [        Player(name: "Player 1", cards: [CardView(), CardView(), CardView()]),
                           Player(name: "Player 2", cards: [CardView(), CardView()]),
                           Player(name: "Player 3", cards: [CardView(), CardView(), CardView(), CardView(),CardView(), CardView(), CardView(), CardView()]),
                           Player(name: "Player 4", cards: [CardView(), CardView()])
    ]
    let lives = [LifeView(), LifeView(), LifeView()]
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                ForEach(lives.indices, id: \.self) { life_index in
                    let life = lives[life_index]
                    if(life_index == lives.indices.last) {
                        life.padding([.trailing], 10)
                    }
                    else {
                        life
                    }
                }
            }.padding([.vertical], 15)
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
            CardView()
            Spacer()
            CardView()
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


