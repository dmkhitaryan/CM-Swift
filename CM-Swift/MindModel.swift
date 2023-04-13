//
//  Model.swift
//  CM-Swift
//
//  Created by David Mkhitaryan on 04/03/2023.
//

import Foundation

struct MindModel {
    internal var model = Model()
    var card_arr: Array<Int>?
    
    mutating func run(playerName: String, cards: Array<Int>) {
        if cards != nil {
            card_arr = cards
        }
        else {
            let _ = print("Card_arr is nil!")
        }
        if model.buffers["goal"] == nil {
            let chunk = Chunk(s: model.generateName(string: "goal"), m: model)
            chunk.setSlot(slot: "isa", value: "goal")
            chunk.setSlot(slot: "state", value: "start")
            model.buffers["goal"] = chunk
        }
        let goal = model.buffers["goal"]!
        
        switch (goal.slotvals["state"]!.description) {
        case "start":
            let _ = print("hi!")
            let n_memories: Int = 5
            for n in 0..<n_memories {
                let prev_card = Int.random(in: 40..<100)
                let current_card = Int.random(in: 1..<100)
                let abs_diff: Double = Double(abs(prev_card - current_card))
                
                let memory = Chunk(s: "memory\(n)", m: model)
                memory.setSlot(slot: "isa", value: "card-memory")
                memory.setSlot(slot: "difference", value: abs_diff)
                //memory.setSlot(slot: "timing", value: Double(log(abs_diff)/log(1.3))+Double.random(in: 3..<6))
                memory.setSlot(slot: "timing", value: Double(timeToPulses(abs_diff) + Int.random(in: 1...3)))
                model.dm.addToDM(memory)
                    
                goal.setSlot(slot: "state", value: "wait")
            }
            // let _ = print(model.dm.chunks)
        default: let _ = 10;
        }
        
    }
    mutating func play_card() {
        card_arr!.removeFirst()
    }
    
    mutating func deal_hand(cards: Array<Int>, level: Int, playerN: Int) {
        card_arr! = Array(cards[playerN*level...(level*(playerN+1))-1]).sorted()
    }
    
    mutating func filter_hand(cards_to_filter: Array<Int>) {
        card_arr! = card_arr!.filter{!cards_to_filter.contains($0)}
    }
    
    func mismatch(x: Value, y: Value) -> Double? {
        if (x.number() == nil || y.number() == nil) {
           return nil
        }
        else if x == y {
            return 0
        }
        else {
            let dif = -abs(x.number()! - y.number()!) / 25
            return max(-1, dif)
            }
        }
    
    mutating func add_request_memory(delta_timer: Double, delta_card: Double, first_memory: Bool) -> (Double, Chunk?) {
        if !(first_memory) {
            let memory_id = Int.random(in: 1..<100000)
            let memory = Chunk(s: "memory\(memory_id)", m: model)
            memory.setSlot(slot: "isa", value: "card-memory")
            memory.setSlot(slot: "difference", value: delta_card)
            memory.setSlot(slot: "timing", value: Double(timeToPulses(delta_timer) + Int.random(in: 1...3)))
            model.dm.addToDM(memory)
        }
        //print("The following memory was added to DM: \(memory)")
        
        model.time += 0.05
        // Retrieve timing for the model
        let retrieval = Chunk(s: "retrieval", m: model)
        retrieval.setSlot(slot: "isa", value: "card-memory")
        retrieval.setSlot(slot: "difference", value: delta_card)
        let (latency, result) = model.dm.blendedPartialRetrieve(chunk: retrieval, mismatchFunction: mismatch)
        return (latency+0.1, result) // 0.1 represents waiting 50ms for adding and requesting memory.
    }
    

    func noise(_ s: Double) -> Double {
        let rand = Double.random(in: 0.001..<0.999)
        return s * log((1 - rand) / rand)
    }

    func timeToPulses(_ time: Double, t_0: Double = 0.011, a: Double = 1.1, b: Double = 0.015, addNoise: Bool = true) -> Int {
        var pulses = 0
        var pulseDuration = t_0
        
        var timeLeft = time
        while timeLeft >= pulseDuration {
            timeLeft -= pulseDuration
            pulses += 1
            pulseDuration = a * pulseDuration + (addNoise ? noise(b * a * pulseDuration) : 0)
        }
        
        return pulses
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
