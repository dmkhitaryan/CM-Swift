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
            let n_memories: Int = 10
            for n in 0..<n_memories {
                let prev_card = Int.random(in: 1..<100)
                let current_card = Int.random(in: 1..<100)
                let abs_diff: Double = Double(abs(prev_card - current_card))
                
                let memory = Chunk(s: "memory\(n)", m: model)
                memory.setSlot(slot: "isa", value: "card-memory")
                memory.setSlot(slot: "difference", value: abs_diff)
                memory.setSlot(slot: "timing", value: log(abs_diff)/log(1.3)+Double.random(in: 3..<6))
                model.dm.addToDM(memory)
                    
                goal.setSlot(slot: "state", value: "wait")
            }
            let _ = print(model.dm.chunks)
        default: let _ = 10;
        }
        
    }
    mutating func play_card() {
        card_arr!.removeFirst()
    }
    mutating func add_request_memory(delta: Double, delta_card: Double) -> (Double, Chunk?) {
        let memory_id = Int.random(in: 1..<100000)
        let memory = Chunk(s: "memory\(memory_id)", m: model)
        memory.setSlot(slot: "isa", value: "card-memory")
        memory.setSlot(slot: "difference", value: delta_card)
        memory.setSlot(slot: "timing", value: delta)
        model.dm.addToDM(memory)
        
        // Retrieve timing for the model
        let retrieval = Chunk(s: "retrieval", m: model)
        retrieval.setSlot(slot: "isa", value: "card-memory")
        retrieval.setSlot(slot: "difference", value: delta_card)
        let (latency, result) = model.dm.blendedRetrieve(chunk: retrieval)
        return (latency, result)
    }
}
