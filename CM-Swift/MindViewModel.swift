//
//  ViewModel.swift
//  CM-Swift
//
//  Created by David Mkhitaryan on 04/03/2023.
//

import Foundation

class MindViewModel: ObservableObject {
    var playerNumber: Int = 2
    var level: Int = 3
    var player_cards: Array<Int>
    var cards_pile: Array<Int> = []
    var model1_cards: Array<Int> = []
    var model2_cards: Array<Int> = []
    var model3_cards: Array<Int> = []
    var model1: MindModel?
    var model2: MindModel?
    var model3: MindModel?
    
    init() {
        // TODO: how to set up card generation logic?
        // TODO: add functions that 'update' models.
        let players = (1...playerNumber).map{"Player \($0)"}
        var cards = Array(1...100).shuffled()
        player_cards = Array(cards[0...level-1]).sorted()
        model1_cards = Array(cards[level...level*2-1]).sorted()
        model2_cards = Array(cards[level*2...level*3-1]).sorted()
        model3_cards = Array(cards[level*3...level*4-1]).sorted()

        switch (playerNumber) {
        case 2:
            model1 = MindModel()
            model1!.run(playerName: players[1], cards: model1_cards)
            play_card(player: players[0])
        case 3:
            model1 = MindModel()
            model2 = MindModel()
            model1!.run(playerName: players[1], cards: model1_cards)
            model2!.run(playerName: players[2], cards: model2_cards)
            
        case 4:
            model1 = MindModel()
            model2 = MindModel()
            model3 = MindModel()
            model1!.run(playerName: players[1], cards: model1_cards)
            model2!.run(playerName: players[2], cards: model2_cards)
            model3!.run(playerName: players[3], cards: model3_cards)
        default:
            model1! = MindModel()
            model1!.run(playerName: players[1], cards: model1_cards)
        }
        
    }
    
    func play_card(player: String) {
        // TODO: get current and last played timers.
        
        switch(player){
        case "Player 1":
            // TODO: cancel the timer if player plays the card.
            let played_card = player_cards.removeFirst()
            cards_pile.append(played_card)
           // let _ = print(cards_pile[200])
        case "Player 2":
            let played_card = model1_cards.removeFirst()
            cards_pile.append(played_card)
            model1!.play_card()
            // TODO: add a check to see if no one had a lower card than one played.
            // TODO: get the difference between current and last played cards.
        case "Player 3":
            let played_card = model2_cards.removeFirst()
            cards_pile.append(played_card)
            model2!.play_card()
        case "Player 4":
            let played_card = model3_cards.removeFirst()
            cards_pile.append(played_card)
            model3!.play_card()
        default: let _ = print("Error!")
        }
        
    }
    
    // TODO: update the DM of models by adding the new event.
    
    // TODO: check if no one has any cards left; start next level if true.
    
    // TODO: do partial blended retrieval for all models that stil have cards.
    // TODO: out of all timers, pick the shortest one, create a thread for it.
    
    
}
