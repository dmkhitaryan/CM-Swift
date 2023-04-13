//
//  HowToPlayView.swift
//  CM-Swift
//
//  Created by David Mkhitaryan on 13/04/2023.
//

import SwiftUI

struct HowToPlayView: View {
    var body: some View {
        ZStack {
            Background()
            Image("game_rules")
                .resizable()
        }
    }
}

struct HowToPlay_Previews: PreviewProvider {
    static var previews: some View {
        HowToPlayView()
    }
}
