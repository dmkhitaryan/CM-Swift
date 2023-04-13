//
//  ViewModel.swift
//  CM-Swift
//
//  Created by David Mkhitaryan on 04/03/2023.
//

import Foundation
import AVFoundation
import Combine

class SoundPlayer: ObservableObject {
    
    var audioPlayer: AVAudioPlayer?
    var cancellables = Set<AnyCancellable>()
    
    func playSound(sounds: Array<String>) {
        guard let sound = sounds.randomElement(),
              let soundUrl = Bundle.main.url(forResource: sound, withExtension: "wav") else {
            print("Error: Sound file not found")
            return
        }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundUrl)
            audioPlayer?.play()
        } catch {
            print("Error playing sound: \(error.localizedDescription)")
        }
    }
}


class MindViewModel: ObservableObject {
    var number_of_players: Int
    @Published var isGameOver: Bool = false
    @Published var isGameComplete: Bool = false
    @Published var level: Int = 1
    @Published var life_counter: Int
    @Published var player_cards: Array<Int> = []
    @Published var cards_pile: Array<Int> = [0]
    @Published var model1_cards: Array<Int> = []
    @Published var model2_cards: Array<Int> = []
    @Published var model3_cards: Array<Int> = []
    private let soundPlayer: SoundPlayer
    var model1: MindModel?
    var model2: MindModel?
    var model3: MindModel?
    var previous_time = Date.now;
    var model_timer: Timer?
    let card_sounds: Array<String> = ["card_played", "card_played2"]
    let wrong_answers: Array<String> = ["wrong2"]
    
    @Published var err1 = 0
    @Published var err2 = 0
    @Published var err3 = 0
    @Published var err4 = 0
    
    init(soundPlayer: SoundPlayer, n_players: Int) {
        number_of_players = n_players
        life_counter = 1 + 2 * number_of_players
        self.soundPlayer = soundPlayer
        var players = (1...number_of_players).map{"Player \($0)"}
        let cards = Array(1...100).shuffled()
        var init_delta_card: Double = 0.0
        
        if number_of_players >= 2 {
            self.player_cards = Array(cards[0...level-1]).sorted()
            self.model1_cards = Array(cards[level...level*2-1]).sorted()
            self.model1 = MindModel()
            self.model1!.run(playerName: players[1], cards: model1_cards)
            
            init_delta_card = Double(abs(0-model1_cards.first!))
        }
        
        if number_of_players >= 3 {
            self.model2_cards = Array(cards[level*2...level*3-1]).sorted()
            self.model2 = MindModel()
            self.model2!.run(playerName: players[2], cards: model2_cards)
            
            init_delta_card = Double(abs(0-model2_cards.first!))
        }
        
        if number_of_players >= 4 {
            self.model3_cards = Array(cards[level*3...level*4-1]).sorted()
            self.model3 = MindModel()
            self.model3!.run(playerName: players[3], cards: model3_cards)
            
            init_delta_card = Double(abs(0-model3_cards.first!))
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [self] in
            // Put your code which should be executed with a delay here
            let (init_fastest_model, init_fastest_timing) = memory_game_logic(number_of_players: number_of_players, delta_card: init_delta_card, delta_timer: 0, first_memory: true)
            self.model_timer = Timer.scheduledTimer(withTimeInterval: init_fastest_timing, repeats: false) { [weak self] timer in
                guard let strongSelf = self else {
                    return
                }
                
                strongSelf.play_card(player: init_fastest_model)
            }

        }
        
    }
    
    func play_card(player: String) {
        if life_counter == 0 {
            exit(0)
        }
        let prev_card = cards_pile.last
        var played_card: Int = 0
        let current_time = Date.now
        let delta_timer = self.previous_time.distance(to: current_time)
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
            model_timer?.invalidate()
            model_timer = nil
            played_card = player_cards.removeFirst()
            cards_pile.append(played_card)
            soundPlayer.playSound(sounds: card_sounds)
        case "Player 2":
            played_card = model1_cards.removeFirst()
            cards_pile.append(played_card)
            soundPlayer.playSound(sounds: card_sounds)
            model1!.play_card()
            //let _ = print(cards_pile[200])
        case "Player 3":
            played_card = model2_cards.removeFirst()
            cards_pile.append(played_card)
            soundPlayer.playSound(sounds: card_sounds)
            model2!.play_card()
        case "Player 4":
            played_card = model3_cards.removeFirst()
            cards_pile.append(played_card)
            soundPlayer.playSound(sounds: card_sounds)
            model3!.play_card()
        default: let _ = print("Error!")
        }
        
