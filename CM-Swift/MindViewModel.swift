//
//  ViewModel.swift
//  CM-Swift
//
//  Created by David Mkhitaryan on 04/03/2023.
//

import Foundation

class MindViewModel: ObservableObject {
    var number_of_players: Int = 3
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
    var previous_time = Date.now;
    var model_timer: Timer?
    
    init() {
        var players = (1...number_of_players).map{"Player \($0)"}
        var cards = Array(1...100).shuffled()
        
        if number_of_players >= 2 {
            player_cards = Array(cards[0...level-1]).sorted()
            model1_cards = Array(cards[level...level*2-1]).sorted()
            model1 = MindModel()
            model1!.run(playerName: players[1], cards: model1_cards)
        }
        
        if number_of_players >= 3 {
            model2_cards = Array(cards[level*2...level*3-1]).sorted()
            model2 = MindModel()
            model2!.run(playerName: players[2], cards: model2_cards)
        }
        
        if number_of_players >= 4 {
            model3_cards = Array(cards[level*3...level*4-1]).sorted()
            model3 = MindModel()
            model3!.run(playerName: players[3], cards: model3_cards)
        }
    }
    
    func play_card(player: String) {
        let prev_card = cards_pile.last
        var played_card: Int = 0
        var current_time = Date.now
        var delta_timer = self.previous_time.distance(to: current_time)
        print("delta_timer is \(delta_timer)")
        self.previous_time = current_time
        
        model1!.model.time += delta_timer
        if number_of_players >= 3 {
            model2!.model.time += delta_timer
        }
        if number_of_players >= 4 {
            model3!.model.time += delta_timer
        }
        
        
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
        
        print("\(player) has just played their card!")
        print("The played card is \(played_card)")
        print("The last card in the pile is \(prev_card ?? 999)")
        print("Player 1 has these cards: \(player_cards)")
        print("Player 2 has these cards: \(model1!.card_arr)")
        print("Player 3 has these cards: \(model2!.card_arr)")
        
        
        let current_card = played_card
        let delta_card = Double(abs(current_card - prev_card!))
        
//        var model_timers: Array<Double> = []
        
        
        // Initialize some variables used to keep track of timing
        var m1_timing = 0.0
        var m2_timing = 0.0
        var m3_timing = 0.0
        var fastest_timing: Double = inf
        var fastest_model = "Player 2"
        
        // TODO: Implement partial blended retrieval!!
        if number_of_players >= 2 {
            // Do for model 1
            let (latency1, result1) = model1!.add_request_memory(delta_timer: delta_timer, delta_card: delta_card)
            
            if (result1 != nil) {
               // print("Good! Latency is \(latency1), chunk is \(result1)")
                print("The blended time is \(Double(result1!.slotvals["timing"]!.number() ?? 99))")
                m1_timing = Double(result1!.slotvals["timing"]!.number() ?? Double.random(in: 0..<0.25)*delta_card)
            }
            else {
//                print("Chunk retrieved was nil!")
//                print("Latency is \(latency1)")
                m1_timing = Double.random(in: 0..<0.25)*delta_card
            }
            
            if !(model1_cards.isEmpty) {
                fastest_timing  = m1_timing + latency1
            }
            print("The timer for model 1 is \(fastest_timing)")
            lower_cards1 = player_cards.enumerated().compactMap {$1 < played_card ? $1 : nil}
            lower_cards2 = model1_cards.enumerated().compactMap {$1 < played_card ? $1 : nil}
        }
        
        if number_of_players >= 3 {
            // Do for model 2
            let (latency2, result2) = model2!.add_request_memory(delta_timer: delta_timer, delta_card: delta_card)
            
            if (result2 != nil) {
                m2_timing = Double(result2!.slotvals["timing"]!.number() ?? Double.random(in: 0..<0.25)*delta_card)
            }
            else {
                m2_timing = Double.random(in: 0..<0.25)*delta_card
            }
            
            if m2_timing + latency2 < fastest_timing && !(model3_cards.isEmpty) {
                fastest_model = "Player 3"
                fastest_timing = m2_timing + latency2
            }
            lower_cards3 = model2_cards.enumerated().compactMap {$1 < played_card ? $1 : nil}
        }
        if number_of_players >= 4 {
            let (latency3, result3) = model3!.add_request_memory(delta_timer: delta_timer, delta_card: delta_card)
            
            if (result3 != nil) {
                m3_timing = Double(result3!.slotvals["timing"]!.number() ?? Double.random(in: 0..<0.25)*delta_card)
            }
            else {
                m3_timing = Double.random(in: 0..<0.25)*delta_card
            }
            
            if m3_timing + latency3 < fastest_timing && !(model3_cards.isEmpty) {
                fastest_model = "Player 4"
                fastest_timing = m3_timing + latency3
            }
            lower_cards4 = model3_cards.enumerated().compactMap {$1 < played_card ? $1 : nil}
        }

        if !(lower_cards1.isEmpty && lower_cards2.isEmpty && lower_cards3.isEmpty && lower_cards4.isEmpty) {
            // TODO: filtering returns indices of wrong elements, not the wrong elements themselves.
            // TODO: running .filter() removes EVERYTHING from both models.
            print("Someone played the wrong card!")
            if (life_counter > 0) {
                if number_of_players >= 2 {
                    print("Show the wrong cards for Player 1: \(lower_cards1)")
                    print("Show the wrong cards for Player 2: \(lower_cards2)")
                    print("Show the wrong cards for Player 3: \(lower_cards3)")
                    
                    print("Player 1 cards before filtering: \(player_cards)")
                    print("Player 2 cards before filtering: \(model1_cards)")
                    print("Player 2 cards before filtering: \(model2_cards)")
                    player_cards = player_cards.filter{!lower_cards1.contains($0)}
                    model1_cards = model1_cards.filter{!lower_cards2.contains($0)}
                    model1!.filter_hand(cards_to_filter: lower_cards2)
                    
                    print("Player 1 cards after filtering: \(player_cards)")
                    print("Player 2 cards after filtering: \(model1_cards)")
                    print("Player 3 cards after filtering: \(model2_cards)")
                    
                }
                if number_of_players >= 3 {
                    model2_cards = model2_cards.filter{!lower_cards3.contains($0)}
                    model2!.filter_hand(cards_to_filter: lower_cards3)
                }
                if number_of_players >= 4 {
                    model3_cards = model3_cards.filter{!lower_cards4.contains($0)}
                    model3!.filter_hand(cards_to_filter: lower_cards4)
                }
                life_counter -= 1
            }
            else {
                // say game over.
                // TODO: define what is 'Game Over'.
                print("Game over, you ran out lives!")
            }
        }
        // if all hands empty -> advance next level, else the timer block.
        if (player_cards.isEmpty && model1_cards.isEmpty && model2_cards.isEmpty && model3_cards.isEmpty) {
            print("Everyone emptied their hands, on to next level!")
            // newLevel()
            level += 1
            let players = (1...number_of_players).map{"Player \($0)"}
            var cards = Array(1...100).shuffled()
            player_cards = Array(cards[0...level-1]).sorted()
            model1_cards = Array(cards[level...level*2-1]).sorted()
            model1!.deal_hand(cards: cards, level: level, playerN: 1)
            
            if number_of_players >= 3 {
                model2_cards = Array(cards[level*2...level*3-1]).sorted()
                model2!.deal_hand(cards: cards, level: level, playerN: 2)
            }
            if number_of_players >= 4 {
                model3_cards = Array(cards[level*3...level*4-1]).sorted()
                model3!.deal_hand(cards: cards, level: level, playerN: 3)
            }
            
        }
        else if (!model1_cards.isEmpty || !model2_cards.isEmpty || !model3_cards.isEmpty) {
            print("The time to wait is \(fastest_timing) seconds!")
            model_timer = Timer.scheduledTimer(withTimeInterval: fastest_timing, repeats: false) {_ in
                self.play_card(player: fastest_model)
            }
        }
        
        
    }
    
}
