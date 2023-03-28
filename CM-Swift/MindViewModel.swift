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
    var life_counter = 3
    var player_cards: Array<Int> = []
    var cards_pile: Array<Int> = [0]
    var model1_cards: Array<Int> = []
    var model2_cards: Array<Int> = []
    var model3_cards: Array<Int> = []
    var model1: MindModel?
    var model2: MindModel?
    var model3: MindModel?
    var last_played = Date.now;
    var model_timer: Timer?
    
    init() {
        var players = (1...playerNumber).map{"Player \($0)"}
        var cards = Array(1...100).shuffled()
        
        if playerNumber >= 2 {
            player_cards = Array(cards[0...level-1]).sorted()
            model1_cards = Array(cards[level...level*2-1]).sorted()
            model1 = MindModel()
            model1!.run(playerName: players[1], cards: model1_cards)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.play_card(player: players[0])
            }
        }
        
        if playerNumber >= 3 {
            model2_cards = Array(cards[level*2...level*3-1]).sorted()
            model2 = MindModel()
            model2!.run(playerName: players[2], cards: model2_cards)
        }
        
        if playerNumber >= 4 {
            model3_cards = Array(cards[level*3...level*4-1]).sorted()
            model3 = MindModel()
            model3!.run(playerName: players[3], cards: model3_cards)
        }
    }
    
    func mismatch(x: Double, y: Double) -> Double? {
//        if !(x is Double && y is Double) {
//            return nil
//        }
        if x == y {
            return 0
        }
        let dif = abs(x - y) / -25
        
        if dif <= -1 {
            return -1
        }
        else {
            return dif
        }
    }
    
    func play_card(player: String) {
        let prev_card = cards_pile.last
        var played_card: Int = 0
        var prev = self.last_played
        var current = Date.now
        self.last_played = current
        var delta = prev.distance(to: current)
        print(delta)
        var lower_cards1: Array<Int> = []
        var lower_cards2: Array<Int> = []
        var lower_cards3: Array<Int> = []
        var lower_cards4: Array<Int> = []
        
        switch(player){
        case "Player 1":
            if model_timer != nil {
                model_timer!.invalidate()
            }
            played_card = player_cards.removeFirst()
            cards_pile.append(played_card)
        case "Player 2":
            played_card = model1_cards.removeFirst()
            cards_pile.append(played_card)
            model1!.play_card()
            //let _ = print(cards_pile[200])
        case "Player 3":
            played_card = model2_cards.removeFirst()
            cards_pile.append(played_card)
            model2!.play_card()
        case "Player 4":
            played_card = model3_cards.removeFirst()
            cards_pile.append(played_card)
            model3!.play_card()
        default: let _ = print("Error!")
        }
        
        
        let current_card = played_card
        let delta_card = Double(abs(current_card - prev_card!))
        
//        var model_timers: Array<Double> = []
        
        
        // Initialize some variables used to keep track of timing
        var m1_timing = 0.0
        var m2_timing = 0.0
        var m3_timing = 0.0
        var fastest_timing: Double = 0
        var fastest_model = "Player 2"
        
        // TODO: Implement partial blended retrieval!!
        if playerNumber >= 2 {
            // Do for model 1
            let (latency, request) = model1!.add_request_memory(delta: delta, delta_card: delta_card)
            m1_timing = 8.0
            fastest_timing = m1_timing
            lower_cards1 = player_cards.enumerated().compactMap {$1 < played_card ? $0 : nil}
            lower_cards2 = model1_cards.enumerated().compactMap {$1 < played_card ? $0 : nil}
        }
        
        if playerNumber >= 3 {
            // Do for model 2
            let (latency, result) = model2!.add_request_memory(delta: delta, delta_card: delta_card)
            m2_timing = 10.0
            if m2_timing < m1_timing {
                fastest_model = "Player 3"
                fastest_timing = m2_timing
            }
            lower_cards3 = model2_cards.enumerated().compactMap {$1 < played_card ? $0 : nil}
        }
        if playerNumber >= 4 {
            let (latency, result) = model3!.add_request_memory(delta: delta, delta_card: delta_card)
            m3_timing = 9.0
            if m3_timing < m1_timing && m3_timing < m2_timing{
                fastest_model = "Player 4"
                fastest_timing = m3_timing
            }
            lower_cards4 = model3_cards.enumerated().compactMap {$1 < played_card ? $0 : nil}
        }

        if !(lower_cards1.isEmpty && lower_cards2.isEmpty && lower_cards3.isEmpty && lower_cards4.isEmpty) {
            if (life_counter > 0) {
                if playerNumber >= 2 {
                    player_cards = player_cards.filter{lower_cards1.contains($0)}
                    model1_cards = model1_cards.filter{lower_cards2.contains($0)}
                }
                if playerNumber >= 3 {
                    model2_cards = model2_cards.filter{lower_cards3.contains($0)}
                }
                if playerNumber >= 4 {
                    model3_cards = model3_cards.filter{lower_cards4.contains($0)}
                }
                life_counter -= 1
            }
            else {
                // say game over.
                
            
            }
        }
        // if all hands empty -> advance next level, else the timer block.
        if (player_cards.isEmpty && model1_cards.isEmpty && model2_cards.isEmpty && model3_cards.isEmpty) {
            // newLevel()
            level += 1
            let players = (1...playerNumber).map{"Player \($0)"}
            var cards = Array(1...100).shuffled()
            player_cards = Array(cards[0...level-1]).sorted()
            model1_cards = Array(cards[level...level*2-1]).sorted()
            model2_cards = Array(cards[level*2...level*3-1]).sorted()
            model3_cards = Array(cards[level*3...level*4-1]).sorted()
        }
        else {
            let shortest_timer = 10.0
            model_timer = Timer.scheduledTimer(withTimeInterval: fastest_timing, repeats: false) {_ in
                print("check!")
                self.play_card(player: fastest_model)
            }
        }
        
        
    }
    
}