        print("\(player) has just played their card!")
        print("The played card is \(played_card)")
        print("The last card in the pile is \(prev_card ?? 999)")
        print("Player 1 has these cards: \(player_cards)")
        print("Player 2 has these cards: \(model1!.card_arr ?? [646])")
        
        
        let current_card = played_card
        let delta_card = Double(abs(current_card - prev_card!))
        
        if number_of_players >= 2 {
            lower_cards1 = player_cards.enumerated().compactMap {$1 < played_card ? $1 : nil}
            lower_cards2 = model1_cards.enumerated().compactMap {$1 < played_card ? $1 : nil}
        }
        if number_of_players >= 3 {
            lower_cards3 = model2_cards.enumerated().compactMap {$1 < played_card ? $1 : nil}
        }
        if number_of_players >= 4 {
            lower_cards4 = model3_cards.enumerated().compactMap {$1 < played_card ? $1 : nil}
        }
        
        if !(lower_cards1.isEmpty && lower_cards2.isEmpty && lower_cards3.isEmpty && lower_cards4.isEmpty) {
            soundPlayer.playSound(sounds: wrong_answers)
            sleep(1)
            // TODO: filtering returns indices of wrong elements, not the wrong elements themselves.
            // TODO: running .filter() removes EVERYTHING from both models.
            print("Someone played the wrong card!")
            if (life_counter > 0) {
                life_counter -= 1
                if number_of_players >= 2 {
                    print("Show the wrong cards for Player 1: \(lower_cards1)")
                    print("Show the wrong cards for Player 2: \(lower_cards2)")
                    
                    
                    print("Player 1 cards before filtering: \(player_cards)")
                    print("Player 2 cards before filtering: \(model1_cards)")
                    player_cards = player_cards.filter{!lower_cards1.contains($0)}
                    model1_cards = model1_cards.filter{!lower_cards2.contains($0)}
                    model1!.filter_hand(cards_to_filter: lower_cards2)
                    
                    
                    print("Player 1 cards after filtering: \(player_cards)")
                    print("Player 2 cards after filtering: \(model1_cards)")
                    
                }
                if number_of_players >= 3 {
                    print("Show the wrong cards for Player 3: \(lower_cards3)")
                    print("Player 3 cards before filtering: \(model2_cards)")
                    model2_cards = model2_cards.filter{!lower_cards3.contains($0)}
                    model2!.filter_hand(cards_to_filter: lower_cards3)
                    print("Player 3 cards after filtering: \(model2_cards)")
                }
                if number_of_players >= 4 {
                    model3_cards = model3_cards.filter{!lower_cards4.contains($0)}
                    model3!.filter_hand(cards_to_filter: lower_cards4)
                }
            }
            
            else {
                // say game over.
                // TODO: define what is 'Game Over'.
                print("Game over, you ran out lives!")
                isGameOver = true
                print("GG")
                if model_timer != nil {
                    model_timer?.invalidate()
                    model_timer = nil
                    exit(0)
                }
            }
        }
        // Initialize some variables used to keep track of timing
        
        // TODO: Implement partial blended retrieval!!
        var (fastest_model, fastest_timing) = memory_game_logic(number_of_players: number_of_players, delta_card: delta_card, delta_timer: delta_timer, first_memory: false)
        
