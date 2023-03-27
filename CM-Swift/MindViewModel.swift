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
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.play_card(player: players[0])
            }
            
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
            // TODO: add a check to see if no one had a lower card than one played.
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
        let memory_id = Int.random(in: 1..<100000)
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
            let memory = Chunk(s: "memory\(memory_id)", m: model1!.model)
            memory.setSlot(slot: "isa", value: "card-memory")
            memory.setSlot(slot: "difference", value: delta_card)
            memory.setSlot(slot: "timing", value: delta)
            model1!.model.dm.addToDM(memory)
            
            // Retrieve timing for m1
            let retrieval = Chunk(s: "retrieval", m: model1!.model)
            retrieval.setSlot(slot: "isa", value: "card-memory")
            retrieval.setSlot(slot: "difference", value: delta_card)
            let (latency, result) = model1!.model.dm.blendedRetrieve(chunk: retrieval)
            
            m1_timing = 8.0
            fastest_timing = m1_timing
        }
        
        if playerNumber >= 3 {
            // Do for model 2
            let memory = Chunk(s: "memory\(memory_id)", m: model2!.model)
            memory.setSlot(slot: "isa", value: "card-memory")
            memory.setSlot(slot: "difference", value: delta_card)
            memory.setSlot(slot: "timing", value: delta)
            model2!.model.dm.addToDM(memory)
            
            // Retrieve timing for m2
            let retrieval = Chunk(s: "retrieval", m: model2!.model)
            retrieval.setSlot(slot: "isa", value: "card-memory")
            retrieval.setSlot(slot: "difference", value: delta_card)
            let (latency, result) = model2!.model.dm.blendedRetrieve(chunk: retrieval)
            
            m2_timing = 10.0
            if m2_timing < m1_timing {
                fastest_model = "Player 3"
                fastest_timing = m2_timing
            }
        }
        if playerNumber >= 4 {
            // Do for model 3
            let memory = Chunk(s: "memory\(memory_id)", m: model3!.model)
            memory.setSlot(slot: "isa", value: "card-memory")
            memory.setSlot(slot: "difference", value: delta_card)
            memory.setSlot(slot: "timing", value: delta)
            model3!.model.dm.addToDM(memory)
            
            // Retrieve timing for m3
            let retrieval = Chunk(s: "retrieval", m: model3!.model)
            retrieval.setSlot(slot: "isa", value: "card-memory")
            retrieval.setSlot(slot: "difference", value: delta_card)
            let (latency, result) = model3!.model.dm.blendedRetrieve(chunk: retrieval)
            
            m3_timing = 9.0
            if m3_timing < m1_timing && m3_timing < m2_timing{
                fastest_model = "Player 4"
                fastest_timing = m3_timing
            }
        }
        
        // TODO: check if no one has any cards left; start next level if true.
        // TODO: add a function that "advances" to the next level.
        
        let shortest_timer = 10.0
        model_timer = Timer.scheduledTimer(withTimeInterval: fastest_timing, repeats: false) {_ in
            print("check!")
            self.play_card(player: fastest_model)
        }
        
        
    }
    
}
