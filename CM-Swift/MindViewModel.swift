//
//  ViewModel.swift
//  CM-Swift
//
//  Created by David Mkhitaryan on 04/03/2023.
//

import Foundation

class MindViewModel: ObservableObject {
    
    init() {
        print("check!")
        var model = MindModel()
        model.run()
    }
}