        // if all hands empty -> advance next level, else the timer block.
        if (player_cards.isEmpty && model1_cards.isEmpty && model2_cards.isEmpty && model3_cards.isEmpty) {
            print("Everyone emptied their hands, on to next level!")
            // newLevel()
            if (level < 16 - number_of_players*2) {
                if(level % 2 == 0) {
                    life_counter += 1
                }
                level += 1
                cards_pile = [0]
                let cards = Array(1...100).shuffled()
                
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
                
                (fastest_model, fastest_timing) = memory_game_logic(number_of_players: number_of_players, delta_card: delta_card, delta_timer: delta_timer, first_memory: true)
                print("New round, first move. The time to wait is \(fastest_timing) seconds!")
                print("This will be done by the \(fastest_model)")
                self.model_timer = Timer.scheduledTimer(withTimeInterval: fastest_timing, repeats: false) { [weak self] timer in
                    guard let strongSelf = self else {
                        return
                    }
                    
                    strongSelf.play_card(player: fastest_model)
                }

            }
            else {
                print("You finished the game!")
                isGameComplete = true
                if model_timer != nil {
                    model_timer?.invalidate()
                    model_timer = nil
                    exit(0)
                }
            }
        }
        else if (!model1_cards.isEmpty || !model2_cards.isEmpty || !model3_cards.isEmpty) {
            print("The time to wait is \(fastest_timing) seconds!")
            print("This will be done by the \(fastest_model)")
            self.model_timer = Timer.scheduledTimer(withTimeInterval: fastest_timing, repeats: false) { [weak self] timer in
                guard let strongSelf = self else {
                    return
                }
                
                strongSelf.play_card(player: fastest_model)
            }
        }        
    }
    
    func memory_game_logic(number_of_players: Int, delta_card: Double, delta_timer: Double, first_memory: Bool) -> (String, Double) {
        var m1_timing = 0.0
        var m2_timing = 0.0
        var m3_timing = 0.0
        var fastest_timing: Double = 99999
        var fastest_model = "Player 2"
        if number_of_players >= 2 {
            // Do for model 1
            let (latency1, result1) = model1!.add_request_memory(delta_timer: delta_timer, delta_card: delta_card, first_memory: false)
            
            if (result1 != nil) {
               // print("Good! Latency is \(latency1), chunk is \(result1)")
                print("The blended time is \(Double(result1!.slotvals["timing"]!.number() ?? 99))")
                m1_timing = pulsesToTime(Int(result1!.slotvals["timing"]!.number() ?? Double.random(in: 10..<31)))
            }
            else {
//                print("Chunk retrieved was nil!")
//                print("Latency is \(latency1)")
                m1_timing = pulsesToTime(Int.random(in: 10..<31))
            }
            
            if !(model1_cards.isEmpty) {
                fastest_timing  = m1_timing + latency1
            }
            print("The timer for model 1 is \(fastest_timing)")
            
        }
        
        if number_of_players >= 3 {
            // Do for model 2
            let (latency2, result2) = model2!.add_request_memory(delta_timer: delta_timer, delta_card: delta_card, first_memory: false)
            
            if (result2 != nil) {
                m2_timing = pulsesToTime(Int(result2!.slotvals["timing"]!.number() ?? Double.random(in: 10..<31)))
            }
            else {
                m2_timing = pulsesToTime(Int.random(in: 10..<31))
            }
            
            if m2_timing + latency2 < fastest_timing && !(model2_cards.isEmpty) {
                fastest_model = "Player 3"
                fastest_timing = m2_timing + latency2
            }
            
        }
        if number_of_players >= 4 {
            let (latency3, result3) = model3!.add_request_memory(delta_timer: delta_timer, delta_card: delta_card, first_memory: false)
            
            if (result3 != nil) {
                m3_timing = pulsesToTime(Int(result3!.slotvals["timing"]!.number() ?? Double.random(in: 10..<31)))
            }
            else {
                m3_timing = pulsesToTime(Int.random(in: 10..<31))
            }
            
            if m3_timing + latency3 < fastest_timing && !(model3_cards.isEmpty) {
                fastest_model = "Player 4"
                fastest_timing = m3_timing + latency3
            }
        }
        if (first_memory) {
            print("First move of the round! The fastest model is \(fastest_model), their time before playing is \(fastest_timing)")
        }
        return (fastest_model, fastest_timing)
    }
    
    func noise(_ s: Double) -> Double {
        let rand = Double.random(in: 0.001..<0.999)
        return s * log((1 - rand) / rand)
    }
    
    func pulsesToTime(_ pulses: Int, t_0: Double = 0.011, a: Double = 1.1, b: Double = 0.015, addNoise: Bool = true) -> Double {
        var time = 0.0
        var pulseDuration = t_0
        
        var pulsesLeft = pulses
        while pulsesLeft > 0 {
            time += pulseDuration
            pulsesLeft -= 1
            pulseDuration = a * pulseDuration + (addNoise ? noise(b * a * pulseDuration) : 0)
        }
        
        return time
    }
}
