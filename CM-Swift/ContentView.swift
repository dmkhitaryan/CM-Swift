//
//  ContentView.swift
//  CM-Swift
//
//  Created by David Mkhitaryan on 01/03/2023.
//

import SwiftUI

struct CardBack: View {
    let width_size: CGFloat
    let height_size: CGFloat
    var body: some View {
        Image("Cardback")
             .resizable()
             .frame(width: width_size, height: height_size)
             .cornerRadius(10)
             .overlay(RoundedRectangle(cornerRadius: 10)
             .stroke(Color.orange, lineWidth: 1))
     }
}

struct CardView: View {
    let value: Int
    var isOwn: Bool
    let width_size: CGFloat
    let height_size: CGFloat
    var body: some View {
        if isOwn == true  {
           Image("\(value)")
                .resizable()
                .frame(width:width_size, height: height_size)
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10)
                .stroke(Color.orange, lineWidth: 1))
        }
        else {
           CardBack(width_size: 80, height_size: 130)
        }
    }
}

struct FakeCardView: View {
    var body: some View {
        CardBack(width_size: 80, height_size: 130)
        .opacity(0.0001)
    }
}

struct LifeView: View {
    var number_of_lives: Int
    var body: some View {
        ZStack {
            Image("Heart")
                .resizable()
                .frame(width: 60, height: 120)
            Text("\(number_of_lives)")
                .foregroundColor(.white)
        }
    }
}

struct LevelView: View {
    var level_number: Int
    var body: some View {
        Text("Level \(level_number)")
            .foregroundColor(.white)
    }
}
struct Player: View {
    let name: String
    let cards: Array<Int>
    var body: some View {
        VStack {
            Text(name)
                .foregroundColor(.white)
            ZStack {
                FakeCardView()
                ForEach(cards.indices, id: \.self) { idx in
                    let card = CardView(value: cards[idx], isOwn: false, width_size: 80, height_size: 130)
                    card.offset(y: CGFloat(7*idx)).animation(/*@START_MENU_TOKEN@*/.easeOut/*@END_MENU_TOKEN@*/, value: 2)
                }
                
                
            }
        }
    }
}

struct PlayersView: View {
    var number_of_players: Int
    @ObservedObject var viewModel: MindViewModel
    
    var body: some View {
        HStack {
            if number_of_players >= 2 {
                Player(name: "Model 1", cards: viewModel.model1_cards)
            }
            
            if number_of_players >= 3 {
                Player(name: "Model 2", cards: viewModel.model2_cards)
            }
            
            if number_of_players >= 4 {
                Player(name: "Model 3", cards: viewModel.model3_cards)
            }
        }
    }
}
struct PileView: View {
    var cards: Array<Int>
    var body: some View {
        ZStack {
            if (cards.isEmpty || cards.last! == 0) {
                FakeCardView()
                    .frame(width: 90, height: 150)
            }
            else {
                CardView(value: cards.last!, isOwn: true, width_size: 90, height_size: 150)
                    .frame(width: 90, height: 150)
            }
        }
    }
}

struct PlayerHandView: View {
    var cards: Array<Int>
    var body: some View {
        if (cards.isEmpty) {
            FakeCardView()
        }
        else {
            ZStack {
                ForEach(cards.indices.reversed(), id: \.self) { idx in
                    let card = CardView(value: cards[idx], isOwn: true, width_size: 80, height_size: 130)
                    card.offset(y: CGFloat(7*idx))
                }
            }
        }
    }
}

struct ContentView: View {
    @ObservedObject var viewModel: MindViewModel
    
    init(nPlayers: Int) {
        let soundPlayer = SoundPlayer()
        viewModel = MindViewModel(soundPlayer: soundPlayer, n_players: nPlayers)
    }
    
    var body: some View {
        if(!viewModel.isGameComplete || !viewModel.isGameOver) {
            ZStack {
                Background()
                VStack {
                    PlayersView(number_of_players: viewModel.number_of_players, viewModel: viewModel)
                    Spacer()
                    PileView(cards: viewModel.cards_pile)
                    Spacer()
                    HStack{
                        PlayerHandView(cards: viewModel.player_cards)
                            .padding(.leading, 55)
                            .onTapGesture {
                                withAnimation {
                                    if !(viewModel.player_cards.isEmpty && (!viewModel.isGameOver || !viewModel.isGameComplete)) {
                                        viewModel.play_card(player: "Player 1")
                                    }
                                }
                            }
                        LifeView(number_of_lives: viewModel.life_counter)
                            .padding()
                        LevelView(level_number: viewModel.level)
                    }
                    
                }
            }
        }
        else {
            if(viewModel.isGameOver) {
                GameOverView()
            }
            if(viewModel.isGameComplete) {
                GameCompleteView()
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(nPlayers: 4)
    }
}

// TODO: add a view for main screen and transitions to game view.
// TODO: replacing skeleton icons with the proper ones, adjust spaces if necessary.
// TODO: add functionality to the buttons, e.g., player tapping on their icons triggers their move.
// TODO: add animations.
